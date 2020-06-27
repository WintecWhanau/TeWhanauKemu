extends KinematicBody2D
class_name Player

# DEFAULTS
export (Vector2) var maxSpeedDefault := Vector2(150, 1200)
export (Vector2) var accelerationDefault := Vector2(100, 1000)
export (Vector2) var accelerationRateDefault := Vector2(1.5, 1)
export (float) var jumpForceDefault := -350.0
export (float) var slideTimeDefault := 0.6
export (float) var frictionGround := 0.2
export (float) var frictionAir := 0.05
export (float) var maxHPDefault := 100.0
# INIT
onready var maxSpeed := maxSpeedDefault
onready var acceleration := accelerationDefault
onready var acceleration_rate := accelerationRateDefault
onready var jumpForce := jumpForceDefault
onready var friction := frictionGround
onready var maxHp := maxHPDefault
onready var hp := maxHp
# MOVEMENT
var velocity := Vector2(0, 0)
onready var acc := acceleration
var gravityRatio := 1.0
var direction:int = 1
const up = Vector2(0, -1)
var stateMachine: PlayerStateMachine
# ANIMATIONS
onready var AnimatedSprite: AnimatedSprite = $AnimatedSprite
# MELEE
onready var Taiaha = $Taiaha
onready var TaiahaHitbox = $Taiaha/CollisionShape2D
onready var MeleeTimer = $Timers/MeleeTimer
var isAttacking = false
var canAttack = true
# SHOOT
const patu = preload("res://Scene/Player/Patu.tscn")
export var level = 0
onready var shootPoint = $SpawnPoints/PatuPosition2D
var shootPosition:int = 1
var canShoot = true
var isShooting = false
var defaultShootTimer = 4.5
var shootCooldown = 0.1
# JUMP
var canDoubleJump = true
var isJumping = false
# AUDIO
onready var jumpAudio = $Audio/JumpAudio
onready var shootAudio = $Audio/ShootAudio
# DEBUG
onready var Label: Label = $Label

func _ready():
	$Timers/DefaultShootTimer.wait_time = defaultShootTimer
	MeleeTimer.wait_time = 0.3
	stateMachine = PlayerStateMachine.new(self)
	stateMachine.set_state_deferred(PlayerStateMachine.IDLE)
# end of _ready

func _physics_process(delta):
	stateMachine.process(delta)
# end of _physics_process

func process_movement(delta):
	var snap = Vector2.DOWN * 32 if !isJumping else Vector2.ZERO
	velocity = move_and_slide_with_snap(velocity, snap, up)
# end of process_movement

func process_velocity(delta):
	if direction != 0:
		velocity.x += direction * acc.x * delta
		acc.x *= acceleration_rate.x
		velocity.x = clamp(velocity.x, -maxSpeed.x, maxSpeed.x)
	else:
		acc.x = acceleration.x
		velocity.x = lerp(velocity.x, 0, friction)

	velocity.y += acc.y * gravityRatio * delta
	velocity.y = clamp(velocity.y, -maxSpeed.y, maxSpeed.y)
# end of process_velocity

func _sprite_flip():
	if direction > 0:
		AnimatedSprite.flip_h = false
		if Taiaha.position.x < 0:
			Taiaha.position.x *= -1
	elif direction < 0:
		AnimatedSprite.flip_h = true
		if Taiaha.position.x < 0:
			pass
		else:
			Taiaha.position.x *= -1		
# end of _sprite_flip

func shoot():
	if canShoot:
		$Timers/DefaultShootTimer.start() # triggers default timer incase player doesnt catch patu
		canShoot = false
		var p = patu.instance()
		p.setLevel(level)
		if shootPosition == -1:
			if $SpawnPoints/PatuPosition2D.position.x < 0:
				pass
			else:
				$SpawnPoints/PatuPosition2D.position.x *= -1
			p.setDirection(-1)
		elif shootPosition == 1:
			if $SpawnPoints/PatuPosition2D.position.x < 0:
				$SpawnPoints/PatuPosition2D.position.x *= -1
			p.setDirection(1)
		p.global_position = $SpawnPoints/PatuPosition2D.global_position
		p.set_as_toplevel(true) # independent movement 
		get_parent().add_child(p)
		p.connect("caught",self,"handleCaught")
		shootAudio.play()
# end of shoot

func handleCaught():
	print('patu caught')
	$Timers/ShootCooldownTimer.wait_time = shootCooldown
	$Timers/ShootCooldownTimer.start()
# end of handleCaught

func _on_ShootCooldownTimer_timeout():
	canShoot = true
# end of _on_ShootCooldownTimer_timeout
	
func _on_DefaultShootTimer_timeout(): # if patu is not caught this is the default case
	canShoot = true
# end of _on_DefaultShootTimer_timeout

func melee():
	if canAttack:
		canAttack = false
		isAttacking = true
		TaiahaHitbox.disabled = false
		MeleeTimer.start()
# end of melee

func _on_Taiaha_body_entered(body):
	if isAttacking:
		if body.name != 'Player' && body.has_method('take_damage'):
			body.take_damage()
# end of _on_Taiaha_body_entered

func _on_MeleeTimer_timeout():
	if !canAttack:
		canAttack = true
		isAttacking = false
		TaiahaHitbox.disabled = true
# end of _on_MeleeTimer_timeout

class PlayerStateMachine extends StateMachine:
	enum {IDLE, RUN, JUMP, DOUBLE_JUMP, FALL, ATTACK, SHOOT}
	var player: Player = null

	func _init(playerLoad: Player):
		player = playerLoad
		add_state(IDLE)
		add_state(RUN)
		add_state(JUMP)
		add_state(DOUBLE_JUMP)
		add_state(FALL)
		add_state(ATTACK)
		add_state(SHOOT)

	func _do_actions(delta):
		"""Perform current state behavior"""
		match state:
			IDLE:
				player.Label.text = 'idle'
				_jump(player.jumpForce)
			RUN:
				player.Label.text = 'run'
				_jump(player.jumpForce)
			JUMP:
				player.Label.text = 'jump'
				if player.canDoubleJump: # double jump
					_jump(player.jumpForce / 1.5)
				pass
			DOUBLE_JUMP:
				player.Label.text = 'double jump'
				pass
			FALL:
				player.Label.text = 'fall'
				
				if player.canDoubleJump: # double jump
					_jump(player.jumpForce * 1.2)
				pass
			ATTACK:
				player.Label.text = 'shoot'
			SHOOT:
				player.Label.text = 'shoot'
		_handle_input(delta)
		player._sprite_flip()
		player.process_velocity(delta)
		player.process_movement(delta)

	func _check_conditions(delta):
		"""Check the current state transition conditions and return to the state to be transferred to"""
		match state:
			IDLE:
				if player.isShooting:
					return SHOOT
				elif player.isAttacking:
						return ATTACK
				elif player.is_on_floor():
					if player.direction != 0:
						return RUN
				else: 
					return JUMP
			RUN:
				if player.isShooting:
					return SHOOT
				elif player.isAttacking:
						return ATTACK
				elif player.is_on_floor():
					if player.direction == 0:
						return IDLE
				else:
					return JUMP
			JUMP:
				if player.isShooting:
					return SHOOT
				elif player.isAttacking:
						return ATTACK
				elif player.is_on_floor():
					if player.direction == 0:
						return IDLE
					else:
						return RUN
				elif !player.is_on_floor() && player.velocity.y >= 0:
					return FALL
			DOUBLE_JUMP:
				if player.is_on_floor():
					if player.direction == 0:
						return IDLE
					else:
						return RUN
				elif !player.is_on_floor() && player.velocity.y >= 0:
					return FALL
			FALL:
				if player.isShooting:
					return SHOOT
				elif player.isAttacking:
						return ATTACK
				elif player.is_on_floor():
					if player.direction == 0:
						return IDLE
					else:
						return RUN
			ATTACK:
				if player.canAttack:
					return IDLE
				pass
#			SHOOT:
#				return IDLE
#				pass

	func _enter_state(state, _old_state):
		"""Enter state"""
		match state:
			IDLE:
				player.gravityRatio = 0.1
				player.friction = player.frictionGround
				player.AnimatedSprite.play("idle")
			RUN:
				player.gravityRatio = 1.0
				player.friction = player.frictionGround
				player.AnimatedSprite.play("run")
			JUMP:
				player.gravityRatio = 1.0
				player.friction = player.frictionAir
				if player.velocity.y < 0:
					player.AnimatedSprite.play("jump")
					player.jumpAudio.play()
				else:
					player.AnimatedSprite.play("fall")
				player.canDoubleJump = true
				player.isJumping = true
			DOUBLE_JUMP:
				player.gravityRatio = 1.0
				player.friction = player.frictionAir
				if player.velocity.y < 0:
					player.AnimatedSprite.play("jump")
					player.jumpAudio.play()
				else:
					player.AnimatedSprite.play("fall")
			FALL:
				player.AnimatedSprite.play("fall")
			ATTACK:
				player.AnimatedSprite.play("attack")

	func _exit_tree():
		"""Exit state"""
		match state:
			JUMP:
				player.isJumping = false
				pass
			DOUBLE_JUMP:
				player.canDoubleJump = true
				pass
			SHOOT:
				player.canShoot = false

	func _handle_input(delta):
			var direction = Input.get_action_strength("right") - Input.get_action_strength("left")
			if player.direction != direction:
				player.acc = player.accelerationDefault
			player.direction = direction
			if player.direction == -1:
				player.shootPosition = -1
			elif player.direction == 1:
				player.shootPosition = 1
			if Input.is_action_just_pressed("shoot"):
				player.shoot()
			if Input.is_action_just_pressed("melee"):
				player.melee()

	func _jump(jumpHeight):
		if Input.is_action_just_pressed("jump"):
			player.jumpAudio.play()
			player.canDoubleJump = false # this is stopping player from constantly jumping
			player.velocity.y += jumpHeight
