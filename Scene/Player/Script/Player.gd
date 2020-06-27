extends KinematicBody2D
class_name Player
export (Vector2) var maxSpeedDefault := Vector2(150, 1200)
export (Vector2) var accelerationDefault := Vector2(100, 1000)
export (Vector2) var accelerationRateDefault := Vector2(1.5, 1)
export (float) var jumpForceDefault := -350.0
export (float) var slideTimeDefault := 0.6
export (float) var frictionGround := 0.2
export (float) var frictionAir := 0.05
export (float) var maxHPDefault := 100.0


onready var maxSpeed := maxSpeedDefault
onready var acceleration := accelerationDefault
onready var acceleration_rate := accelerationRateDefault
onready var jumpForce := jumpForceDefault
onready var friction := frictionGround
onready var maxHp := maxHPDefault
onready var hp := maxHp

var velocity := Vector2(0, 0)
onready var acc := acceleration
var gravityRatio := 1.0
var direction:int = 1
var shootPosition:int = 1

const up = Vector2(0, -1)
var stateMachine: PlayerStateMachine

const patu = preload("res://Scene/Player/Patu.tscn")
export var level = 0
var canShoot = true
var isShooting = false
var defaultShootTimer = 4.5
var shootCooldown = 0.1

var isAttacking = false

var canDoubleJump = true
var isJumping = false

onready var AnimatedSprite: AnimatedSprite = $AnimatedSprite
onready var Taiaha = $Taiaha
onready var Label: Label = $Label
onready var shootPoint = $SpawnPoints/PatuPosition2D
onready var jumpAudio = $Audio/JumpAudio
onready var shootAudio = $Audio/ShootAudio

func _ready():
	$Timers/DefaultShootTimer.wait_time = defaultShootTimer
	stateMachine = PlayerStateMachine.new(self)
	stateMachine.set_state_deferred(PlayerStateMachine.IDLE)

func _physics_process(delta):
	stateMachine.process(delta)

func process_movement(delta):
	var snap = Vector2.DOWN * 32 if !isJumping else Vector2.ZERO
	velocity = move_and_slide_with_snap(velocity, snap, up)

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

func _on_ShootCooldownTimer_timeout():
	canShoot = true
	pass # Replace with function body.
	
func _on_DefaultShootTimer_timeout(): # if patu is not caught this is the default case
	canShoot = true
	pass # Replace with function body.

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
				_handle_input(delta)
				_jump(player.jumpForce)
			RUN:
				player.Label.text = 'run'
				_handle_input(delta)
				_jump(player.jumpForce)
			JUMP:
				player.Label.text = 'jump'
				_handle_input(delta)
				if player.canDoubleJump: # double jump
					_jump(player.jumpForce / 1.5)
				pass
			DOUBLE_JUMP:
				player.Label.text = 'double jump'
				_handle_input(delta)
				pass
			FALL:
				player.Label.text = 'fall'
				_handle_input(delta)
				if player.canDoubleJump: # double jump
					_jump(player.jumpForce * 1.2)
				pass
			ATTACK:
				player.Label.text = 'shoot'
			SHOOT:
				player.Label.text = 'shoot'
		player._sprite_flip()
		player.process_velocity(delta)
		player.process_movement(delta)

	func _check_conditions(delta):
		"""Check the current state transition conditions and return to the state to be transferred to"""
		match state:
			IDLE:
				if player.isShooting:
					return SHOOT
#				elif
#					player.isAttacking:
#						return ATTACK
				elif player.is_on_floor():
					if player.direction != 0:
						return RUN
				else: 
					return JUMP
			RUN:
				if player.isShooting:
					return SHOOT
#				elif
#					player.isAttacking:
#						return ATTACK
				elif player.is_on_floor():
					if player.direction == 0:
						return IDLE
				else:
					return JUMP
			JUMP:
				if player.isShooting:
					return SHOOT
#				elif
#					player.isAttacking:
#						return ATTACK
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
#				elif
#					player.isAttacking:
#						return ATTACK
				elif player.is_on_floor():
					if player.direction == 0:
						return IDLE
					else:
						return RUN
			ATTACK:
				return IDLE
				pass
			SHOOT:
				return IDLE
				pass

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
			var direction = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
			if player.direction != direction:
				player.acc = player.accelerationDefault
			player.direction = direction
			if player.direction == -1:
				player.shootPosition = -1
			elif player.direction == 1:
				player.shootPosition = 1
			if Input.is_action_pressed("ui_shoot"):
				player.shoot()
				
	func _jump(jumpHeight):
		if Input.is_action_just_pressed("ui_up"):
			player.jumpAudio.play()
			player.canDoubleJump = false # this is stopping player from constantly jumping
			player.velocity.y += jumpHeight
