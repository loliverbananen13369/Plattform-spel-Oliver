extends AnimatedSprite

onready var dtimer = $Timer
onready var dia = $Dialogue

func _ready() -> void:

	set_process_input(false)



func _use_dialogue(): #Se dialouge för dialouge._start()
	var dialogue = get_node("Dialogue")
	if dialogue:
		dialogue._start()

func _on_Timer_timeout() -> void:
	dia._auto_input()
