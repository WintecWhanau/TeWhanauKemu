extends Node

func _ready():
	var player = $Player
	var playerHealth = $Player/Health
	var healthBar =  $HUD/HealthBar_Maui

	playerHealth.connect("changed", healthBar, "set_value")
	playerHealth.connect("depleted", player, "dead")
