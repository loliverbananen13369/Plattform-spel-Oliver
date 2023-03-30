extends WorldEnvironment


# Declare member variables here. Examples:
# var a: int = 2
# var b: String = "text"


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	environment.glow_enabled = true
	environment.tonemap_exposure = 0.9



func _on_Player_test() -> void:
	environment.tonemap_exposure = 0.1
	$TestTimer.start(0.2)


	
