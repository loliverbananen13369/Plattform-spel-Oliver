extends CanvasLayer

export (String, FILE, "*.json") var d_file
export (String) var person

var dialogue = []
var current_dialogue_id = 0
var d_active = false
var first_time_done = true

var talk_quest_current = false

onready var animp = $AnimationPlayer

signal active(active)
signal dialogue_done(nr)

#Quest Signaler
signal choose_class()
signal talk_to_bs()

func _ready():
	Quests.get_node(str(person)).connect("talk_quest_started", self, "_on_talk_quest_started")
	Quests.get_node(str(person)).connect("change_d_file", self, "_on_d_file_changed")
	$NinePatchRect.visible = false
	if Quests.get_node(str(person)).has_node("TalkQuest"):
		if person == Quests.get_node(str(person)).get_node("TalkQuest").goal:
			talk_quest_current = true

func _start():
	if d_active:
		return
	d_active = true
	$NinePatchRect.visible = true
	_set_player_inactive()
	current_dialogue_id = -1
	_next_script()
	emit_signal("active", true)


func _load_dialogue(file):
	var dia = File.new()
	if dia.file_exists(file):
		dia.open(file, dia.READ)
		return parse_json(dia.get_as_text())

func _new_d_file(d_list):
	var index = Quests.dialogue_list.find("res://Quests/json/" + str(d_list) + ".json")
	dialogue = _load_dialogue(Quests.dialogue_list[index])
	#return index
	#dialogue = _load_dialogue(d_list)
	
func _input(event):
	if not d_active:
		return
	if event.is_action_pressed("ui_accept"):
		_next_script()

func _auto_input():
	_next_script()

func _next_script():
	current_dialogue_id += 1
	
	if current_dialogue_id >= len(dialogue):
		$Timer.start(0.4)
		$NinePatchRect.visible = false
		_set_player_active()
		emit_signal("active", false)
		if talk_quest_current:
			Quests.get_node(str(person)).get_node("TalkQuest").emit_signal("talk_finished")
			talk_quest_current = false
			return
		if not Quests.quest_active:
			Quests.emit_signal("quest_accepted", person)#("Hubby_accepted")
			Quests.quest_active = true
		return
	$NinePatchRect/Chat.percent_visible = 0
	#if dialogue[current_dialogue_id]["name"] == "Signal":
		#emit_signal(dialogue[current_dialogue_id]["text"])
	#	return
	$NinePatchRect/Name.text = dialogue[current_dialogue_id]["name"]
	$NinePatchRect/Chat.text = dialogue[current_dialogue_id]["text"]
	animp.play("Ny Anim")

func _get_npc(person):
	if person == Quests.npc:
		talk_quest_current = true
	else:
		talk_quest_current = false

func _on_d_file_changed(npc, d_list):
	if person == npc:
		_new_d_file(d_list)
		#print((Quests.dialogue_list.find("res://Quests/json/" + str(d_list) + ".json")))
		#dialogue = _load_dialogue(Quests.dialogue_list.find(d_list))
		
	
func _on_Timer_timeout():
	d_active = false

func _on_talk_quest_started(person):
	_get_npc(person)

func _set_player_active():
	var player = PlayerStats.player
	if player:
		#player.set_active(true)
		player.set_process_unhandled_input(true)
		

func _set_player_inactive():
	var player = PlayerStats.player
	if player:
		#player.set_active(false)
		player.set_process_unhandled_input(true)
