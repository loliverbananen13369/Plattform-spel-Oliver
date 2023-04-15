extends Node

"""
Delar ut vilken NPC som får nästa mission
"""

"""
Variabler och signaler som behövs:
var quest_available = true
var quest_active = false
var global_quest_id = 0

signal quest_available(npc)
signal quest_accepted()
signal quest_completed()
signal quest_delivered(npc)

func _on_quest_delivered(npc):
	npc.give_reward()
	_next_quest()
	quest_available = true
	quest_active = false

func _next_quest() -> void:
	global_quest_id += 1
	emit_signal(quest_available(json_file[current_quest_id]))
	

"""
var npc
var list = []

var global_quest_id := 0
var quest_available := true
var quest_active := false



signal quest_available(npc)
signal quest_accepted()
signal quest_completed()
signal quest_delivered(npc)

export(String, FILE, "*.json") var npc_file

func _ready():
	list = _load_npc_list()
	_get_next()
	
	
	

func _load_npc_list():
	var file = File.new()
	if file.file_exists(npc_file):
		file.open(npc_file, file.READ)
		return parse_json(file.get_as_text())

func _get_npc():
	npc = list[global_quest_id - 1]["NPC"]
	return npc

func _get_next():
	global_quest_id += 1
	if global_quest_id >= len(list):
		list.invert()
		global_quest_id = 1
	_get_npc()
	_send_quest_available()
	
func _send_quest_available():
	emit_signal("quest_available", npc)

func _input(event):
	if event.is_action_pressed("ui_accept"):
		_get_next()



"""
func _load_dialogue():
	var file = File.new()
	if file.file_exists(d_file):
		file.open(d_file, file.READ)
		return parse_json(file.get_as_text())
"""
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
