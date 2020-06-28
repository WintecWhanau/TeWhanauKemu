extends Control

#player
signal death_screen

#death 
func _on_player_death_screen():
	visible = true




#if health >= 0: 
	queue_free()
	$death.visible = true
