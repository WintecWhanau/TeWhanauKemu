extends Area2D

onready var coinSpin: AnimatedSprite = get_node("AnimatedSprite")

func _process(_delta):
	coinSpin.play("spin")

func _on_RuaumokoCoin_body_entered(body):
	if body.name == "Player":
	#	MainHUD.score += 10
		$Collect.play()

func _on_Collect_finished():
	queue_free()
