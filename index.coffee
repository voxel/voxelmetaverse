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
    chunkDistance: 2
    materials: ['#fff', '#000'],
    materialFlatColor: true,
    worldOrigin: [0, 0, 0],
    controls:
      discreteFire: true

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
  avatar.possess()
  avatar.yaw.position.set 2, 14, 4
       
  setup game, avatar
  
  return game

defaultSetup = (game, avatar) ->
  console.log "entering setup"

  console.log "making fly"
  makeFly = fly game
  console.log "getting target"
  target = game.controls.target()
  console.log "setting flyer"
  game.flyer = makeFly target

  blockPosPlace = blockPosErase = null

  console.log "configuring highlight "
  # highlight blocks when you look at them, hold <Ctrl> for block placement
  hl = game.highlighter = highlight game, { color:  0xff0000 }
  hl.on 'highlight', (voxelPos) => blockPosErase = voxelPos
  hl.on 'remove', (voxelPos) => blockPosErase = null
  hl.on 'highlight-adjacent', (voxelPos) => blockPosPlace = voxelPos
  hl.on 'remove-adjacent', (voxelPos) => blockPosPlace = null

  # toggle between first and third person 
  window.addEventListener 'keydown', (ev) ->
    avatar.toggle() if ev.keyCode == 'R'.charCodeAt(0)

  # block interaction stuff, uses highlight data
  currentMaterial = 1

  game.on 'fire', (target, state) ->
    console.log "fire #{target}, #{state}"
    position = blockPosPlace
    if position
      game.createBlock position, currentMaterial
    else
      position = blockPosErase
      game.setBlock(position, 0) if position

  
  game.on 'tick', () ->
    walk.render target.playerSkin
    vx = Math.abs target.velocity.x
    vz = Math.abs target.velocity.z
    if vx > 0.001 || vz > 0.001
      walk.stopWalking() 
    else
      walk.startWalking()

