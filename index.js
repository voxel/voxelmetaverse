// Function Scope
(function() {

  // Plugins loaded by voxel-plugins are listed here for browserify
  // Art Pack Selector Dialog
  require('voxel-artpacks');
  // Shows wireframe if showWireFrame = true
  require('voxel-wireframe');
  // Shows chunks around border (F9)
  require('voxel-chunkborder');
  // Shows outline around targeted voxel
  require('voxel-outline');
  // Player inventory
  require('voxel-carry');
  // Buckets to pick up and place fluids
  require('voxel-bucket');
  // Fluid Registration
  require('voxel-fluid'); // TODO: pending rename https://github.com/voxel/voxel-fluid/issues/2
  // A Block which can be placed in the sky
  require('voxel-skyhook'); // TODO: pending rename https://github.com/voxel/voxel-skyhook/issues/1
  // Access to "craftingrecipes" (https://github.com/deathcap/craftingrecipes)
  require('voxel-recipes');
  // Adds quarry block which can mine large blocks of ... well ... blocks
  require('voxel-quarry');
  // Item that measures between blocks  
  require('voxel-measure'); // TODO: pending rename https://github.com/voxel/voxel-measure/issues/1
  // Not a whole lot of reason to keep this in the game... maybe a modified version
  // which can fit within a GUI element
  // require('voxel-webview');
  // Renders scene for use with webvr
  require('voxel-vr');
  // Adds 3x3 work bench (crafting table)
  require('voxel-workbench'); // TODO: pending rename https://github.com/voxel/voxel-workbench/issues/4
  // Adds furnace for smelting
  require('voxel-furnace'); // TODO: pending rename https://github.com/voxel/voxel-furnace/issues/5
  // Adds chest
  require('voxel-chest'); // TODO: pending rename https://github.com/voxel/voxel-chest/issues/4
  // Adds a hotbar for the player inventory
  require('voxel-inventory-hotbar');  
  // Adds 2x2 craftin area
  require('voxel-inventory-crafting');
  // Displays name of the targeted block
  require('voxel-voila');
  // Stores player health
  require('voxel-health');
  // Shows player health
  require('voxel-health-bar');
  // Adds food items which restore health
  require('voxel-food');
  // Play sound effects on events
  require('voxel-sfx');
  // Adds flight control
  require('voxel-flight');
  // Toggle between creative and survival game mode
  require('voxel-gamemode');
  //  Adds sprinting
  require('voxel-sprint');
  // Adds textured planes on the side of blocks
  require('voxel-decals');
  // Supports mining of blocks (essentially destroying them)
  require('voxel-mine');
  // Works with voxel-mine to add an item representing the block in the players inventory
  // Essentailly "harvesting" the block
  require('voxel-harvest');
  // Allows interfacing with blocks and items
  require('voxel-use');
  // Allows for raycasting and "getting" blocks
  require('voxel-reach');
  // Adds picks, axes and spades
  require('voxel-pickaxe');
  // Adds a hammer, similar to a pick but larger aoe
  require('voxel-hammer');
  // Adds wool blocks
  require('voxel-wool');
  // Adds pumpkin block
  require('voxel-pumpkin'); // TODO: pending rename https://github.com/voxel/voxel-pumpkin/issues/6
  // Allows for adding additional data to blocks
  require('voxel-blockdata');
  // Adds glass blocks
  require('voxel-glass'); // TODO: pending rename https://github.com/voxel/voxel-glass/issues/6
  // Terrain generator
  require('voxel-land');
  // Adds decorative blocks
  require('voxel-decorative');  // TODO: pending rename https://github.com/voxel/voxel-decorative/issues/2
  // Creative inventory dialog
  require('voxel-inventory-creative');
  // Adds console widget
  require('voxel-console');
  // Basic commands for voxel-console
  require('voxel-commands');
  // Supports dropping several different files
  require('voxel-drop');
  // Removes all distractions
  require('voxel-zen');
  // Adjustable camera debug datgui settings for voxel-shader (voxel.js plugin)
  require('camera-debug');
  // GUI for enabling and disabling plugins
  require('voxel-plugins-ui');
  // Toggles fullscreen
  require('voxel-fullscreen');
  // events for key bindings
  require('voxel-keys');
  // ui for key bindings
  require('kb-bindings-ui');

  var createEngine = require('voxel-engine-stackgl');

  var main = function() {
    console.log('voxelmetaverse starting: ', global.__BROWSERIFY_META_DATA__GIT_VERSION, global.__BROWSERIFY_META_DATA__CREATED_AT);
    return createEngine({
      require: require,
      exposeGlobal: true,
      pluginOpts: {
        'voxel-engine-stackgl': {
          appendDocument: true,
          exposeGlobal: true,
          lightsDisabled: true,
          arrayTypeSize: 2,
          useAtlas: true,
          generateChunks: false,
          chunkDistance: 2,
          worldOrigin: [0, 0, 0],
          controls: {
            discreteFire: false,
            fireRate: 100,
            jumpTimer: 25
          },
          keybindings: {
            'W': 'forward',
            'A': 'left',
            'S': 'backward',
            'D': 'right',
            '<up>': 'forward',
            '<left>': 'left',
            '<down>': 'backward',
            '<right>': 'right',
            '<mouse 1>': 'fire',
            '<mouse 3>': 'firealt',
            '<space>': 'jump',
            '<shift>': 'crouch',
            '<control>': 'alt',
            '<tab>': 'sprint',
            'F5': 'pov',
            'O': 'home',
            'E': 'inventory',
            'T': 'console',
            '/': 'console2',
            '.': 'console3',
            'P': 'packs',
            'F1': 'zen'
          }
        },
        'voxel-registry': {},
        'voxel-stitch': {
          artpacks: ['ProgrammerArt-ResourcePack.zip']
        },
        'voxel-shader': {
          cameraFOV: 90
        },
        'voxel-mesher': {},
        'game-shell-fps-camera': {
          position: [0, -100, 0]
        },
        'voxel-artpacks': {},
        'voxel-wireframe': {},
        'voxel-chunkborder': {},
        'voxel-outline': {},
        'voxel-recipes': {},
        'voxel-quarry': {},
        'voxel-measure': {},
        'voxel-vr': {
          onDemand: true
        },
        'voxel-carry': {},
        'voxel-bucket': {
          fluids: ['water', 'lava']
        },
        'voxel-fluid': {},
        'voxel-skyhook': {},
        'voxel-blockdata': {},
        'voxel-chest': {},
        'voxel-workbench': {},
        'voxel-furnace': {},
        'voxel-pickaxe': {},
        'voxel-hammer': {},
        'voxel-wool': {},
        'voxel-pumpkin': {},
        'voxel-glass': {},
        'voxel-land': {
          populateTrees: true
        },
        'voxel-decorative': {},
        'voxel-inventory-creative': {},
        'voxel-console': {},
        'voxel-commands': {},
        'voxel-drop': {},
        'voxel-zen': {},
        'voxel-health': {},
        'voxel-health-bar': {},
        'voxel-food': {},
        'voxel-sfx': {},
        'voxel-flight': {
          flySpeed: 0.8,
          onDemand: true
        },
        'voxel-gamemode': {},
        'voxel-sprint': {},
        'voxel-inventory-hotbar': {
          inventorySize: 10
        },
        'voxel-inventory-crafting': {},
        'voxel-reach': {
          reachDistance: 8
        },
        'voxel-decals': {},
        'voxel-mine': {
          instaMine: false,
          progressTexturesPrefix: 'destroy_stage_',
          progressTexturesCount: 9
        },
        'voxel-use': {},
        'voxel-harvest': {},
        'voxel-voila': {},
        'voxel-fullscreen': {},
        'voxel-keys': {},
        'camera-debug': {},
        'voxel-plugins-ui': {},
        'kb-bindings-ui': {}
      }
    });
  };

  main();

}).call(this);
