extends Node
onready var pointOne = $TanemahutaPoint
onready var boss = get_node("Path2D/PathFollow2D/Te Ra")

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var enemyA = preload('res://Scene/Enemy/Tanemahuta/Tanemahuta Scene.tscn')
var enemyB = preload('res://Scene/Enemy/Ruaumoko/Ruaumoko.tscn')
var enemyC = preload('res://Scene/Enemy/Tangaroa/Tangaroa Scene.tscn')
var enemyD = preload('res://Scene/Enemy/Tumatauenga/Tumatauenga.tscn')

func _process(delta):
	#print(boss.get_global_position().y,'-',pointOne.get_global_position().y)
#	print(boss.get_global_position().y)
#	if  boss.global_position.y > pointOne.position.y:
#		print("hello")
		if $Enemy.get_child_count()+$Enemy2.get_child_count()+$Enemy3.get_child_count() + $Enemy4.get_child_count() < 4:
			print($Enemy.get_child_count())
			try()



# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
func try():
	var a = enemyA.instance()
	$Enemy4.add_child(a)
	var b = enemyB.instance()
	$Enemy3.add_child(b)
	var c = enemyC.instance()
	$Enemy.add_child(c)
	var d = enemyD.instance()
	$Enemy2.add_child(d)


