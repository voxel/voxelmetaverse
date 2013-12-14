# vim: set shiftwidth=2 tabstop=2 softtabstop=2 expandtab:

ever = require 'ever'
datgui = require 'dat-gui'
ItemPile = require 'itempile'
Inventory = require 'inventory'
createToolbar = require 'toolbar'
createGame = require 'voxel-engine'
createPlugins = require 'voxel-plugins'
createPluginsUI = require 'voxel-plugins-ui'

createRegistry = require 'voxel-registry'

# plugins (loaded by voxel-plugins; listed here for browserify)
require 'voxel-oculus'
require 'voxel-highlight'
require 'voxel-player'
require 'voxel-fly'
require 'voxel-walk'
require 'voxel-mine'
require 'voxel-reach'
require 'voxel-debris'
require 'voxel-debug'
require 'voxel-land'

module.exports = () ->
  console.log 'voxpopuli starting'

  # setup the game 
  console.log 'creating game'
  game = createGame {
    #generate: voxel.generator['Valley']
    #generateVoxelChunk: terrain {chunkSize: 32, chunkDistance: 2, seed: 42}
    useAtlas: false
    generateChunks: false
    chunkDistance: 2
    materials: []  # added dynamically later
    texturePath: 'AssetPacks/ProgrammerArt/textures/blocks/' # subproject with textures
    worldOrigin: [0, 0, 0],
    controls:
      discreteFire: false
      fireRate: 100 # ms between firing
      jumpSpeed: 0.001
    }

  toolbar = createToolbar {el: '#tools'}
  toolbar.on 'select', (material) ->
    game.currentMaterial = +material


  console.log 'initializing plugins'
  plugins = createPlugins game, {require: require}

  registry = plugins.load 'registry', {}
  registry.registerBlock 'grass', {texture: ['grass_top', 'dirt', 'grass_side'], hardness:5}
  registry.registerBlock 'dirt', {texture: 'dirt', hardness:4}
  registry.registerBlock 'stone', {texture: 'stone', hardness:90}
  registry.registerBlock 'logOak', {texture: ['log_oak_top', 'log_oak_top', 'log_oak'], hardness:8}
  registry.registerBlock 'cobblestone', {texture: 'cobblestone', hardness:90}
  registry.registerBlock 'oreCoal', {texture: 'coal_ore'}
  registry.registerBlock 'brick', {texture: 'brick'}
  registry.registerBlock 'obsidian', {texture: 'obsidian', hardness: 900}
  registry.registerBlock 'leavesOak', {texture: 'leaves_oak_opaque', hardness: 2}
  registry.registerBlock 'glass', {texture: 'glass'}

  game.materials.load registry.getBlockPropsAll 'texture'

  plugins.load 'land', {
    populateTrees: true
    materials: {  # TODO: refactor
      grass: registry.getBlockID 'grass'
      dirt: registry.getBlockID 'dirt'
      stone: registry.getBlockID 'stone'
      bark: registry.getBlockID 'logOak'
      leaves: registry.getBlockID 'leavesOak'
    }
  }

  plugins.preconfigure 'oculus', { distortion: 0.2, separation: 0.5 }

  if window.location.href.indexOf('rift') != -1 ||  window.location.hash.indexOf('rift') != -1
    # Oculus Rift support
    plugins.enable 'oculus'
    document.getElementById('logo').style.visibility = 'hidden'

  container = document.body
  window.game = window.g = game # for debugging
  game.appendTo container
  return game if game.notCapable()

  # create the player from a minecraft skin file and tell the
  # game to use it as the main player
  avatar = game.plugins.load 'player', {image: 'player.png'}
  avatar.pov('first');
  avatar.possess()
  home(avatar)

  controlsTarget = game.controls.target()

  game.plugins.load 'fly', {physical: controlsTarget, flySpeed: 0.8}
  game.plugins.disable 'fly'

  game.plugins.load 'walk', { 
    skin: controlsTarget.playerSkin
    bindGameEvents: true
    shouldStopWalking: () =>
      vx = Math.abs(controlsTarget.velocity.x)
      vz = Math.abs(controlsTarget.velocity.z)
      return vx > 0.001 || vz > 0.001
    }

  REACH_DISTANCE = 8
  reach = game.plugins.load 'reach', { reachDistance: REACH_DISTANCE }
  mine = game.plugins.load 'mine', {
    instaMine: false
    reach: reach
    #progressTexturesDir: 'ProgrammerArt/textures/blocks/'
    progressTexturesPrefix: 'destroy_stage_'
    progressTexturesCount: 9
    defaultHardness: 9
    hardness: registry.getBlockPropsAll 'hardness'
  }

  # highlight blocks when you look at them
  highlight = game.plugins.load 'highlight', {
    color:  0xff0000
    distance: REACH_DISTANCE
    adjacentActive: () -> false   # don't hold <Ctrl> for block placement (right-click instead, 'reach' plugin)
  }

  game.mode = 'survival'

  haveMouseInteract = false
  game.interact.on 'attain', () => haveMouseInteract = true
  game.interact.on 'release', () => haveMouseInteract = false

  ever(document.body).on 'keydown', (ev) ->
    return if !haveMouseInteract    # don't care if typing into a GUI, etc. TODO: use kb-controls here too? (like voxel-engine)

    if ev.keyCode == 'R'.charCodeAt(0)
      # toggle between first and third person 
      avatar.toggle()
      # TODO: disable/re-enable voxel-walk in 1st/3rd person?
    else if ev.keyCode == 'T'.charCodeAt(0)
      game.plugins.toggle 'oculus'
    else if '0'.charCodeAt(0) <= ev.keyCode <= '9'.charCodeAt(0)
      slot = ev.keyCode - '0'.charCodeAt(0)
      if slot == 0
        slot = 10
      console.log 'switching to slot #{slot}'

      game.currentMaterial = slot

    else if ev.keyCode == 'O'.charCodeAt(0)
      home(avatar)
    else if ev.keyCode == 'C'.charCodeAt(0)
      # TODO: add gamemode event? for plugins to handle instead of us
      if game.mode == 'survival'
        game.mode = 'creative'
        game.plugins.enable 'fly'
        mine.instaMine = true
        console.log 'creative mode'
      else
        game.mode = 'survival'
        game.plugins.disable 'fly'
        mine.instaMine = false
        console.log 'survival mode'

  # cancel context-menu on right-click
  ever(document.body).on 'contextmenu', (event) ->
    event.preventDefault()
    return false

  reach.on 'interact', (target) ->
    if not target
      console.log 'waving'
      return

    game.createBlock target.adjacent, game.currentMaterial
    #game.setBlock target.voxel, 0
    # TODO: other interactions depending on item (ex: click button, check target.sub; or other interactive blocks)

  # block interaction: left/right-click to break/place blocks, uses raytracing
  game.currentMaterial = 1

  debris = plugins.load 'debris', {power: 1.5}
  plugins.disable 'debris' # lag :(

  debris.on 'collect', (item) ->
    console.log 'collect', item

  playerInventory = new Inventory(10)

  mine.on 'break', (target) =>
    if plugins.isEnabled('debris') # TODO: refactor into module itself (event listener)
      debris(target.voxel, target.value)
    else
      game.setBlock target.voxel, 0

    # TODO: add as item name instead of id
    droppedPile = new ItemPile(target.value, 1) # TODO: custom drops
    playerInventory.give droppedPile
    console.log ''+playerInventory

  gui = new datgui.GUI()
  console.log 'gui',gui
  debug = plugins.load 'debug', {gui: gui}
  debug.axis [0, 0, 0], 10

  pluginsUI = createPluginsUI game, {gui: gui}

  return game

home = (avatar) ->
  #avatar.yaw.position.set 2, 14, 4
  avatar.yaw.position.set 2, 5, 4


