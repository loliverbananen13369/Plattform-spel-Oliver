extends Particles2D

#Ger vart necromancers hälso-stjäla får liv

onready var player1 = PlayerStats.player.get_node("LifeStealPos1")
onready var player2 = PlayerStats.player.get_node("LifeStealPos2")
var player
var rng = RandomNumberGenerator.new()


func _ready():
	rng.randomize()
	var random_number = rng.randi_range(1,2)
	if random_number == 1:
		player = player1
	else:
		player = player2
	emitting = true
	$Timer.start(0.5)
	

func _process(delta):
	global_position.x = player.global_position.x 
	global_position.y = player.global_position.y 

func _on_Timer_timeout():
	queue_free()
	
