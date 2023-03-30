extends AnimatedSprite


# Declare member variables here. Examples:
# var a: int = 2
# var b: String = "text"
onready var dtimer = $Timer
onready var dia = $Dialogue

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	#yield(get_tree().create_timer(1), "timeout")
	#_use_dialogue()
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
#	pass

func _use_dialogue():
	var dialogue = get_node("Dialogue")
	if dialogue:
		dialogue._start()

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("ui_accept"):
		dia._input(event)
		dtimer.start(2)
		
func _on_Timer_timeout() -> void:
	dia._auto_input()
	dtimer.start(2)
