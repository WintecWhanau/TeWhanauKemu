extends KinematicBody2D
class_name Player
export (int) var speed
export (int) var gravity
export (int) var jumpHeight
var direction:int = 1
var velocity := Vector2()
const up = Vector2(0, -1)
var origin_position: Vector2
var stateMachine: PlayerStateMachine
onready var AnimatedSprite = $AnimatedSprite
onready var Label = $Label

func _ready():
	origin_position = global_position
	stateMachine = PlayerStateMachine.new(self)
	stateMachine.set_state_deferred(PlayerStateMachine.IDLE)

func _physics_process(delta):
	stateMachine.process(delta)

func process_movement(delta):
	velocity = move_and_slide(velocity,up)

func process_velocity(delta):
	velocity.y += 20

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
					player.velocity.y += player.jumpHeight
			RUN:
				player.Label.text = 'run'
				_handle_input(delta)
				if Input.is_action_just_pressed("ui_up"):
					player.velocity.y += player.jumpHeight
			JUMP:
				player.Label.text = 'jump'
				_handle_input(delta)
				pass
			FALL:
				player.Label.text = 'fall'
				_handle_input(delta)
				pass
		_sprite_flip()
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
				player.AnimatedSprite.play("idle")
			RUN:
				player.AnimatedSprite.play("run")
			JUMP:
				player.AnimatedSprite.play("jump")
			FALL:
				player.AnimatedSprite.play("fall")

	func _handle_input(delta):
			var direction = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
			player.direction = direction
			player.velocity.x = direction * player.speed
	
	func _sprite_flip():
		if player.direction > 0:
			player.AnimatedSprite.flip_h = false
		elif player.direction < 0:
			player.AnimatedSprite.flip_h = true
