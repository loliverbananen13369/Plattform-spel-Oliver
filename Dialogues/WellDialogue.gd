extends CanvasLayer

export(String, FILE, "*.json") var d_file

var dialogue = []
var current_dialogue_id = 0
var d_active = false
var rng = RandomNumberGenerator.new()

func _ready():
	$NinePatchRect.visible = false

func _start():
	$NinePatchRect.visible = true
	dialogue = _load_dialogue()
	_set_player_inactive()
	current_dialogue_id = -1
	_next_script()
	

func _load_dialogue():
	var file = File.new()
	if file.file_exists(d_file):
		file.open(d_file, file.READ)
		return parse_json(file.get_as_text())

func _input(event):
	if event.is_action_pressed("ui_accept"):
		pass

func _next_script():
	rng.randomize()
	current_dialogue_id = rng.randi_range(0, 19)
	#if current_dialogue_id >= len(dialogue):
	#	$Timer.start(0.4)
	#	$NinePatchRect.visible = false
	#	_set_player_active()
	#	return
	
	$NinePatchRect/Name.text = dialogue[current_dialogue_id]["name"]
	$NinePatchRect/Chat.text = dialogue[current_dialogue_id]["text"]
	

func _stop_dialogue():
	#$Timer.start(0.4)
	$NinePatchRect.visible = false
	_set_player_active()

func _on_Timer_timeout():
	d_active = false

func _set_player_active():
	var player = PlayerStats.player
	if player:
		player.set_active(true)

func _set_player_inactive():
	var player = PlayerStats.player
	if player:
		player.set_active(false)
