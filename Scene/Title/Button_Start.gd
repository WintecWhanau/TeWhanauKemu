extends Button

func _on_Button_Start_pressed():
# warning-ignore:return_value_discarded
	get_tree().change_scene("res://Level/Forest/ForestLevel.tscn")
