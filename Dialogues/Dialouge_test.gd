extends CanvasLayer

export(String, FILE, "*.json") var d_file

var dialogue = []
var current_dialogue_id = 0
var d_active = false

onready var animp = $AnimationPlayer

signal active(active)

func _ready():
	$NinePatchRect.visible = false

func _start(): #Startar en ny dialog om inte dialogen redan är aktiv
	if d_active:
		return
	d_active = true
	$NinePatchRect.visible = true
	dialogue = _load_dialogue()
	_set_player_inactive()
	current_dialogue_id = -1
	_next_script()
	emit_signal("active", true)
	

func _load_dialogue(): #Konverterar dialogen från en json fil till en "sträng"
	var file = File.new()
	if file.file_exists(d_file):
		file.open(d_file, file.READ)
		return parse_json(file.get_as_text())

func _input(event):
	if not d_active:
		return
	if event.is_action_pressed("ui_accept"):
		_next_script()

func _auto_input():
	_next_script()

func _next_script(): #Nästa index 
	current_dialogue_id += 1
	
	if current_dialogue_id >= len(dialogue):
		$Timer.start(0.4)
		$NinePatchRect.visible = false
		_set_player_active()
		emit_signal("active", false)
		return
	$NinePatchRect/Chat.percent_visible = 0
	$NinePatchRect/Name.text = dialogue[current_dialogue_id]["name"] #Ger värde på noden Name
	$NinePatchRect/Chat.text = dialogue[current_dialogue_id]["text"] #Ger värde på noden Chat
	animp.play("Ny Anim")

func _on_Timer_timeout():
	d_active = false

func _set_player_active():
	var player = PlayerStats.player
	if is_instance_valid(player):
		#player.set_active(true)
		player.set_process_unhandled_input(true)
		

func _set_player_inactive():
	var player = PlayerStats.player
	if is_instance_valid(player):
		#player.set_active(false)
		player.set_process_unhandled_input(true)
