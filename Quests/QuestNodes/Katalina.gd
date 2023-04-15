extends Node


func _ready():
	get_parent().connect("quest_available", self, "_on_quest_available")

func _on_quest_available(npc):
	if npc == "Katalina":
		print("self")


