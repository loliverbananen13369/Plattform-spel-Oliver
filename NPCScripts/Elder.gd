extends AnimatedSprite

export (String) var person 
var can_interact = false
var quest_available = false

onready var quest_d = $QuestDialogue
onready var normal_d = $Dialogue


func _ready():
	Quests.connect("quest_available", self, "_on_quest_available")
	if Quests.npc == person:
		quest_available = true

func _get_dialogue_file(npc):
	if npc == person:
		quest_d.d_file = "res://Quests/json/ChooseClassQuest.json"
	

func _input(event: InputEvent) -> void:
	if can_interact:
		if event.is_action_pressed("ui_accept"):
			_check_dialogue()
			print(event)
			

func _check_dialogue() -> void:
	if quest_available:
		quest_d._start()
	else:
		normal_d._start()
		#quest_d._start()

func _on_QuestDialogue_dialogue_done(nr):
	if nr == 1:#Quests.global_quest_id:
		Quests.get_node(str(person)).emit_signal("talk_finished")
	
func _on_quest_available(npc):
	if npc == person:
		quest_available = true

func _on_Area2D_body_entered(body: Node) -> void:
	if body.is_in_group("Player"):
		can_interact = true
		
func _on_Area2D_body_exited(body: Node) -> void:
	if body.is_in_group("Player"):
		can_interact = false
