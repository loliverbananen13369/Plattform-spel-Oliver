extends Node

#Quest nr 1
#Gå till Hubby, prata med honom.
#Gå till blacksmith och döda 10 skeletons
#Gå tillbaka till blacksmith, få en skillpoint

#Quest nr 2
#Gå till Katalina och döda 25 skeletons
#Gå tillbaka och få en skillpoint

#Quest nr 3
#Gå till NPCRock och döda 10 gröna skelet
#Gå tillbaka och få en skillpoint

signal quest_completed(quest)
signal reward(quest)

var id := 0
var quest_active := 0
var giver

export(String, FILE, "*.json") var q_file

func _ready():
	pass # Replace with function body.

func _load_dialogue():
	var file = File.new()
	if file.file_exists(q_file):
		file.open(q_file, file.READ)
		return parse_json(file.get_as_text())

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
