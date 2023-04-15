extends AnimatedSprite


var can_interact = false
var quest_available = false

onready var quest_d = $QuestDialogue
onready var normal_d = $Dialogue

func _ready():
	pass

func _input(event: InputEvent) -> void:
	#if can_interact:
	if event.is_action_pressed("ui_accept"):
		_check_dialogue()

func _check_dialogue() -> void:
	if quest_available:
		quest_d._start()
	else:
		#normal_d._start()
		quest_d._start()

"""

const QUESTS_LIST = [("res://Quests/json/ChooseClassQuest.json"), ("res://Quests/json/TalkToBS1.json")]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Quests.connect("quest_available", self, "on_quest_available")
	Quests.connect("quest_completed", self, "on_quest_completed")
	quest_d.d_file = QUESTS_LIST[1]

func _input(event: InputEvent) -> void:
	#if can_interact:
	if event.is_action_pressed("ui_accept"):
		_check_dialogue()

func _check_dialogue() -> void:
	if quest_available:
		quest_d._start()
	else:
		#normal_d._start()
		quest_d._start()

func on_quest_available(person):
	if person == "Hubby":
		quest_available = true
		$QuestAvailableTestIndicator.visible = true
		quest_d.d_file = QUESTS_LIST[Quests.hubby_quest_id]

func on_quest_completed(nr):
	if nr == 1:
		Quests.quest_id = 2
		Quests.emit_signal("quest_available", "Hubby")
	else:
		quest_available = false
		$QuestAvailableTestIndicator.visible = false

func _on_Area2D_body_entered(body: Node) -> void:
	if body.is_in_group("Player"):
		can_interact = true
		
func _on_Area2D_body_exited(body: Node) -> void:
	if body.is_in_group("Player"):
		can_interact = false

func _on_QuestDialogue_dialogue_done(nr) -> void:
	pass


func _on_QuestDialogue_choose_class():
	Transition.load_scene("res://UI/ChooseClassScene.tscn")
"""
