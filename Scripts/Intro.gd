extends CanvasLayer


"""
Ja inget speciellt. Väldigt "dålig kod", men det funkar. Det är bara ett intro ändå så
"""


const NEW_AUDIO = "res://Intro/sunrise-114326.mp3"
onready var tween = $Tween
onready var timer_t = $TimerTween
onready var animp = $AnimationPlayer
onready var timer = $SkipTimer

var timer_tween_values = [0, 1]

var can_skip = false
# Called when the node enters the scene tree for the first time.
func _ready():
	$TimerLayer/Label.modulate.a = 0
	$ColorRect.visible = false
	$CanvasLayer2.visible = false
	#yield(get_tree().create_timer(0.1), "timeout")
	yield(get_tree().create_timer(0.1), "timeout")
	animp.play("Fade in")
	yield(animp, "animation_finished")
	yield(get_tree().create_timer(2), "timeout")
	$ColorRect.visible = true
	$CanvasLayer2.visible = true
	#$AudioStreamPlayer.stream = NEW_AUDIO
	yield(get_tree().create_timer(0.05), "timeout")
	animp.play("NameAnim")
	yield(animp, "animation_finished")
	yield(get_tree().create_timer(1), "timeout")
	get_tree().change_scene("res://Levels/CityHall.tscn")
	
	#pass
func _fade_tween(value: Array) -> void:
	tween.interpolate_property($CanvasLayer/ColorRect2, "modulate:a", value[0], value[1], 0.5)
	tween.start()
	yield(tween, "tween_completed")
	value.invert()
	tween.interpolate_property($CanvasLayer/ColorRect2, "modulate:a", value[0], value[1], 0.5)
	tween.start()
	value.invert()

func _mod_tween(value: Array) -> void:
	tween.interpolate_property($BananaGaming/LOGO, "modulate:a", value[1], value[0], 0.5)
	tween.start()

func _timer_tween() -> void:
	timer_t.interpolate_property($TimerLayer/Label, "modulate:a", timer_tween_values[0], timer_tween_values[1], 1.0)
	timer_t.start()

func _skip_pressed_tween() -> void:
	timer_t.stop(timer_t)
	var current_mod = $TimerLayer/Label.modulate.a
	var current_vol = $AudioStreamPlayer.volume_db
	timer_t.interpolate_property($TimerLayer/Label, "modulate:a", current_mod, 0, 0.6)
	#timer_t.interpolate_property($AudioStreamPlayer, "volume: ")
	timer_t.interpolate_property($AudioStreamPlayer, "volume_db", current_vol, -30, 0.6)


func _skip() -> void:
	if animp.current_animation == "Fade in":
		var tween_values = [0, 1]
		_fade_tween(tween_values)
		_mod_tween(tween_values)
		animp.stop(true)
		#$BananaGaming/LOGO.visible = false
		yield(get_tree().create_timer(1.5), "timeout")
		animp.play("NameAnim")
	if animp.current_animation == "NameAnim":
		var tween_values = [0, 1]
		_fade_tween(tween_values)
		animp.stop(true)
		get_tree().change_scene("res://Levels/CityHall.tscn")
	

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("ui_accept") and can_skip:
		_skip()
		_skip_pressed_tween()
		can_skip = false
		


func _on_SkipTimer_timeout() -> void:
	timer_t.stop(timer_t)
	can_skip = true
	$TimerLayer/Label.visible = false
	_timer_tween()

func _on_Timer_timeout() -> void:
	pass
	#_timer_tween()


func _on_TimerTween_tween_completed(object: Object, key: NodePath) -> void:
	if can_skip:
		timer_tween_values.invert()
		_timer_tween()
