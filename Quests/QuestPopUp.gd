extends Node2D


onready var label = $CanvasLayer/Label

func _ready():
	Quests.connect("quest_available", self, "on_quest_available")


func on_quest_available():
	if Quests.quest_id == 1:
		label.text = "Go to the Town's Hubby"
