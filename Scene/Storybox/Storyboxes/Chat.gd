extends Label

var drawTextSpeed: int = 0
var chatterLimit: int = 200 # max characters in chatbox
var dialog = [] # list of story lines
var oneLine = ""
var page = 0
var font = get("custom_fonts/font")

func _loadDialogFromFile(fname):
	
	var f = File.new()
	f.open(fname, File.READ)
# warning-ignore:unused_variable
	var index = 1
	while not f.eof_reached():
		var line = f.get_line()
		dialog.append(line)
		index+=1
	f.close()
	
	# initialise first line of chat and set the chat box text
	set_text(dialog[page])
	pass

func _ready():
	pass # Replace with function body.

# Print story line by line
func _showChatter():
	if drawTextSpeed < chatterLimit: # print 1 char at a time
		drawTextSpeed += 1
		self.visible_characters = drawTextSpeed
	pass

# warning-ignore:unused_argument
func _process(delta):
	_showChatter()
	pass

func _on_Next_pressed():
	if page < dialog.size()-1:
		page += 1
		set_text(dialog[page])
	else:
		page = 0
		set_text(dialog[page])
	
	# reset chatter box method to show new chat line
	drawTextSpeed = 0
	_showChatter()
	pass # Replace with function body.

# Print the whole script
func _on_ShowAll_pressed():
	chatterLimit = dialog[page].length()
	oneLine = ""
	page = 0

	while page < dialog.size()-1:
		oneLine += dialog[page]+"\n" 
		page += 1
		chatterLimit += dialog[page].length()
	
	set_text(oneLine + dialog[page])
	pass # Replace with function body.


func _on_NextLevel_pressed():
	get_tree().change_scene(get_parent().next_level)
	pass # Replace with function body.
