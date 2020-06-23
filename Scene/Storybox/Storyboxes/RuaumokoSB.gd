extends Panel

export (String, FILE, "*.txt") var story_line_file

onready var chatNode = get_node("Chat")
onready var nextNode = get_node("Next") # to skip to next line

# Called when the node enters the scene tree for the first time.
func _ready():
	chatNode._loadDialogFromFile(story_line_file)
	pass # Replace with function body.
