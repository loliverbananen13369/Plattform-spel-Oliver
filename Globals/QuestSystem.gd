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

var global_quest_id := -1
var quest_available := true
var quest_active := false
var talk_quest_active := false

const ChooseClassQuest = "res://Quests/json/ChooseClassQuest.json"
const HubbyKillSkeletonsDia = "res://Quests/json/HubbyKillSkeletonsDia.json"

signal quest_available(person)
signal quest_accepted(person)
signal quest_completed()
signal xp_changed()
signal quest_delivered(person)
signal Hubby_available()
signal Hubby_accepted()
signal Katalina_available()
signal Katalina_accepted()

export(String, FILE, "*.json") var npc_file

onready var Hubby = $Hubby
onready var Katalina = $Katalina

func _ready():
	connect("quest_available", self, "_on_quest_available")
	connect("quest_completed", self, "_on_quest_completed")
	list = _load_npc_list()
	
	
	

func _load_npc_list():
	var file = File.new()
	if file.file_exists(npc_file):
		file.open(npc_file, file.READ)
		return parse_json(file.get_as_text())

func _get_npc():
	npc = list[global_quest_id]["NPC"]
	return npc

func _get_next():
	global_quest_id += 1
	if global_quest_id >= len(list):
		list.invert()
		global_quest_id = 0
	_get_npc()

func send_quest_available():
	_get_next()
	emit_signal("quest_available", npc)



func _on_quest_available(npc):
	pass

func _on_quest_completed():
	emit_signal("xp_changed")
	quest_active = false
	send_quest_available()


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
