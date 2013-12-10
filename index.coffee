# vim: set shiftwidth=2 tabstop=2 softtabstop=2 expandtab:

console.log "Hello"

voxel = require 'voxel'
extend = require 'extend'
datgui = require 'dat-gui'
createGame = require 'voxel-engine'
createPlugins = require 'voxel-plugins'

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

module.exports = (opts, setup) ->
  setup ||= defaultSetup
  console.log "initializing"

  registry = createRegistry null, {}
  registry.registerBlock 'grass', {texture: ['grass_top', 'dirt', 'grass_side'], hardness:5}
  registry.registerBlock 'dirt', {texture: 'dirt', hardness:2}
  registry.registerBlock 'stone', {texture: 'stone', hardness:90}
  registry.registerBlock 'logOak', {texture: ['log_oak_top', 'log_oak_top', 'log_oak'], hardness:8}
  registry.registerBlock 'cobblestone', {texture: 'cobblestone', hardness:90}
  registry.registerBlock 'oreCoal', {texture: 'coal_ore'}
  registry.registerBlock 'brick', {texture: 'brick'}
  registry.registerBlock 'obsidian', {texture: 'obsidian', hardness: 900}
  registry.registerBlock 'leavesOak', {texture: 'leaves_oak_opaque', hardness: 2}
  registry.registerBlock 'glass', {texture: 'glass'}

  defaults =
    #generate: voxel.generator['Valley']
    #generateVoxelChunk: terrain {chunkSize: 32, chunkDistance: 2, seed: 42}
    generateChunks: false
    mesher: voxel.meshers.greedy
    chunkDistance: 2
    materials: registry.getBlockPropsAll('texture')
    texturePath: 'ProgrammerArt/textures/blocks/' # subproject with textures
    worldOrigin: [0, 0, 0],
    controls:
      discreteFire: false
      fireRate: 100 # ms between firing
      jumpSpeed: 0.001
      #jumpTimer: 200.0

  opts = extend {}, defaults, opts || {}

  # setup the game 
  console.log "creating game"
  game = createGame opts
  game.registry = registry

  console.log "initializing plugins"
  plugins = createPlugins(game, {require: require})

  plugins.load 'land', {populateTrees: true}

  plugins.preconfigure 'oculus', { distortion: 0.2, separation: 0.5 }

  if window.location.href.indexOf('rift') != -1 ||  window.location.hash.indexOf('rift') != -1
    # Oculus Rift support
    plugins.enable 'oculus'
  #  document.getElementById("logo").style.visibility = "hidden"

  container = opts.container || document.body
  window.game = game # for debugging
  game.appendTo container
  return game if game.notCapable()


  # create the player from a minecraft skin file and tell the
  # game to use it as the main player
  avatar = game.plugins.load 'player', {image: 'player.png'}
  avatar.pov('first');
  avatar.possess()
  home(avatar)
  game.avatar = avatar
      
  setup game, avatar
  
  return game

home = (avatar) ->
  #avatar.yaw.position.set 2, 14, 4
  avatar.yaw.position.set 2, 5, 4


GAME_MODE_SURVIVAL = 0
GAME_MODE_CREATIVE = 1

REACH_DISTANCE = 8

defaultSetup = (game, avatar) ->
  console.log "entering setup"

  gui = new datgui.GUI()
  console.log 'gui',gui
  debug = game.plugins.load 'debug', {gui: gui}
  debug.axis([0, 0, 0], 10)

  game.mode = GAME_MODE_SURVIVAL
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

  reach = game.plugins.load 'reach', { reachDistance: REACH_DISTANCE }
  mine = game.plugins.load 'mine', {
    instaMine: false
    reach: reach
    progressTexturesBase: "ProgrammerArt/textures/blocks/destroy_stage_"
    progressTexturesCount: 9
    defaultHardness: 9
    hardness: this.game.registry.getBlockPropsAll('hardness')
  }

  console.log "configuring highlight "
  # highlight blocks when you look at them
  highlight = game.plugins.load 'highlight', {
    color:  0xff0000
    distance: REACH_DISTANCE
    adjacentActive: () -> false   # don't hold <Ctrl> for block placement (right-click instead, 'reach' plugin)
  }

  # toggle between first and third person 
  window.addEventListener 'keydown', (ev) ->
    if ev.keyCode == 'R'.charCodeAt(0)
      avatar.toggle()
    else if ev.keyCode == 'T'.charCodeAt(0)
      game.plugins.toggle "oculus"
    else if '0'.charCodeAt(0) <= ev.keyCode <= '9'.charCodeAt(0)
      slot = ev.keyCode - '0'.charCodeAt(0)
      if slot == 0
        slot = 10
      console.log "switching to slot #{slot}"

      game.currentMaterial = slot

    else if ev.keyCode == 'O'.charCodeAt(0)
      home(game.avatar)
    else if ev.keyCode == 'C'.charCodeAt(0)
      # TODO: add gamemode event? for plugins to handle instead of us
      if game.mode == GAME_MODE_SURVIVAL
        game.mode = GAME_MODE_CREATIVE
        game.plugins.enable 'fly'
        mine.instaMine = true
        console.log("creative mode")
      else
        game.mode = GAME_MODE_SURVIVAL
        game.plugins.disable 'fly'
        mine.instaMine = false
        console.log("survival mode")

  # cancel context-menu on right-click
  window.addEventListener 'contextmenu', (event) ->
    event.preventDefault()
    return false

  reach.on 'interact', (target) ->
    if not target
      console.log("waving")
      return

    game.createBlock target.adjacent, game.currentMaterial
    #game.setBlock target.voxel, 0
    # TODO: other interactions depending on item (ex: click button, check target.sub; or other interactive blocks)

  mine.on 'break', (goner) ->
    #console.log "exploding",goner
    #game.explode goner # TODO: update voxel-debris for latest voxel-engine, doesn't pass materials?
    game.setBlock goner, 0

  # block interaction: left/right-click to break/place blocks, uses raytracing
  game.currentMaterial = 1

  debris = game.plugins.load 'debris', {power: 1.5}
  debris.on 'collect', (item) ->
    console.log("collect", item)


