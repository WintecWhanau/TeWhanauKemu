extends Node2D

func _on_Area2D_body_entered(body):
	if body.name != "Player":
		pass
	else:
		body.take_damage(100)
	pass # Replace with function body.
