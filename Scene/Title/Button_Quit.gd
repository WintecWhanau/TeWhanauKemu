extends Button

func _on_Button_Quit_button_up():
	get_tree().quit()

func _on_Button_Menu_pressed():
	get_tree().change_scene("res://Scene/Title/Title.tscn")
