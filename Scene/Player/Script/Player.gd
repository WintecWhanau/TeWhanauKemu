#func _physics_process(delta):
#	motion.y += gravity
#
#	if Input.is_action_pressed("ui_right"):
#		$AnimatedSprite.play("run")
#		$AnimatedSprite.flip_h = false
#		motion.x = speed
#	elif Input.is_action_pressed("ui_left"):
#		$AnimatedSprite.play("run")
#		$AnimatedSprite.flip_h = true
#		motion.x = -speed
#	else:
#		$AnimatedSprite.play("idle")
#		motion.x = 0
#
#	if is_on_floor():
#		if Input.is_action_pressed("ui_up"):
#			motion.y = jumpHeight
#	else:
#		$AnimatedSprite.play('jump')
#		pass
#
#	motion = move_and_slide(motion, up)
##end of _physics_process

extends KinematicBody2D
class_name Player
export (int) var speed
export (int) var gravity
export (int) var jumpHeight
var motion = Vector2() # moving in 2d space
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
	_fixed_process(delta)

func process_movement(delta):
	velocity = move_and_slide(velocity,up)

func process_velocity(delta):
	"""Apply gravity"""
	velocity.y += 20

func _fixed_process(delta):
	if Input.is_action_just_pressed("ui_right"):
		AnimatedSprite.flip_h = false
		direction = 1
		velocity.x = speed * direction
	elif Input.is_action_just_pressed("ui_left"):
		AnimatedSprite.flip_h = true
		direction = -1
		velocity.x = speed * direction
		
	if is_on_floor():
		if Input.is_action_just_pressed("ui_up"):
			velocity.y = jumpHeight

class PlayerStateMachine extends StateMachine:
	enum {IDLE, RUN, ATTACK, JUMP, FALL}
	var player: Player

	func _init(playerLoad: Player):
		player = playerLoad
		add_state(IDLE)
		add_state(RUN)
		add_state(ATTACK)
		add_state(JUMP)
		add_state(FALL)
		

	func _do_actions(delta):
		"""Perform current state behavior"""
		match state:
			IDLE:
				player.Label.text = 'idle'
				pass
			RUN:
				player.Label.text = 'run'
				pass
			JUMP:
				player.Label.text = 'jump'
				pass
			FALL:
				player.Label.text = 'fall'
				pass
#		player._fixed_process(delta)
		player.process_velocity(delta)
		player.process_movement(delta)
		
	func _check_conditions(delta):
		"""Check the current state transition conditions and return to the state to be transferred to"""
		match state:
			IDLE:
				if !player.is_on_floor():
					if player.velocity.y < 0:
						return JUMP
					if player.velocity.y > 0:
						return FALL
				elif player.velocity.x != 0:
					return RUN
			RUN:
				if !player.is_on_floor():
					if player.velocity.y < 0:
						return JUMP
					if player.velocity.y > 0:
						return FALL
				elif player.velocity.x == 0:
					return IDLE
			JUMP:
				if player.is_on_floor():
					return IDLE
				elif player.velocity.y >= 0:
					return FALL
			FALL:
				if player.is_on_floor():
					return IDLE
				elif player.velocity.y < 0:
					return JUMP


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


	func _exit_state(state, _new_state):
		match state:
#			IDLE:
#				pass
#			RUN:
#				pass
			JUMP:
				player.is_on_floor()
				pass
