extends WorldEnvironment



var tween_values  = [0.9, 0.3]
onready var tween = $Tween
onready var animp = $AnimationPlayer

var hejsan 

signal Darken(length)

func _ready() -> void:
	connect("Darken", self, "_on_darken")
	environment.glow_enabled = true
	environment.tonemap_exposure = 0.9

func frameFreeze(timescale, duration):
	Engine.time_scale = timescale
	yield(get_tree().create_timer(duration * timescale), "timeout")
	Engine.time_scale = 1

func start_tween(value: Array, time: float):
	tween.interpolate_property(environment, "tonemap_exposure", value[0], value[1], time)
	tween.start()

func new_skill_animation() -> void:
	animp.play("NewSkill")

func _on_darken(type: String) -> void:
	var length = 0.5
	if type == "Prepare":
		tween_values = [10, 0.9]
		start_tween(tween_values, length)
	if type == "Combo3":
		tween_values = [2.0, 0.9]
		start_tween(tween_values, length)
	if type == "lvl_up":
		tween_values = [2.0, 0.9]
		start_tween(tween_values, length)


	
func _on_TestTimer_timeout() -> void:
	environment.tonemap_exposure = 0.9


func _on_Tween_tween_all_completed() -> void:
	environment.tonemap_exposure = 0.9
