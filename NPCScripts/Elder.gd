extends AnimatedSprite


var can_interact = false
var quest_available = false

onready var quest_d = $QuestDialogue
onready var normal_d = $Dialogue

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Quests.connect("quest_available", self, "on_quest_available")
	Quests.connect("quest_completed", self, "on_quest_completed")

func _input(event: InputEvent) -> void:
	#if can_interact:
	if event.is_action_pressed("ui_accept"):
		_check_dialogue()

func _check_dialogue() -> void:
	if quest_available:
		quest_d._start()
	else:
		normal_d._start()
		#quest_d._start()

func on_quest_available(person):
	if person == "Hubby":
		quest_available = true
		$QuestAvailableTestIndicator.visible = true

func on_quest_completed():
	quest_available = false
	$QuestAvailableTestIndicator.visible = false

func _on_Area2D_body_entered(body: Node) -> void:
	if body.is_in_group("Player"):
		can_interact = true
		
func _on_Area2D_body_exited(body: Node) -> void:
	if body.is_in_group("Player"):
		can_interact = false

func _on_QuestDialogue_dialogue_done(nr) -> void:
	if nr == 1:
		Transition.load_scene("res://UI/ChooseClassScene.tscn")
