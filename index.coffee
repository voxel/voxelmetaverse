# vim: set shiftwidth=2 tabstop=2 softtabstop=2 expandtab:

console.log "Hello"

voxel = require 'voxel'
extend = require 'extend'

createGame = require 'voxel-engine'

createPlugins = require 'voxel-plugins'

# plugins
createOculus = require 'voxel-oculus'
createHighlight = require 'voxel-highlight'
createPlayer = require 'voxel-player'
createFly = require 'voxel-fly'
createWalk = require 'voxel-walk'
createMine = require 'voxel-mine'
createReach = require 'voxel-reach'
createDebris = require 'voxel-debris'
createDebug = require 'voxel-debug'

module.exports = (opts, setup) ->
  setup ||= defaultSetup
  console.log "initializing"

  defaults =
    generate: voxel.generator['Valley']
    mesher: voxel.meshers.greedy
    chunkDistance: 2
    materials: [
      ['grass_top', 'dirt', 'grass_side'],
      'dirt',
      ['log_oak_top', 'log_oak_top', 'log_oak'],
      'stone',
      'cobblestone',
      'coal_ore',
      'brick',
      'obsidian',
      'leaves_oak_opaque',
      'glass',
      ]
    texturePath: 'ProgrammerArt/textures/blocks/' # subproject with textures
    worldOrigin: [0, 0, 0],
    controls:
      discreteFire: false
      fireRate: 100 # ms between firing
      jumpSpeed: 0.001
      #jumpTimer: 200.0

  opts = extend {}, defaults, opts || {}

  # setup the game 
  # TODO: add some trees
  console.log "creating game"
  game = createGame opts

  console.log "initializing plugins"
  plugins = createPlugins(game, {require: require})

  plugins.preconfigure("voxel-oculus", { distortion: 0.2, separation: 0.5 })

  if window.location.href.indexOf("rift") != -1 ||  window.location.hash.indexOf("rift") != -1
    # Oculus Rift support TODO: allow in-game toggling
    plugins.enable("voxel-oculus")
  #  document.getElementById("logo").style.visibility = "hidden"

  container = opts.container || document.body
  window.game = game # for debugging
  game.appendTo container
  return game if game.notCapable()


  # create the player from a minecraft skin file and tell the
  # game to use it as the main player
  avatar = game.plugins.load "voxel-player", {image: 'player.png'}
  avatar.pov('first');
  avatar.possess()
  home(avatar)
  game.avatar = avatar
      
  setup game, avatar
  
  return game

home = (avatar) ->
  avatar.yaw.position.set 2, 14, 4


GAME_MODE_SURVIVAL = 0
GAME_MODE_CREATIVE = 1

REACH_DISTANCE = 8

defaultSetup = (game, avatar) ->
  console.log "entering setup"

  game.plugins.load("voxel-debug", {}) # TODO: allow disable
  #debug.axis([0, 0, 0], 10)

  game.mode = GAME_MODE_SURVIVAL
  controlsTarget = game.controls.target()

  game.flyer = game.plugins.load "voxel-fly", {physical: controlsTarget, flySpeed: 0.8, enabled: false}

  game.plugins.load "voxel-walk", { 
    skin: controlsTarget.playerSkin
    bindGameEvents: true
    shouldStopWalking: () =>
      vx = Math.abs(controlsTarget.velocity.x)
      vz = Math.abs(controlsTarget.velocity.z)
      return vx > 0.001 || vz > 0.001
    }

  reach = game.plugins.load "voxel-reach", { reachDistance: REACH_DISTANCE }
  mine = game.plugins.load "voxel-mine", {
    instaMine: false
    reach: reach
    progressTexturesBase: "ProgrammerArt/textures/blocks/destroy_stage_"
    progressTexturesCount: 9
  }

  console.log "configuring highlight "
  # highlight blocks when you look at them, hold <Ctrl> for block placement
  highlight = game.plugins.load "voxel-highlight", {
    color:  0xff0000
    distance: REACH_DISTANCE
    adjacentActive: () -> false
  }

  # toggle between first and third person 
  window.addEventListener 'keydown', (ev) ->
    if ev.keyCode == 'R'.charCodeAt(0)
      avatar.toggle()
    else if ev.keyCode == 'T'.charCodeAt(0)
      game.plugins.toggle("voxel-oculus")
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
        game.flyer.enabled = true
        mine.instaMine = true
        console.log("creative mode")
      else
        game.mode = GAME_MODE_SURVIVAL
        if game.flyer.flying
          game.flyer.stopFlying()
        game.flyer.enabled = false
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

  debris = game.plugins.load("voxel-debris", {power: 1.5})
  debris.on 'collect', (item) ->
    console.log("collect", item)


