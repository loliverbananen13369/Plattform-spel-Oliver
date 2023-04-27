extends Node

"""
Delar ut vilken NPC som får nästa mission. Det här är main, som sköter vilket uppdrag som ska väljas. 

Gjorde questsystem någon dag innan deadlinen, så det finns funktioner som är helt onödiga. Jag testade ba mycket. 
"""



var npc
var list = []

var global_quest_id := -1
var quest_available := true
var quest_active := false
var talk_quest_active := false

const ChooseClassDia = "res://Quests/json/ChooseClassDia.json"
const HubbyKillSkeletonsDia = "res://Quests/json/HubbyKillSkeletonsDia.json"

var dialogue_list = [ChooseClassDia, HubbyKillSkeletonsDia]

signal quest_available(person)
signal quest_accepted(person)
signal quest_completed()
signal xp_changed()
signal quest_delivered(person)
signal EnemyDead(type)


signal ClassChosen()
signal ClassChosen2()
signal CityHallLoaded()
var class_chosen = false

signal TutorialFinished()
signal TutorialFinished2()
var tutorial_finished = false


export(String, FILE, "*.json") var npc_file

onready var Hubby = $Hubby
onready var Katalina = $Katalina

func _ready():
	connect("TutorialFinished", self, "_on_tutorial_finished")
	connect("ClassChosen", self, "_on_class_chosen")
	connect("CityHallLoaded", self, "_on_cityhall_loaded")
	connect("quest_available", self, "_on_quest_available")
	connect("quest_completed", self, "_on_quest_completed")
	list = _load_npc_list()
	

func _load_npc_list(): #Tar lista över vilken npc som ska få nästa uppdrag
	var file = File.new()
	if file.file_exists(npc_file):
		file.open(npc_file, file.READ)
		return parse_json(file.get_as_text())

func _get_npc(): #Ger vilken npc som får den
	npc = list[global_quest_id]["NPC"]
	return npc

func _get_next(): #Ger nästa uppdrag
	global_quest_id += 1
	if global_quest_id >= len(list):
		list.invert()
		global_quest_id = 0
	_get_npc()

func send_quest_available(): #Signal
	_get_next()
	emit_signal("quest_available", npc)



func _on_quest_available(npc):
	pass

func _on_quest_completed():
	emit_signal("xp_changed")
	quest_active = false
	send_quest_available()

func _on_cityhall_loaded(): #När cityhall har laddats klart skickar den ut signalen. Fungerar som en mellanhand
	if tutorial_finished:
		emit_signal("TutorialFinished2")
		tutorial_finished = false
		return
	if class_chosen:
		emit_signal("ClassChosen2")
		class_chosen = false
		
func _on_tutorial_finished():
	tutorial_finished = true

func _on_class_chosen():
	class_chosen = true
