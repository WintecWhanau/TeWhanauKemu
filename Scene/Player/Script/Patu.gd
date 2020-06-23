extends Area2D
class_name Patu

onready var speed = 300
onready var damage = 25
onready var lifetime = 0.5
var direction = 1
var comeBack = false
var velocity = Vector2()
var stateMachine = PatuStateMachine
var level
onready var AnimatedSprite = $AnimatedSprite
signal caught

func _ready():
	$Timers/ReturnTimer.wait_time = lifetime
	stateMachine = PatuStateMachine.new(self)
	stateMachine.set_state_deferred(PatuStateMachine.DEFAULT)
	pass
	
func _on_ReturnTimer_ready():
	$Timers/ReturnTimer.start()
	pass # Replace with function body.

func setDirection(dir):
	direction = dir
	if dir == -1:
		$AnimatedSprite.flip_v = true

func _physics_process(delta):
	velocity.x = speed * delta * direction
	translate(velocity)
# end of _physics_process

func setLevel(lvl):
	level = lvl

func _on_Patu_body_entered(body):
	if !comeBack:# initial shot
		if !body.name == 'Player' && body.has_method('takeDamage'):
			body.takeDamage(damage)
		elif body.name == 'Player':
			queue_free()
		triggerComeBack()
	else:# patu returning
		if !body.name == 'Player' && body.has_method('takeDamage'):
			body.takeDamage(damage)
			print(body.name)
		elif body.name == 'Player':
			queue_free()
			emit_signal("caught")
		else:
			print(body.name)
			queue_free()
# end of _on_Area2D_body_entered

func _on_ReturnTimer_timeout():
	if !comeBack:
		triggerComeBack()
# end of _on_ReturnTimer_timeout

func triggerComeBack():
	comeBack = true
	direction *= -1
	$Timers/ReturnTimer.wait_time = lifetime
	$Timers/ReturnTimer.start()
	if direction == -1:
		$AnimatedSprite.flip_v = true
	else:
		$AnimatedSprite.flip_v = false
# end of triggerComeBack

class PatuStateMachine extends StateMachine:
	enum {DEFAULT, TERA}
	var patu: Patu = null

	func _init(patuLoad: Patu):
		patu = patuLoad
		add_state(DEFAULT)
		add_state(TERA)

	func _do_actions(delta):
		"""Perform current state behavior"""
		match state:
			DEFAULT:
				print('default')
				pass
		patu.setLevel(patu.level)

	func _check_conditions(delta):
		"""Check the current state transition conditions and return to the state to be transferred to"""
		match state:
			DEFAULT:
				if patu.level == 4:
					return TERA

	func _enter_state(state, _old_state):
		"""Enter state"""
		match state:
			DEFAULT:
				patu.AnimatedSprite.play("default")
			TERA:
				patu.AnimatedSprite.play("tera")
