extends KinematicBody2D
class_name Boss
onready var path_follow = get_parent()
export var speed:int = 150
var move_directiom = 0


# Called when the node enters the scene tree for the first time.
func _physics_process(delta):
	MovementLoop(delta) # Replace with function body.


func MovementLoop(delta):
	var prepos = path_follow.get_global_position()
	path_follow.set_offset(path_follow.get_offset() + speed * delta)
	var pos = path_follow.get_global_position()
	move_directiom = (pos.angle_to_point(prepos)/3.14)*180

