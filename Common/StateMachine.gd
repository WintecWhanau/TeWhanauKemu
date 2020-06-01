extends Node
class_name StateMachine

var states := []	# An array containing all states
var state: int	# Current status
var previous_state: int	# Previous state

func process(delta):
	"""State machine logic, expected to execute every frame"""
	if state != null:
		# Perform current state behavior
		_do_actions(delta)
		# Check if the condition of transition is met
		var new_state = _check_conditions(delta)
		if new_state != null:
			set_state(new_state)

func _do_actions(delta):
	"""Perform current state behavior"""
	pass

func _check_conditions(delta):
	"""Check the current state transition conditions and return to the state to be transferred to"""
	pass
	
func _enter_state(state, old_state):
	"""Enter state"""
	pass

func _exit_state(state, new_state):
	"""Exit status"""
	pass

func set_state(new_state):
	"""Set current status"""
	if states.has(new_state):
		previous_state = state
		state = states[new_state]
		if previous_state != null:
			_exit_state(previous_state, state)
		if state != null:
			_enter_state(state, previous_state)

func set_state_deferred(new_state):
	"""Set the delayed call wrapper for the current state"""
	call_deferred("set_state", new_state)

func add_state(new_state):
	"""New status"""
	states.append(new_state)