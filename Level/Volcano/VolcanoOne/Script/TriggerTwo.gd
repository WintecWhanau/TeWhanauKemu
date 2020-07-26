extends Area2D
#onready var wall = get_tree().get_root().get_child(0).get_node("Wall")

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Area2D2_body_entered(body):
	$WallTwo.queue_free()
	queue_free()
	pass # Replace with function body.
