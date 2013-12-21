# vim: set shiftwidth=2 tabstop=2 softtabstop=2 expandtab:

ever = require 'ever'
datgui = require 'dat-gui'

ItemPile = require 'itempile'
Inventory = require 'inventory'
InventoryWindow = require 'inventory-window'

createGame = require 'voxel-engine'
createPlugins = require 'voxel-plugins'
createPluginsUI = require 'voxel-plugins-ui'

createRegistry = require 'voxel-registry'

# plugins (loaded by voxel-plugins; listed here for browserify)
require 'voxel-inventory-hotbar'
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

  registry.registerItem 'pickaxeWood', {itemTexture: '../items/wood_pickaxe', speed: 2.0} # TODO: fix path
  registry.registerItem 'pickaxeDiamond', {itemTexture: '../items/diamond_pickaxe', speed: 10.0}

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

  game.mode = 'survival'

  playerInventory = new Inventory(50)
  #toolbar = createToolbar {el: '#tools'}
  #inventoryToolbar = plugins.load 'inventory-toolbar', {toolbar:toolbar, inventory:playerInventory, inventorySize:10, registry:registry}
  inventoryHotbar = plugins.load 'inventory-hotbar', {inventory:playerInventory, inventorySize:10, registry:registry}

  REACH_DISTANCE = 8
  reach = game.plugins.load 'reach', { reachDistance: REACH_DISTANCE }
  mine = game.plugins.load 'mine', {
    reach: reach
    timeToMine: (target) =>
      # the innate difficulty of mining this block
      blockID = game.getBlock(target.voxel)
      blockName = registry.getBlockName(blockID)
      hardness = registry.getBlockProps(blockName)?.hardness
      hardness ?= 9

      # effectiveness of currently held tool, shortens mining time
      heldItem = inventoryHotbar.held()
      speed = 1.0
      speed = registry.getItemProps(heldItem?.item)?.speed ? 1.0
      finalTimeToMine = Math.max(hardness / speed, 0)
      # TODO: more complex mining 'classes', e.g. shovel against dirt, axe against wood

      return finalTimeToMine

    instaMine: false
    progressTexturesPrefix: 'destroy_stage_'
    progressTexturesCount: 9
  }

  # highlight blocks when you look at them
  highlight = game.plugins.load 'highlight', {
    color:  0xff0000
    distance: REACH_DISTANCE
    adjacentActive: () -> false   # don't hold <Ctrl> for block placement (right-click instead, 'reach' plugin)
  }


  haveMouseInteract = false
  game.interact.on 'attain', () => haveMouseInteract = true
  game.interact.on 'release', () => haveMouseInteract = false

  # one of everything, please..
  creativeInventoryArray = []
  for props in registry.blockProps
    creativeInventoryArray.push(new ItemPile(props.name, Infinity)) if props.name?

  survivalInventoryArray = []

  ever(document.body).on 'keydown', (ev) =>
    return if !haveMouseInteract    # don't care if typing into a GUI, etc. TODO: use kb-controls here too? (like voxel-engine)

    if ev.keyCode == 'R'.charCodeAt(0)
      # toggle between first and third person 
      avatar.toggle()
      # TODO: disable/re-enable voxel-walk in 1st/3rd person?
    else if ev.keyCode == 'T'.charCodeAt(0)
      game.plugins.toggle 'oculus'
    else if ev.keyCode == 'O'.charCodeAt(0)
      home(avatar)
    else if ev.keyCode == 'E'.charCodeAt(0)
      # inventory window

      # TODO
      
      if not window.iw?
        window.iw = new InventoryWindow {
          width: 10
          inventory: playerInventory
          getTexture: (itemPile) -> game.materials.texturePath + registry.getItemProps(itemPile.item).itemTexture + '.png'
          }
        container = iw.createContainer()

        container.style.position = 'absolute'
        container.style.top = '100px'
        container.style.left = '100px'
        container.style.zIndex = 1
        document.body.appendChild(container)
      else
        if window.iw.container.style.visibility == 'hidden'
          window.iw.refresh()   # TODO: refresh automatically
          window.iw.container.style.visibility = ''
        else
          window.iw.container.style.visibility = 'hidden'
        

    else if ev.keyCode == 'P'.charCodeAt(0)
      inventoryHotbar.give(new ItemPile('pickaxeDiamond', 1, {damage:0}))
      console.log 'gave diamond pickaxe' # until we have crafting
    else if ev.keyCode == 'L'.charCodeAt(0)
      inventoryHotbar.give(new ItemPile('pickaxeWood', 1, {damage:0}))
      console.log 'gave wooden pickaxe'

    else if ev.keyCode == 'C'.charCodeAt(0)
      # TODO: add gamemode event? for plugins to handle instead of us
      if game.mode == 'survival'
        game.mode = 'creative'
        game.plugins.enable 'fly'
        mine.instaMine = true
        survivalInventoryArray = inventoryHotbar.inventory.array
        inventoryHotbar.inventory.array = creativeInventoryArray
        inventoryHotbar.refresh()
        console.log 'creative mode'
      else
        game.mode = 'survival'
        game.plugins.disable 'fly'
        mine.instaMine = false
        inventoryHotbar.inventory.array = survivalInventoryArray
        inventoryHotbar.refresh()
        console.log 'survival mode'

  # cancel context-menu on right-click
  ever(document.body).on 'contextmenu', (event) ->
    event.preventDefault()
    return false
  
  # right-click to place block
  reach.on 'interact', (target) =>
    if not target
      console.log 'waving'
      return

    # test if can place block here (not blocked by self), before consuming inventory
    # (note: canCreateBlock + setBlock = createBlock, but we want to check in between)
    if not game.canCreateBlock target.adjacent
      console.log 'blocked'
      return

    taken = inventoryHotbar.takeHeld(1)
    if not taken?
      console.log 'nothing in this inventory slot to use'
      return

    currentBlockID = registry.getBlockID(taken.item)
    game.setBlock target.adjacent, currentBlockID

    # TODO: other interactions depending on item (ex: click button, check target.sub; or other interactive blocks)

  debris = plugins.load 'debris', {power: 1.5}
  plugins.disable 'debris' # lag :(

  debris.on 'collect', (item) ->
    console.log 'collect', item


  # block broken after completed mining (from voxel-mine) by holding left-click
  mine.on 'break', (target) =>
    if plugins.isEnabled('debris') # TODO: refactor into module itself (event listener)
      debris(target.voxel, target.value)
    else
      game.setBlock target.voxel, 0

    blockName = registry.getBlockName(target.value)
    droppedPile = new ItemPile(blockName, 1) # TODO: custom drops

    # adds to inventory and refreshes toolbar
    excess = inventoryHotbar.give droppedPile

    if excess > 0
      # if didn't fit in inventory, un-mine the block since they can't carry it
      # TODO: handle partial fits, prevent dupes (canFit before giving?) -- needed once have custom drops
      game.setBlock target.voxel, target.value
      # TOOD: some kind of notification


  gui = new datgui.GUI()
  console.log 'gui',gui
  debug = plugins.load 'debug', {gui: gui}
  debug.axis [0, 0, 0], 10

  pluginsUI = createPluginsUI game, {gui: gui}

  return game

home = (avatar) ->
  #avatar.yaw.position.set 2, 14, 4
  avatar.yaw.position.set 2, 5, 4


