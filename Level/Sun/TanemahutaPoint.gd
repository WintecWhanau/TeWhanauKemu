extends Node
class_name Final
var state_machine: FianlLevelStateMachine	
var enemyA = preload('res://Scene/Enemy/Tanemahuta/Tanemahuta Scene.tscn')
var enemyB = preload('res://Scene/Enemy/Ruaumoko/Ruaumoko.tscn')
var enemyC = preload('res://Scene/Enemy/Tangaroa/Tangaroa Scene.tscn')
var enemyD = preload('res://Scene/Enemy/Tumatauenga/Tumatauenga.tscn')
onready var pointA = get_node("Enemy")
#onready var pointB = get_node("Enemy2")
#onready var pointC = get_node("Enemy3")
#onready var pointD = get_node("Enemy4")
onready var enemyArray = [enemyA,enemyB, enemyC, enemyD]
#onready var enemySpwan = [pointA,pointB,pointC,pointD]
var screenSize:Vector2
func _ready():
	screenSize = get_viewport().get_visible_rect().size
	state_machine = FianlLevelStateMachine.new(self)
	state_machine.set_state_deferred(FianlLevelStateMachine.IDLE)
	
func _physics_process(delta):
	state_machine.process(delta)


class FianlLevelStateMachine extends StateMachine:
	var F: Final
	
	
	enum {IDLE,SPWAN}
	func _init(final: Final):
		F = final
		add_state(IDLE)
		add_state(SPWAN)


	func _do_actions(delta):
		match state:
			SPWAN:
				try()
			IDLE:
				pass
				
	func _check_conditions(delta):
		match state:
			IDLE:
				if F.pointA.get_child_count() ==0 :
					return SPWAN
			SPWAN:
				if F.pointA.get_child_count() > 1:
					return IDLE
				
	func _enter_state(state, old_state):
		pass


	func _exit_state(state, new_state):
		pass



	func try():
		var rand = RandomNumberGenerator.new()
		var rng = RandomNumberGenerator.new()
		for i in range(0,1):
			rng.randomize()
			var randEnemy = rng.randi_range(0, 3)
			var enemy = F.enemyArray[randEnemy]
			var e = enemy.instance()
			e.set_as_toplevel(true)
			rand.randomize()
			var x = rand.randf_range(0,F.screenSize.x)
			rand.randomize()
			var y = rand.randf_range(0,F.screenSize.y)
			e.position.x = x
			e.position.y = y
			F.pointA.add_child(e)


