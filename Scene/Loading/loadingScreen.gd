extends Control

func update_percent(new_percent):
	$LoadingTween.interpolate_property($LoadingBar, "value", $LoadingBar.value, new_percent, 0.5, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$LoadingTween.start()

	yield($LoadingTween, "tween_completed")
	
	
	
	
	
