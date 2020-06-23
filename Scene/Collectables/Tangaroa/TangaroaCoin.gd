extends Area2D

onready var coinSpin: AnimatedSprite = get_node("AnimatedSprite")

func _process(_delta):
	coinSpin.play("spin")

func _on_TangaroaCoin_body_entered(body):
	if body.name == "Player":
#		MainHUD.score += 10
		queue_free()
