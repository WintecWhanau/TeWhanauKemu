extends KinematicBody2D
class_name Tanemahuta

export var max_speed_normal:int = 100 
export var max_speed_attack:int = 120
export var damage:int = 1
export var hp:int = 0
var direction:int = 1
var max_speed = max_speed_normal
var velocity := Vector2()
var origin_position: Vector2
var target: Vector2	# 目标
var player: Player	# Players in the secen
var state_machine: TanemahutaStateMachine	# 状态机

onready var GroundCheckLeft = $GroundCheckLeft
onready var GroundCheckRight = $GroundCheckRight
onready var WallCheckLeft = $WallCheckLeft
onready var WallCheckRight = $WallCheckRight
onready var AnimatedSprite = $AnimatedSprite

const TARGET_DIST = 0
const UP = Vector2(0, -1)

func _ready():
	origin_position = global_position
	state_machine = TanemahutaStateMachine.new(self)
	state_machine.set_state_deferred(TanemahutaStateMachine.IDLE)
	
func _physics_process(delta):
	state_machine.process(delta)
	print(direction)
	
func process_movement(delta):
	velocity = move_and_slide(velocity,Vector2.UP)

func process_velocity(delta):
	"""Apply gravity"""
	velocity.y += 20
	
func _on_HitBox_body_entered(body):
	#AnimatedSprite.play("Slashing")
	if body.has_method("take_damage"):
		WallCheckLeft.enabled = false
		WallCheckRight.enabled = false
		body.take_damage(damage) #what to do?
		AnimatedSprite.play("Slashing")
		
func _on_HitBox_body_exited(body):
	if body.has_method("take_damage"):
		WallCheckLeft.enabled = true
		WallCheckRight.enabled = true
		state_machine.set_state(TanemahutaStateMachine.CHASE)

func _on_DetectingBox_body_entered(body):
	"""Player enters the perception area"""
	if body is Player:
		player = body
		target = body.global_position
		state_machine.set_state(TanemahutaStateMachine.CHASE)
		
func _on_DetectingBox_body_exited(body):
	"""Player exits the perception area"""
	if body is Player:
		state_machine.set_state(TanemahutaStateMachine.WALK)
		
func _check_direction():
	"""Determine the current direction"""
	if GroundCheckLeft.is_colliding() or WallCheckLeft.is_colliding():
		return -1
	elif GroundCheckRight.is_colliding() or WallCheckRight.is_colliding():
		return 1
	else:
		return direction
		
func control_ray_cast(condition:bool):
	GroundCheckLeft.enabled = condition
	GroundCheckRight.enabled = condition

func take_damge(damage):
	hp -= damage
	if hp > 0:
		pass
	else:
		state_machine.set_state(TanemahutaStateMachine.DEAD)
				
class TanemahutaStateMachine extends StateMachine:
	enum {IDLE,WALK,ATTACK,DEAD,CHASE,JUMP}
	var enemy: Tanemahuta
	var idle_state_duration = 0
	var walk_state_duration = 0
	var state_stay = 0

	func _init(tanemahuta: Tanemahuta):
		enemy = tanemahuta
		add_state(IDLE)
		add_state(WALK)
		add_state(DEAD)
		add_state(ATTACK)
		add_state(CHASE)
		add_state(JUMP)

	func _do_actions(delta):
		match state:
			IDLE:
				idle_state_duration += delta
				enemy.velocity.y += 20
			WALK:
				enemy.direction = enemy._check_direction()
				if enemy.direction > 0:
					enemy.AnimatedSprite.flip_h = false
				elif enemy.direction < 0:
					enemy.AnimatedSprite.flip_h = true
				walk_state_duration += delta
				enemy.velocity.x = enemy.max_speed * enemy.direction
			CHASE:
				if enemy.player.position.x < enemy.position.x:
					enemy.AnimatedSprite.flip_h = true
					enemy.direction = -1
				elif enemy.player.position.x > enemy.position.x:
					enemy.AnimatedSprite.flip_h = false
					enemy.direction = 1
				
				enemy.velocity.x = enemy.max_speed * enemy.direction
				
				
			JUMP:
				enemy.velocity.x = enemy.max_speed * enemy.direction
				
			DEAD:
				enemy.direction = 0
				
		enemy.process_velocity(delta)
		enemy.process_movement(delta)
		
	func _check_conditions(delta):
		match state:
			IDLE:
				if enemy.is_on_floor():
					if idle_state_duration > state_stay:
						return WALK
			WALK:
				if walk_state_duration > state_stay: #or enemy.direction != enemy._check_direction() :
					return IDLE
			CHASE:
				print(enemy.player.position.x,"-",enemy.position.x)
				if enemy.player.position.y < enemy.position.y -32 and enemy.is_on_floor():
					return JUMP
				elif enemy.WallCheckLeft.is_colliding() or enemy.WallCheckRight.is_colliding():
					return JUMP
			JUMP:
				if enemy.is_on_floor():
					return CHASE


	func _enter_state(state, old_state):
		"""Enter state"""
		match state:
			IDLE:
				# 静止状态，随机持续时间
				enemy.AnimatedSprite.play("Idle")
				enemy.velocity = Vector2.ZERO
				state_stay = rand_range(1, 4)
			WALK:
				enemy.control_ray_cast(true)
				# 移动状态，在活动范围内移动
				enemy.max_speed = enemy.max_speed_normal
				enemy.AnimatedSprite.play("Walking")
				state_stay = rand_range(1, 5)
			CHASE:
				enemy.control_ray_cast(false)
				enemy.AnimatedSprite.play("Walking")
				enemy.max_speed = enemy.max_speed_attack
			JUMP:
				enemy.velocity.y = -700
				enemy.AnimatedSprite.play("Jump")
			DEAD:
				enemy.AnimatedSprite.play("Dying")

	func _exit_state(state, new_state):
		match state:
			IDLE:
				idle_state_duration = 0
				enemy.direction *= -1
				state_stay = 0
			WALK:
				walk_state_duration = 0
				state_stay = 0
			CHASE:
				pass
			JUMP:
				pass
