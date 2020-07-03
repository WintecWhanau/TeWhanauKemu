extends Button

func _on_Button_Start_pressed():
	get_tree().change_scene("res://Scene/Chief Scene/ChiefScene.tscn")

func _on_Button_Controls_pressed():
	get_tree().change_scene("res://Scene/Keyboard Controls/Keyboard Controls.tscn")


