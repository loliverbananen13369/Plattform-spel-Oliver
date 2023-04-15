extends Node

var index := 0
var list := []
var types_of_info := ["type", "goal", "reward", "location"]
var list_of_types := [type, goal, reward, location]

var type
var goal
var reward
var location

onready var kill_quest_scene = preload("res://Quests/QuestNodes/KillQuest.tscn")


export(String, FILE, "*.json") var i_file



func _ready():
	list = _load_index_list()
	_get_all_info()
	get_parent().connect("quest_available", self, "_on_quest_available")
	_kill_quest()
	
func _load_index_list():
	var file = File.new()
	if file.file_exists(i_file):
		file.open(i_file, file.READ)
		return parse_json(file.get_as_text())

func _get_info(info: String):
	var information
	information = list[1][info] #index
	return information


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


func _on_quest_available(npc):
	if npc == "Hubby":
		pass

func _on_quest_completed():
	print("completed")
