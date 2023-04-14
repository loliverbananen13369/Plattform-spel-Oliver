extends Panel


onready var label = $Label



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Quests.connect("quest_available", self, "on_quest_available")


func on_quest_available():
	if Quests.first_quest:
		label = "Go to the Town's Hubby"

