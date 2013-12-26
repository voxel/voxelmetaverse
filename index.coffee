# vim: set shiftwidth=2 tabstop=2 softtabstop=2 expandtab:

ever = require 'ever'
datgui = require 'dat-gui'

ItemPile = require 'itempile'
Inventory = require 'inventory'
InventoryWindow = require 'inventory-window'
{Recipe, AmorphousRecipe, PositionalRecipe, CraftingThesaurus, RecipeLocator} = require 'craftingrecipes'

createGame = require 'voxel-engine'
createPlugins = require 'voxel-plugins'
createPluginsUI = require 'voxel-plugins-ui'
createBindingsUI = require 'kb-bindings-ui'

createRegistry = require 'voxel-registry'

# plugins (loaded by voxel-plugins; listed here for browserify)
require 'voxel-workbench'
require 'voxel-inventory-hotbar'
require 'voxel-inventory-dialog'
require 'voxel-oculus'
require 'voxel-highlight'
require 'voxel-player'
require 'voxel-fly'
require 'voxel-walk'
require 'voxel-mine'
require 'voxel-harvest'
require 'voxel-use'
require 'voxel-reach'
require 'voxel-debris'
require 'voxel-debug'
require 'voxel-land'

module.exports = () ->
  console.log 'voxpopuli starting'

  if window.performance && window.performance.timing
    loadingTime = Date.now() - window.performance.timing.navigationStart
    console.log "User-perceived page loading time: #{loadingTime / 1000}s"

  # setup the game 
  console.log 'creating game'
  game = createGame {
    lightsDisabled: true
    #generate: voxel.generator['Valley']
    #generateVoxelChunk: terrain {chunkSize: 32, chunkDistance: 2, seed: 42}
    useAtlas: false
    generateChunks: false
    chunkDistance: 2
    materials: []  # added dynamically later
    texturePath: 'AssetPacks/ProgrammerArt/textures/blocks/' # subproject with textures
    worldOrigin: [0, 0, 0]
    controls:
      discreteFire: false
      fireRate: 100 # ms between firing
      jumpTimer: 25
    keybindings:
      # voxel-engine defaults
      'W': 'forward'
      'A': 'left'
      'S': 'backward'
      'D': 'right'
      '<up>': 'forward'
      '<left>': 'left'
      '<down>': 'backward'
      '<right>': 'right'
      '<mouse 1>': 'fire'
      '<mouse 3>': 'firealt'
      '<space>': 'jump'
      '<shift>': 'crouch'
      '<control>': 'alt'
      '<tab>': 'sprint'

      # our extras
      'R': 'pov'
      'T': 'vr'
      'O': 'home'
      'E': 'inventory'
      'C': 'gamemode'
    }

  # add lighting - based on voxel-engine addLights()
  ambientLight = new game.THREE.AmbientLight(0x888888)
  game.scene.add(ambientLight)
  directionalLight = new game.THREE.DirectionalLight(0xffffff, 1)
  directionalLight.position.set(1, 1, 0.5).normalize()
  game.scene.add(directionalLight)


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

  registry.registerBlock 'plankOak', {texture: 'planks_oak'}
  registry.registerBlock 'logBirch', {texture: ['log_birch_top', 'log_birch_top', 'log_birch'], hardness:8} # TODO: generate

  registry.registerItem 'pickaxeWood', {itemTexture: '../items/wood_pickaxe', speed: 2.0} # TODO: fix path
  registry.registerItem 'pickaxeDiamond', {itemTexture: '../items/diamond_pickaxe', speed: 10.0}
  registry.registerItem 'stick', {itemTexture: '../items/stick'}

  # recipes TODO: move to registry?
  registry.recipes = RecipeLocator
  registry.thesaurus = CraftingThesaurus
  CraftingThesaurus.registerName 'wood.log', new ItemPile('logOak')
  CraftingThesaurus.registerName 'wood.log', new ItemPile('logBirch')
  CraftingThesaurus.registerName 'wood.plank', new ItemPile('plankOak')
  CraftingThesaurus.registerName 'tree.leaves', new ItemPile('leavesOak')
  RecipeLocator.register new AmorphousRecipe(['wood.log'], new ItemPile('plankOak', 2))
  RecipeLocator.register new AmorphousRecipe(['wood.plank', 'wood.plank'], new ItemPile('stick', 4))

  RecipeLocator.register new PositionalRecipe([
    ['wood.plank', 'wood.plank', 'wood.plank'],
    [undefined, 'stick', undefined],
    [undefined, 'stick', undefined]], new ItemPile('pickaxeWood', 1))

  # temporary recipe
  RecipeLocator.register new PositionalRecipe([
    ['tree.leaves', 'tree.leaves', 'tree.leaves'],
    [undefined, 'stick', undefined],
    [undefined, 'stick', undefined]], new ItemPile('pickaxeDiamond', 1))

  playerInventory = new Inventory(10, 5)

  # workbench - adds its own block (call before game.materials.load) and recipe
  workbenchDialog = plugins.load 'workbench', {playerInventory:playerInventory, registry:registry}


  game.materials.load registry.getBlockPropsAll 'texture'
  global.InventoryWindow_defaultGetTexture = (itemPile) => registry.getItemPileTexture(itemPile)

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

  #playerInventory.give new ItemPile('stick', 32)
  #playerInventory.give new ItemPile('logOak', 10)
  #playerInventory.give new ItemPile('plankOak', 10)
  #playerInventory.give new ItemPile('logBirch', 5)
  #playerInventory.give new ItemPile('workbench', 1)
  #toolbar = createToolbar {el: '#tools'}
  #inventoryToolbar = plugins.load 'inventory-toolbar', {toolbar:toolbar, inventory:playerInventory, inventorySize:10, registry:registry}
  inventoryHotbar = plugins.load 'inventory-hotbar', {inventory:playerInventory, inventorySize:10}

  inventoryDialog = plugins.load 'inventory-dialog', {playerInventory:playerInventory}

  REACH_DISTANCE = 8
  reach = game.plugins.load 'reach', { reachDistance: REACH_DISTANCE }
  # left-click hold to mine
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

  # right-click to place block (etc.)
  use = game.plugins.load 'use', {
    reach: reach
    registry: registry
    inventoryHotbar: inventoryHotbar
    }

  # highlight blocks when you look at them
  highlight = game.plugins.load 'highlight', {
    color:  0xff0000
    distance: REACH_DISTANCE
    adjacentActive: () -> false   # don't hold <Ctrl> for block placement (right-click instead, 'reach' plugin)
  }

  # one of everything, please..
  creativeInventoryArray = []
  for props in registry.blockProps
    creativeInventoryArray.push(new ItemPile(props.name, Infinity)) if props.name?

  survivalInventoryArray = []

  game.buttons.down.on 'pov', () -> avatar.toggle() # TODO: disable/re-enable voxel-walk in 1st/3rd person?
  game.buttons.down.on 'vr', () -> game.plugins.toggle 'oculus'
  game.buttons.down.on 'home', () -> home(avatar)
  game.buttons.down.on 'inventory', () -> inventoryDialog.toggle()
  game.buttons.down.on 'gamemode', () ->
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

  debris = plugins.load 'debris', {power: 1.5}
  plugins.disable 'debris' # lag :(

  debris.on 'collect', (item) ->
    console.log 'collect', item

  # handles 'break' event from voxel-mine (left-click hold breaks blocks), collects block and adds to inventory
  plugins.load 'harvest', {
    mine:mine
    registry:registry
    playerInventory:playerInventory,
    block2ItemPile: (blockName) ->
      # TODO: use registry? more data-driven

      if blockName == 'grass'
        return new ItemPile('dirt', 1)
      if blockName == 'stone'
        return new ItemPile('cobblestone', 1)
      if blockName == 'leavesOak'
        return undefined

      return new ItemPile(blockName)
  }

  gui = new datgui.GUI()
  console.log 'gui',gui
  debug = plugins.load 'debug', {gui: gui}
  debug.axis [0, 0, 0], 10

  pluginsUI = createPluginsUI game, {gui: gui}
  bindingsUI = createBindingsUI game, {gui: gui, kb: game.buttons}

  return game

home = (avatar) ->
  #avatar.yaw.position.set 2, 14, 4
  avatar.yaw.position.set 2, 5, 4


