// Function Scope
(function() {

  // Plugins loaded by voxel-plugins are listed here for browserify
  require('voxel-artpacks');

  require('voxel-wireframe');

  require('voxel-chunkborder');

  require('voxel-outline');

  require('voxel-carry');

  require('voxel-bucket');

  require('voxel-fluid');

  require('voxel-skyhook');

  require('voxel-recipes');

  require('voxel-quarry');

  require('voxel-measure');

  require('voxel-webview');

  require('voxel-vr');

  require('voxel-workbench');

  require('voxel-furnace');

  require('voxel-chest');

  require('voxel-inventory-hotbar');

  require('voxel-inventory-crafting');

  require('voxel-voila');

  require('voxel-health');

  require('voxel-health-bar');

  require('voxel-food');

  require('voxel-sfx');

  require('voxel-flight');

  require('voxel-gamemode');

  require('voxel-sprint');

  require('voxel-decals');

  require('voxel-mine');

  require('voxel-harvest');

  require('voxel-use');

  require('voxel-reach');

  require('voxel-pickaxe');

  require('voxel-hammer');

  require('voxel-wool');

  require('voxel-pumpkin');

  require('voxel-blockdata');

  require('voxel-glass');

  require('voxel-land');

  require('voxel-decorative');

  require('voxel-inventory-creative');

  require('voxel-console');

  require('voxel-commands');

  require('voxel-drop');

  require('voxel-zen');

  require('camera-debug');

  require('voxel-plugins-ui');

  require('voxel-fullscreen');

  require('voxel-keys');

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
        'voxel-webview': {},
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
