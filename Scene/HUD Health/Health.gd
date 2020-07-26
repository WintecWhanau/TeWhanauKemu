extends Node

signal changed(new_amount)
signal depleted

export(int) var max_amount = 100
export (int) var current = 100 setget set_current

func _ready():
	initialize()

func set_current(new_value):
	current = new_value
	current = clamp(current, 0, max_amount)
	emit_signal("changed", current)
	
	if current == 0:
		emit_signal("depleted")

func initialize():
	emit_signal("changed", current)

#func set_value(new_amount):
#	pass # Replace with function body.
