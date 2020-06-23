extends NinePatchRect

func _on_collectables_coins_changed(count):
	$Number.text = str(count)
