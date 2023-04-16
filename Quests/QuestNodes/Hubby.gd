extends Node


#Hubyb
var index := 0
var list := []
var types_of_info := ["type", "goal", "reward", "d_list"]
var list_of_types := [type, goal, reward, d_list]

var type
var goal
var reward
var d_list

onready var kill_quest_scene = preload("res://Quests/QuestNodes/KillQuest.tscn")
onready var talk_quest_scene = preload("res://Quests/QuestNodes/TalkQuest.tscn")

export (String) var who
export (String, FILE, "*.json") var i_file 
export (Array, String) var dia_list
#export (Array, FILE, "*.json") var dia_list


signal talk_finished()
signal talk_quest_started(npc)
signal change_d_file(npc, file)

func _ready():
	list = _load_index_list()
	_get_all_info()
	Quests.connect("quest_accepted", self, "_on_quest_accepted")
	Quests.connect("quest_available", self, "_on_quest_available")
	connect("talk_finished", self, "_on_talk_finished")
"""
func load_json_file(path):
	var file = File.new()
	file.open(path, file.READ)
	var text = file.get_as_text()
	var result_json = JSON.parse(text)
	if result_json.error != OK:
		print("[load_json_file] Error loading JSON file '" + str(path) + "'.")
		print("\tError: ", result_json.error)
		print("\tError Line: ", result_json.error_line)
		print("\tError String: ", result_json.error_string)
		return null
	var obj = result_json.result
	return obj
"""
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
	child.d_list = _get_info("d_list")
	child.skeleton_type = _get_info("s_type")
	child.connect("quest_completed", self, "_on_quest_completed")
	emit_signal("change_d_file", child.goal, child.d_list)
	add_child(child)

func _talk_quest():
	var child = talk_quest_scene.instance()
	child.goal = _get_info("goal")
	child.reward = _get_info("reward")
	child.d_list = _get_info("d_list")
	child.connect("quest_completed", self, "_on_quest_completed")
	emit_signal("talk_quest_started", child.goal)
	add_child(child)


func _on_quest_completed():
	index += 1
	Quests.emit_signal("quest_completed")

func _on_talk_finished():
	pass

func _on_quest_available(npc):
	if who == npc:
		if _get_info("type") == "talk":
			_talk_quest()
		if _get_info("type") == "kills":
			_kill_quest()

func _on_quest_accepted(npc):
	pass
	
"""
func _on_hubby_accepted():
	if _get_info("type") == "talk":
		_talk_quest()
	if _get_info("type") == "kills":
		_kill_quest()
"""
