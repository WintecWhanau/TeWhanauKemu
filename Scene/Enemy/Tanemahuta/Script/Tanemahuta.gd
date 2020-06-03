extends KinematicBody2D
class_name Tanemahuta

export var max_speed_normal:int = 100 
export var max_speed_attack:int = 120
var direction:int = 1
var max_speed = max_speed_normal
var velocity := Vector2()
var origin_position: Vector2	# 初始位置
var active_range := Vector2(500, 50)	# 活动范围x,y
var target: Vector2	# 目标
var player: Player	# 处于检测范围内的玩家
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
	"""计算速度"""
	velocity.y += 20
	


func _on_HitBox_body_entered(body):
	#AnimatedSprite.play("Slashing")
	if body.has_method("take_damage"):
		body.take_damage(-1) #what to do?
		pass

func _on_DetectingBox_body_entered(body):
	"""玩家进入感知区域"""
	if body is Player:
		player = body
		target = body.global_position
		state_machine.set_state(TanemahutaStateMachine.CHASE)
		
func _on_DetectingBox_body_exited(body):
	"""玩家退出感知区域"""
	if body is Player:
		state_machine.set_state(TanemahutaStateMachine.IDLE)
		
func _check_direction():
	"""判断当前前进方向"""
	if GroundCheckLeft.is_colliding() or WallCheckLeft.is_colliding():
		return -1
	elif GroundCheckRight.is_colliding() or WallCheckRight.is_colliding():
		return 1
	else:
		return direction
		
func control_ray_cast(condition:bool):
	GroundCheckLeft.enabled = condition
	GroundCheckRight.enabled = condition
	WallCheckLeft.enabled = condition
	WallCheckRight.enabled = condition
				
class TanemahutaStateMachine extends StateMachine:
	enum {IDLE, WALK, ATTACK, DEAD, CHASE, JUMP}
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
				if enemy.player.position.x < enemy.position.x and enemy.position.y >= -40:
					enemy.AnimatedSprite.flip_h = true
					enemy.direction = -1
				elif enemy.player.position.x > enemy.position.x and enemy.position.y >= -40:
					enemy.AnimatedSprite.flip_h = false
					enemy.direction = 1
				
				enemy.velocity.x = enemy.max_speed * enemy.direction
				
				
			JUMP:
				enemy.velocity.x = enemy.max_speed * enemy.direction
				
		enemy.process_velocity(delta)
		enemy.process_movement(delta)
		
	func _check_conditions(delta):
		match state:
			IDLE:
				if enemy.is_on_floor():
					if idle_state_duration > state_stay:
						return WALK
				else:
					return JUMP
			WALK:
				
				if walk_state_duration > state_stay: #or enemy.direction != enemy._check_direction() :
					return IDLE
			CHASE:
				print(enemy.player.position.x,"-",enemy.position.x)
				if enemy.player.position.y < enemy.position.y -32 and enemy.is_on_floor():
					return JUMP
			JUMP:
				if enemy.is_on_floor():
					return CHASE


	func _enter_state(state, old_state):
		"""进入状态"""
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
