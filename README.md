voxelmetaverse: playing with [voxel.js](https://github.com/voxel)
=========

[![browser support](https://ci.testling.com/voxel/voxelmetaverse.png)
](https://ci.testling.com/voxel/voxelmetaverse)


**Live demo: [https://voxel.github.io/voxelmetaverse/](https://voxel.github.io/voxelmetaverse/)**

Core plugins:
* [voxel-engine-stackgl](https://github.com/voxel/voxel-engine-stackgl): An experimental port of [voxel-engine](https://github.com/maxogden/voxel-engine) replacing [three.js](http://threejs.org) with [stackgl](http://stack.gl)
* [voxel-registry](https://github.com/voxel/voxel-registry): A shared registry for managing item and block IDs
* [voxel-stitch](https://github.com/voxel/voxel-stitch): Stitches a set of block textures together into a texture atlas
* [voxel-shader](https://github.com/voxel/voxel-shader): Shader for use with [voxel-mesher](https://github.com/deathcap/voxel-mesher)
* [voxel-mesher](https://github.com/voxel/voxel-mesher): A voxel mesher for ndarrays that handles ambient occlusion and transparency
* [game-shell-fps-camera](https://github.com/deathcap/game-shell-fps-camera): First person shooter style camera controls for [game-shell](https://github.com/mikolalysenko/game-shell)

Additional plugins:
* [voxel-artpacks](https://github.com/voxel/voxel-artpacks): Artpack selector dialog
* [voxel-wireframe](https://github.com/voxel/voxel-wireframe): Shows a wireframe around the voxels
* [voxel-chunkborder](https://github.com/voxel/voxel-chunkborder): Show borders around the outline of chunks
* [voxel-outline](https://github.com/voxel/voxel-outline): Show an outline around the player's currently targeted block
* [voxel-carry](https://github.com/voxel/voxel-carry): Adds a player [inventory](https://github.com/deathcap/inventory) for carrying items
* [voxel-bucket](https://github.com/voxel/voxel-bucket): Adds buckets to pickup and place fluids
* [voxel-fluid](https://github.com/voxel/voxel-fluid): Fluid registry
* [voxel-skyhook](https://github.com/voxel/voxel-skyhook): A block that can be placed in mid-air, no other block required in the world to be placed against
* [voxel-bedrock](https://github.com/voxel/voxel-bedrock): Bedrock block
* [voxel-recipes](https://github.com/voxel/voxel-recipes): Provides access to [craftingrecipes](https://github.com/deathcap/craftingrecipes)
* [voxel-quarry](https://github.com/voxel/voxel-quarry): Automated mining quarry
* [voxel-measure](https://github.com/voxel/voxel-measure): Tape measure tool to measure distance between blocks
* [voxel-webview](https://github.com/voxel/voxel-webview): Embed webpages in a voxel.js world using CSS 3D
* [voxel-vr](https://github.com/voxel/voxel-vr): WebVR voxel.js plugin
* [voxel-workbench](https://github.com/voxel/voxel-workbench): A workbench block to access a 3x3 crafting grid
* [voxel-furnace](https://github.com/voxel/voxel-furnace): A furnace block for smelting items
* [voxel-chest](https://github.com/voxel/voxel-chest): Chests to store your items
* [voxel-inventory-hotbar](https://github.com/voxel/voxel-inventory-hotbar): Adds a hotbar to view and select a subset of player inventory
* [voxel-inventory-crafting](https://github.com/voxel/voxel-inventory-crafting): A player inventory and crafting dialog
* [voxel-voila](https://github.com/voxel/voxel-voila): Show name of block highlighted at your cursor
* [voxel-health](https://github.com/voxel/voxel-health): Stores player health value
* [voxel-health-bar](https://github.com/voxel/voxel-health-bar): Player health bar display
* [voxel-food](https://github.com/voxel/voxel-food): Adds food you can eat to improve your health
* [voxel-scriptblock](https://github.com/voxel/voxel-scriptblock): A block to run player-defined JavaScript code
* [voxel-sfx](https://github.com/voxel/voxel-sfx): Play sound effects on events
* [voxel-flight](https://github.com/voxel/voxel-flight): Double-tap jump to toggle flight mode, then use jump/crouch to adjust altitude, and land if you hit the ground
* [voxel-gamemode](https://github.com/voxel/voxel-gamemode): Toggle between a creative/survival game modes 
* [voxel-sprint](https://github.com/voxel/voxel-sprint): Double-tap the forward key (default 'W') to sprint
* [voxel-decals](https://github.com/voxel/voxel-decals): Adds textured planes on the side of blocks
* [voxel-mine](https://github.com/voxel/voxel-mine): Mine blocks of variable hardness, hold down the left mouse button to mine
* [voxel-harvest](https://github.com/voxel/voxel-harvest): Add mined blocks from [voxel-mine](https://github.com/deathcap/voxel-mine) to an [inventory](https://github.com/deathcap/inventory)
* [voxel-use](https://github.com/voxel/voxel-use): Use items and blocks
* [voxel-reach](https://github.com/voxel/voxel-reach): Listen for fire/firealt events, raycast the voxel within reach, and send mining/interact events for the hit voxel
* [voxel-pickaxe](https://github.com/voxel/voxel-pickaxe): Adds pickaxe tools to help you mine faster
* [voxel-hammer](https://github.com/voxel/voxel-hammer): Adds a hammer tool to mine blocks in a 3x3x1 area
* [voxel-wool](https://github.com/voxel/voxel-wool): Colored wool blocks
* [voxel-pumpkin](https://github.com/voxel/voxel-pumpkin): Carvable pumpkin blocks, a directional block metadata demonstration
* [voxel-blockdata](https://github.com/voxel/voxel-blockdata): Store arbitrary per-block data in chunks
* [voxel-glass](https://github.com/voxel/voxel-glass): Glass blocks
* [voxel-land](https://github.com/voxel/voxel-land): A terrain generator combining several landform features: grass, dirt, stone, trees
* [voxel-flatland](https://github.com/voxel/voxel-flatland): Simple flat land terrain generator
* [voxel-decorative](https://github.com/voxel/voxel-decorative): Decorative blocks you can craft
* [voxel-inventory-creative](https://github.com/voxel/voxel-inventory-creative): Inventory dialog with an infinite supply of all items and blocks
* [voxel-console](https://github.com/voxel/voxel-console): Text console widget
* [voxel-commands](https://github.com/voxel/voxel-commands): A few basic commands for [voxel-console](https://github.com/deathcap/voxel-console)
* [voxel-drop](https://github.com/voxel/voxel-drop): Drag and drop various types of files to load them into your game
* [voxel-zen](https://github.com/voxel/voxel-zen): Hide distracting UI elements
* [camera-debug](https://github.com/deathcap/camera-debug): Adjustable camera debug datgui settings for [voxel-shader](https://github.com/deathcap/voxel-shader)
* [voxel-plugins-ui](https://github.com/voxel/voxel-plugins-ui): A graphical interface for [voxel-plugins](https://github.com/deathcap/voxel-plugins) using [dat-gui](https://code.google.com/p/dat-gui/)
* [voxel-fullscreen](https://github.com/voxel/voxel-fullscreen): Toggle fullscreen with a hotkey
* [voxel-keys](https://github.com/voxel/voxel-keys): Events for key bindings
* [kb-bindings-ui](https://github.com/deathcap/kb-bindings-ui): A graphical interface for configuring [kb-bindings](https://github.com/deathcap/kb-bindings) or [game-shell](https://github.com/mikolalysenko/game-shell) using [dat-gui](https://code.google.com/p/dat-gui/).
