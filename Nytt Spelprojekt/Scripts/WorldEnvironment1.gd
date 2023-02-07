extends WorldEnvironment



var tween_values  = [0.9, 0.3]
var tween = Tween.new()

func _ready() -> void:
	environment.glow_enabled = true
	environment.tonemap_exposure = 0.9

func _enter_tree():
	tween.name = "Tween"
	add_child(tween)    

func start_tween():
	$Tween.interpolate_property(environment, "tonemap_exposure", tween_values[0], tween_values[1], 0.2)
	$Tween.start()

func _on_Player_test() -> void:
	start_tween()
	$TestTimer.start(0.2)

	
func _on_TestTimer_timeout() -> void:
	environment.tonemap_exposure = 0.9
