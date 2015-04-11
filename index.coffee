
# plugins (loaded by voxel-plugins; listed here for browserify)
require 'voxel-artpacks'
require 'voxel-wireframe'
require 'voxel-chunkborder'
require 'voxel-outline'
require 'voxel-carry'
require 'voxel-bucket'
require 'voxel-fluid'
require 'voxel-skyhook'
require 'voxel-recipes'
require 'voxel-quarry'
require 'voxel-measure'
require 'voxel-webview'
require 'voxel-vr'
require 'voxel-workbench'
require 'voxel-furnace'
require 'voxel-chest'
require 'voxel-inventory-hotbar'
require 'voxel-inventory-crafting'
require 'voxel-voila'
require 'voxel-health'
require 'voxel-health-bar'
#require 'voxel-health-fall' # TODO: after https://github.com/deathcap/voxel-health-fall/issues/1
require 'voxel-food'
require 'voxel-sfx'
require 'voxel-flight'
require 'voxel-gamemode'
require 'voxel-sprint'
require 'voxel-decals'
require 'voxel-mine'
require 'voxel-harvest'
require 'voxel-use'
require 'voxel-reach'
require 'voxel-pickaxe'
require 'voxel-hammer'
require 'voxel-wool'
require 'voxel-pumpkin'
require 'voxel-blockdata'
require 'voxel-glass'
require 'voxel-land'
require 'voxel-decorative'
require 'voxel-inventory-creative'
#require 'voxel-clientmc' # TODO: after published
require 'voxel-console'
require 'voxel-commands'
require 'voxel-drop'
require 'voxel-zen'
require 'camera-debug'
require 'voxel-plugins-ui'
require 'voxel-fullscreen'
require 'voxel-keys'
require 'kb-bindings-ui'
require 'voxel-background-music'

createEngine = require 'voxel-engine-stackgl'

main = () ->
  console.log 'voxelmetaverse starting: ', global.__BROWSERIFY_META_DATA__GIT_VERSION, global.__BROWSERIFY_META_DATA__CREATED_AT # TODO: display somewhere on page

  createEngine {require:require, exposeGlobal:true, pluginOpts:
    'voxel-engine-stackgl':
      appendDocument: true
      exposeGlobal: true  # for debugging

      lightsDisabled: true
      arrayTypeSize: 2  # arrayType: Uint16Array
      useAtlas: true
      generateChunks: false
      chunkDistance: 2
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
        'F5': 'pov'
        'O': 'home'
        'E': 'inventory'

        'T': 'console'
        '/': 'console2'
        '.': 'console3'

        'P': 'packs'

        'F1': 'zen'

    # built-in plugins
    'voxel-registry': {}
    'voxel-stitch':
      artpacks: ['ProgrammerArt-ResourcePack.zip']
    'voxel-shader':
      #cameraFOV: 45
      #cameraFOV: 70
      cameraFOV: 90
      #cameraFOV: 110

    'voxel-mesher': {},
    'game-shell-fps-camera':
      position: [0, -100, 0]


    'voxel-artpacks': {}
    'voxel-wireframe': {}
    'voxel-chunkborder': {}
    'voxel-outline': {}
    'voxel-recipes': {}
    'voxel-quarry': {}
    'voxel-measure': {}
    'voxel-webview': {}
    'voxel-vr': {onDemand: true} # has to be enabled after gl-init to replace renderer
    'voxel-carry': {inventoryWidth:10, inventoryRows:5}
    'voxel-bucket': {fluids: ['water', 'lava']}
    'voxel-fluid': {}
    #'voxel-virus': {materialSource: 'water', material: 'waterFlow', isWater: true} # requires this.game.materials TODO: water
    'voxel-skyhook': {}
    'voxel-blockdata': {}
    'voxel-chest': {}
    'voxel-workbench': {}
    'voxel-furnace': {}
    'voxel-pickaxe': {}
    'voxel-hammer': {}
    'voxel-wool': {}
    'voxel-pumpkin': {}

    'voxel-glass': {}
    'voxel-land': {populateTrees: true}
    'voxel-decorative': {}
    'voxel-inventory-creative': {}
    #'voxel-clientmc': {url: 'ws://localhost:1234', onDemand: true} # TODO

    'voxel-console': {}
    'voxel-commands': {}
    'voxel-drop': {}
    'voxel-zen': {}


    #'voxel-player': {image: 'player.png', homePosition: [2,14,4], homeRotation: [0,0,0]} # three.js TODO: stackgl avatar
    'voxel-health': {}
    'voxel-health-bar': {}
    #'voxel-health-fall': {} # requires voxel-player TODO: enable and test
    'voxel-food': {}
    'voxel-sfx': {}
    'voxel-flight': {flySpeed: 0.8, onDemand: true}
    'voxel-gamemode': {}
    'voxel-sprint': {}
    'voxel-inventory-hotbar': {inventorySize:10}
    'voxel-inventory-crafting': {}
    'voxel-reach': { reachDistance: 8 }
    'voxel-decals': {}
    # left-click hold to mine
    'voxel-mine':
      instaMine: false
      progressTexturesPrefix: 'destroy_stage_'
      progressTexturesCount: 9
    # right-click to place block (etc.)
    'voxel-use': {}
    # handles 'break' event from voxel-mine (left-click hold breaks blocks), collects block and adds to inventory
    'voxel-harvest': {}
    'voxel-voila': {}
    'voxel-fullscreen': {}
    'voxel-keys': {}

    # the GUI window (built-in toggle with 'H')
    #'voxel-debug': {} # heavily three.js dependent TODO: more debugging options for stackgl-based engine besides camera?
    'camera-debug': {} # TODO: port from game-shell-fps-camera
    'voxel-plugins-ui': {}
    'kb-bindings-ui': {}
    'voxel-background-music': {}
  }

main()
