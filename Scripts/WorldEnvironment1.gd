extends WorldEnvironment



var tween_values  = [0.9, 0.3]
var tween = Tween.new()
var hejsan 

func _ready() -> void:
	environment.glow_enabled = true
	environment.tonemap_exposure = 0.9

func _enter_tree():
	tween.name = "Tween"
	add_child(tween)    

func start_tween():
	$Tween.interpolate_property(environment, "tonemap_exposure", tween_values[0], tween_values[1], hejsan)
	$Tween.start()

func _on_Player_test(length) -> void:
	hejsan = length
	if length == 0.3:
		tween_values = [1.2, 0.9]
	elif length == 0.2:
		tween_values = [0.9, 0.3]
	elif length == 0.15:
		tween_values = [0.9, 0.3]
	else:
		tween_values = [2, 0.9]
	start_tween()
	$TestTimer.start(hejsan)

	
func _on_TestTimer_timeout() -> void:
	environment.tonemap_exposure = 0.9

""" #Ngl ascoolt
func _on_Player_test(length) -> void:
	hejsan = length
	if length == 0.3:
		tween_values = [10, 0.9]
		Engine.time_scale = 0.1
		yield(get_tree().create_timer(0.3), "timeout")
		Engine.time_scale = 1
	else:
		tween_values = [0.9, 0.3]
	start_tween()
	$TestTimer.start(hejsan)
"""
