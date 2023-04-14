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

signal quest_started()
signal quest_available(person)
signal quest_completed()
signal reward()

var id := 0
var quest_active := 0
var giver

var first_quest = false
var skeletonskilled = 0


export(String, FILE, "*.json") var q_file

func _ready():
	pass # Replace with function body.



# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
