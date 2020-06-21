extends Area2D
class_name Patu

onready var speed = 300
onready var damage = 25
onready var lifetime = 0.2
var direction = 1
var comeBack = false
var velocity = Vector2()

var stateMachine = PatuStateMachine

func _ready():
	$Timers/ReturnTimer.wait_time = lifetime
	stateMachine = PatuStateMachine.new(self)
	stateMachine.set_state_deferred(PatuStateMachine.SHOOT)
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

func _on_Patu_body_entered(body):
	if body.has_method('takeDamage'):
		body.takeDamage(damage)
		queue_free()
	else:
		queue_free()
# end of _on_Area2D_body_entered

func _on_ReturnTimer_timeout():
	comeBack = true
	direction *= -1
#	queue_free()
	pass # Replace with function body.

class PatuStateMachine extends StateMachine:
	enum {SHOOT, COMEBACK}
	var patu: Patu = null

	func _init(patuLoad: Patu):
		patu = patuLoad
		add_state(SHOOT)
		add_state(COMEBACK)
	
	func _do_actions(delta):
		"""Perform current state behavior"""
		match state:
			SHOOT:
				print('shoot')
				pass
			COMEBACK:
				print('comeback')
				pass
		
	
	func _check_conditions(delta):
		"""Check the current state transition conditions and return to the state to be transferred to"""
		match state:
			SHOOT:
				if patu.comeBack:
					return COMEBACK
				pass
	
	
	func _enter_state(state, _old_state):
		"""Enter state"""
		match state:
			SHOOT:
				pass
			COMEBACK:
#				patu.setDirection(patu.direction * -1)
				pass
