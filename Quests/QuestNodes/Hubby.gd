extends Node


#Hubyb
var index := 0
var list := []
var types_of_info := ["type", "goal", "reward", "location"]
var list_of_types := [type, goal, reward, location]

var type
var goal
var reward
var location

onready var kill_quest_scene = preload("res://Quests/QuestNodes/KillQuest.tscn")
onready var talk_quest_scene = preload("res://Quests/QuestNodes/TalkQuest.tscn")

export (String) var who
export(String, FILE, "*.json") var i_file

signal talk_finished()
signal talk_quest_started(npc)

func _ready():
	list = _load_index_list()
	_get_all_info()
	Quests.connect("quest_accepted", self, "_on_quest_accepted")
	Quests.connect("Hubby_accepted", self, "_on_hubby_accepted")
	#Quests.connect("quest_available", self, "_on_quest_available")
	Quests.connect("Hubby_available", self, "_on_hubby_available")
	connect("talk_finished", self, "_on_talk_finished")
	
func _load_index_list():
	var file = File.new()
	if file.file_exists(i_file):
		file.open(i_file, file.READ)
		return parse_json(file.get_as_text())

func _get_info(info: String):
	var information
	_check_list()
	information = list[index][info] 
	return information

func _check_list():
	if index >= len(list):
		list.invert()
		index = 0

func _get_all_info():
	for i in range(len(list_of_types)):
		list_of_types[i] = _get_info(types_of_info[i])
		#print(types_of_info[i])
		#print(list_of_types[i])

func _kill_quest():
	var child = kill_quest_scene.instance()
	child.goal = _get_info("goal")
	child.reward = _get_info("reward")
	child.location = _get_info("location")
	child.skeleton_type = _get_info("s_type")
	child.connect("quest_completed", self, "_on_quest_completed")
	add_child(child)

func _talk_quest():
	var child = talk_quest_scene.instance()
	child.goal = _get_info("goal")
	child.reward = _get_info("reward")
	child.location = _get_info("location")
	child.connect("quest_completed", self, "_on_quest_completed")
	emit_signal("talk_quest_started", child.goal)
	add_child(child)

func _on_hubby_available():
	pass

func _on_quest_completed():
	index += 1
	Quests.emit_signal("quest_completed")

func _on_talk_finished():
	pass

func _on_quest_accepted(npc):
	if who == npc:
		if _get_info("type") == "talk":
			_talk_quest()
		if _get_info("type") == "kills":
			_kill_quest()
	
"""
func _on_hubby_accepted():
	if _get_info("type") == "talk":
		_talk_quest()
	if _get_info("type") == "kills":
		_kill_quest()
"""
