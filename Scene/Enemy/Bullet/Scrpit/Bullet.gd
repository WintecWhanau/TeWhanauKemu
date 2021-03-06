extends Area2D
export var speed:int = 220
export var damage:int = 1
var velocity = Vector2()
var direction = 1

# Called when the node enters the scene tree for the first time.
func _ready():
	print(get_parent().name)

func set_bullet_direction(dir):
	direction = dir
	if dir == -1:
		$Animated.flip_h = true
func _physics_process(delta):
	velocity.x = speed * delta * direction
	translate(velocity)
	$Animated.play('Fly')

	
func _on_VisibilityNotifier2D_screen_exited():
	queue_free()



func _on_Bullet_body_entered(body):
	if body.has_method('take_damage'):
		body.take_damage(damage)
		queue_free()
	print('hit')
