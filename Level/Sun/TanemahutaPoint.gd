extends Node
class_name Final
var state_machine: FianlLevelStateMachine	
var enemyA = preload('res://Scene/Enemy/Tanemahuta/Tanemahuta Scene.tscn')
var enemyB = preload('res://Scene/Enemy/Ruaumoko/Ruaumoko.tscn')
var enemyC = preload('res://Scene/Enemy/Tangaroa/Tangaroa Scene.tscn')
var enemyD = preload('res://Scene/Enemy/Tumatauenga/Tumatauenga.tscn')
onready var pointA = get_node("Enemy")

onready var pointB = get_node("Enemy2")
onready var pointC = get_node("Enemy3")
onready var pointD = get_node("Enemy4")
onready var enemyArray = [enemyA,enemyB, enemyC, enemyD]
onready var enemySpwan = [pointA,pointB,pointC,pointD]

var screenSize:Vector2
func _ready():
	screenSize = get_viewport().get_visible_rect().size
	state_machine = FianlLevelStateMachine.new(self)
	state_machine.set_state_deferred(FianlLevelStateMachine.IDLE)
	
func _physics_process(delta):
	state_machine.process(delta)


class FianlLevelStateMachine extends StateMachine:
	var F: Final

	var idle_state_duration = 0
	var state_stay = 0

	enum {IDLE,SPWAN}
	func _init(final: Final):
		F = final
		add_state(IDLE)
		add_state(SPWAN)


	func _do_actions(delta):
		match state:
			SPWAN:

				randPoint()
			IDLE:
				if F.pointA.get_child_count()+ F.pointB.get_child_count() + F.pointC.get_child_count() + F.pointD.get_child_count() == 0:
					idle_state_duration += delta
					print(idle_state_duration)

				
	func _check_conditions(delta):
		match state:
			IDLE:

				if F.pointA.get_child_count()+ F.pointB.get_child_count() + F.pointC.get_child_count() + F.pointD.get_child_count() ==0 and idle_state_duration > state_stay:
					return SPWAN
			SPWAN:
				if F.pointA.get_child_count()+ F.pointB.get_child_count() + F.pointC.get_child_count() + F.pointD.get_child_count() > 3:
					return IDLE
				
	func _enter_state(state, old_state):
		match state:
			SPWAN:
				pass
			IDLE:
				state_stay = rand_range(4, 10)



	func _exit_state(state, new_state):
		match state:
			IDLE:
				idle_state_duration = 0


	func randPoint():
		var rand = RandomNumberGenerator.new()
		for i in range(0,1):
			rand.randomize()
			var num = rand.randi_range(0, 3)
			var point = F.enemySpwan[num]
			try(point)

	func try(point:Position2D):
		var rng = RandomNumberGenerator.new()
		rng.randomize()
		var randEnemy = rng.randi_range(0, 3)
		var enemy = F.enemyArray[randEnemy]
		var e = enemy.instance()
		e.set_as_toplevel(true)
		e.position.x = point.position.x
		e.position.y = point.position.y
		point.add_child(e)



