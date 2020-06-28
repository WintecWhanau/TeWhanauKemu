extends Node2D

var platform = preload("res://Scene/TileScenes/Volcano/Tscn/volcano_moving.tscn")

func _ready():
	platform 
	
func _on_Area2D_body_entered(body):
	if body.name != "Player":
		pass
	else:
		var p = platform.instance()
		p.global_position = $Position2D.global_position
		p.move_to.x = 0
		p.move_to.y = -220
		get_parent().get_parent().add_child(p)
		queue_free()
	pass # Replace with function body.
