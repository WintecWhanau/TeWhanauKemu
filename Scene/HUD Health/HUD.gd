extends CanvasLayer

signal coins_changed(count)

func _on_collectables_coins_changed(count):
	emit_signal("coins_changed", count)
