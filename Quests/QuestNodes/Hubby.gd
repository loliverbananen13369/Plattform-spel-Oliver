extends Node

"""
Egentligen borde scenen heta NPC, eftersom jag instansierar den här scene i Questssystem, dvs huvudnoden. Den fungerar för alla npcs,
där export var who är vilken npc den ska representera. Den tar emot signal från main questsystem att ett nytt uppdrag, och skickar i sin tur
ut vilken sort av quest som ska instansieras. 
"""
var index := 0
var list := []
var types_of_info := ["type", "goal", "reward", "d_list"]
var list_of_types := [type, goal, reward, d_list]

var type
var goal
var reward

onready var kill_quest_scene = preload("res://Quests/QuestNodes/KillQuest.tscn")
onready var talk_quest_scene = preload("res://Quests/QuestNodes/TalkQuest.tscn")

export (String) var who
export (String, FILE, "*.json") var i_file 
export (Array, String) var d_list


signal talk_finished()
signal talk_quest_started(npc)
signal change_d_file(npc, file)
signal check_person(person)
signal person_checked(correct, file)

func _ready():
	list = _load_index_list()
	_get_all_info()
	Quests.connect("quest_accepted", self, "_on_quest_accepted")
	Quests.connect("quest_available", self, "_on_quest_available")
	connect("talk_finished", self, "_on_talk_finished")
	connect("check_person", self, "_on_check_person")

func _load_index_list(): #Laddar en json fil som innehåller vilken typ av uppdrag, hur många man ska döda / vem man ska prata med
	var file = File.new()
	if file.file_exists(i_file):
		file.open(i_file, file.READ)
		return parse_json(file.get_as_text())

func _get_info(info: String): 
	var information
	_check_list()
	information = list[index][info] 
	return information

func _check_list(): #Det kommer alltid finnsa uppdrag. Däremot problematiskt, eftersom choose_class scene egentligen endast ska köras en gång. Hoppas den som spelar inte kommer så långt i uppdragen
	if index >= len(list):
		list.invert()
		index = 0

func _get_all_info():
	for i in range(len(list_of_types)):
		list_of_types[i] = _get_info(types_of_info[i])

func _kill_quest(): #en ny node läggs till. Noden har värden osv. 
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
	emit_signal("change_d_file", child.goal, child.d_list)
	add_child(child)

func _on_check_person(person, child): #NPC skickar en signal och vill kolla om det är den som har uppdragen ( den har en export var som säger vad den heter ). Har försökt göra ett system där man kan lägga till nya npc, där alla har samma kod och variabler förutom just 'who' export variabeln.
	if person == _get_info("goal"):
		emit_signal("person_checked", true, _get_info("d_list"))
	else:
		emit_signal("person_checked", false, _get_info("d_list"))
	
func _on_quest_completed():
	index += 1
	Quests.emit_signal("quest_completed")

func _on_talk_finished():
	pass

func _on_quest_available(npc): #Kollar vilken typ av quest som ska spawnas
	if who == npc:
		if _get_info("type") == "talk":
			_talk_quest()
		if _get_info("type") == "kills":
			_kill_quest()

func _on_quest_accepted(npc):
	pass
	
