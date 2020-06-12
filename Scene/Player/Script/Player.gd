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
onready var jump_force := jumpForceDefault
onready var friction := frictionGround
onready var max_hp := maxHPDefault
onready var hp := max_hp

var velocity := Vector2(0, 0)
onready var acc := acceleration
var gravity_ratio := 1.0
var direction:int = 1

const up = Vector2(0, -1)
var origin_position: Vector2
var stateMachine: PlayerStateMachine

var jumps = 0

onready var AnimatedSprite = $AnimatedSprite
onready var Label = $Label
onready var JumpTimer = $Timers/JumpTimer

func _ready():
	origin_position = global_position
	stateMachine = PlayerStateMachine.new(self)
	stateMachine.set_state_deferred(PlayerStateMachine.IDLE)

func _physics_process(delta):
	stateMachine.process(delta)

func process_movement(delta):
	velocity = move_and_slide(velocity,up)

func process_velocity(delta):
	if direction != 0:
		velocity.x += direction * acc.x * delta
		acc.x *= acceleration_rate.x
		velocity.x = clamp(velocity.x, -maxSpeed.x, maxSpeed.x)
	else:
		acc.x = acceleration.x
		velocity.x = lerp(velocity.x, 0, friction)
		
	velocity.y += acc.y * gravity_ratio * delta
	velocity.y = clamp(velocity.y, -maxSpeed.y, maxSpeed.y)
	
func _sprite_flip():
		if direction > 0:
			AnimatedSprite.flip_h = false
		elif direction < 0:
			AnimatedSprite.flip_h = true
	
func _on_JumpTimer_timeout():
	pass # Replace with function body.

class PlayerStateMachine extends StateMachine:
	enum {IDLE, RUN, JUMP, FALL, ATTACK}
	var player: Player = null

	func _init(playerLoad: Player):
		player = playerLoad
		add_state(IDLE)
		add_state(RUN)
		add_state(JUMP)
		add_state(FALL)
		add_state(ATTACK)
		

	func _do_actions(delta):
		"""Perform current state behavior"""
		match state:
			IDLE:
				player.Label.text = 'idle'
				_handle_input(delta)
				if Input.is_action_just_pressed("ui_up"):
					player.velocity.y += player.jump_force
			RUN:
				player.Label.text = 'run'
				_handle_input(delta)
				if Input.is_action_just_pressed("ui_up"):
					player.velocity.y += player.jump_force
			JUMP:
				player.Label.text = 'jump'
				_handle_input(delta)
				pass
			FALL:
				player.Label.text = 'fall'
				_handle_input(delta)
				pass
		player._sprite_flip()
		player.process_velocity(delta)
		player.process_movement(delta)
		
	func _check_conditions(delta):
		"""Check the current state transition conditions and return to the state to be transferred to"""
		match state:
			IDLE:
				if player.is_on_floor():
					if player.direction != 0:
						return RUN
				else: 
					return JUMP
			RUN:
				if player.is_on_floor():
					if player.direction == 0:
						return IDLE
				else: 
					return JUMP
			JUMP:
				if player.is_on_floor():
					if player.direction == 0:
						return IDLE
					else:
						return RUN
				elif !player.is_on_floor() && player.velocity.y >= 0:
					return FALL
			FALL:
				if player.is_on_floor():
					if player.direction == 0:
						return IDLE
					else:
						return RUN


	func _enter_state(state, _old_state):
		"""Enter state"""
		match state:
			IDLE:
				player.gravity_ratio = 0.1
				player.friction = player.frictionGround
				player.AnimatedSprite.play("idle")
			RUN:
				player.gravity_ratio = 0.2
				player.friction = player.frictionGround
				player.AnimatedSprite.play("run")
			JUMP:
				player.gravity_ratio = 1.0
				player.friction = player.frictionAir
				if player.velocity.y < 0:
					player.AnimatedSprite.play("jump")
				else:
					player.AnimatedSprite.play("fall")
			FALL:
				player.AnimatedSprite.play("fall")

	func _handle_input(delta):
			var direction = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
			if player.direction != direction:
				player.acc = player.accelerationDefault
			player.direction = direction
