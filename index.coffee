# vim: set shiftwidth=2 tabstop=2 softtabstop=2 expandtab:

console.log "Hello"

createGame = require 'voxel-engine'
highlight = require 'voxel-highlight'
player = require 'voxel-player'
voxel = require 'voxel'
extend = require 'extend'
fly = require 'voxel-fly'
walk = require 'voxel-walk'

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

  # setup the game and add some trees
  console.log "creating game"
  game = createGame opts
  console.log "created"
  container = opts.container || document.body
  window.game = game # for debugging
  game.appendTo container
  return game if game.notCapable()

  createPlayer = player game

  # create the player from a minecraft skin file and tell the
  # game to use it as the main player
  avatar = createPlayer opts.playerSkin || 'player.png'
  game.pov = 'third'
  avatar.pov(game.pov)
  avatar.possess()
  home(avatar)
  game.avatar = avatar
       
  setup game, avatar
  
  return game

home = (avatar) ->
  avatar.yaw.position.set 2, 14, 4

ACTION_BREAK = 0
ACTION_INTERACT = 1
ACTION_PICK = 2
getAction = (kb_state) ->
  switch
    when kb_state['fire'] && kb_state['firealt'] then ACTION_PICK  # TODO: block picking
    when kb_state['fire'] then ACTION_BREAK
    when kb_state['firealt'] then ACTION_INTERACT
    else ACTION_BREAK

GAME_MODE_SURVIVAL = 0
GAME_MODE_CREATIVE = 1

defaultSetup = (game, avatar) ->
  console.log "entering setup"

  makeFly = fly game
  target = game.controls.target()
  game.mode = GAME_MODE_SURVIVAL
  game.flyer = makeFly target
  game.flyer.enabled = false

  console.log "configuring highlight "
  # highlight blocks when you look at them, hold <Ctrl> for block placement
  hl = game.highlighter = highlight game, { color:  0xff0000 }

  # toggle between first and third person 
  window.addEventListener 'keydown', (ev) ->
    if ev.keyCode == 'R'.charCodeAt(0)
      game.pov = {first: 'third', third: 'first'}[game.pov] # toggle TODO: 2nd (facing)

      # hide player in 1st person to fix obscuring view
      show = game.pov != 'first'
      avatar.playerSkin.rightArm.visible = show  # TODO: change visibility of entire skin model all at once instead of individual meshes
      avatar.playerSkin.leftArm.visible = show
      avatar.playerSkin.body.visible = show
      avatar.playerSkin.rightLeg.visible = show
      avatar.playerSkin.leftLeg.visible = show
      avatar.playerSkin.head.visible = show

      avatar.pov(game.pov) 
    else if '0'.charCodeAt(0) <= ev.keyCode <= '9'.charCodeAt(0)
      slot = ev.keyCode - '0'.charCodeAt(0)
      if slot == 0
        slot = 10
      console.log "switching to slot #{slot}"

      game.currentMaterial = slot

    else if ev.keyCode == 'H'.charCodeAt(0)
      home(game.avatar)
    else if ev.keyCode == 'C'.charCodeAt(0)
      if game.mode == GAME_MODE_SURVIVAL
        game.mode = GAME_MODE_CREATIVE
        game.flyer.enabled = true
        console.log("creative mode")
      else
        game.mode = GAME_MODE_SURVIVAL
        if game.flyer.flying
          game.flyer.stopFlying()
        game.flyer.enabled = false
        console.log("survival mode")

  # cancel context-menu on right-click
  window.addEventListener 'contextmenu', (event) ->
    event.preventDefault()
    return false

  # block interaction: left/right-click to break/place blocks, uses raytracing
  game.currentMaterial = 1

  game.on 'fire', (target, state) ->

    REACH_DISTANCE = 8
    hit = game.raycastVoxels game.cameraPosition(), game.cameraVector(), REACH_DISTANCE

    switch getAction(state)
      when ACTION_BREAK
        if hit.voxel?
          game.setBlock hit.voxel, 0
      when ACTION_INTERACT
        if hit.adjacent?
          game.createBlock hit.adjacent, game.currentMaterial

  game.on 'tick', () ->
    walk.render target.playerSkin
    vx = Math.abs target.velocity.x
    vz = Math.abs target.velocity.z
    if vx > 0.001 || vz > 0.001
      walk.stopWalking() 
    else
      walk.startWalking()
