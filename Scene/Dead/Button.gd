extends Button

# Get node
export (NodePath) var button_path
onready var button = get_node(button_path)

func _ready():
	#Create connection
	button.connect("pressed", self, "on_pressed")
	
	#set button name
	button.set_text("Restart")
	
	#set toggle name
	button.set_toggle_mode(true)

	#Disable button
	#button.set_disabled(true)

#On button toggle
func on_toggled(pressed):
	if(pressed):
		print("Hello!")
	else:
		print("Goodbye!")
		
#On button pressed
func on_pressed():
	get_tree().change_scene("res://Title/Title.tscn")
	#print("Game Over")
