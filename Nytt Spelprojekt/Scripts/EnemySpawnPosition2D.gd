extends Position2D

export (int) var amount_allowed
var list_of_enemies = []
export (bool) var can_spawn = true
var amount = 0
export (int) var diameter = 0


# Called when the node enters the scene tree for the first time.
func _ready():
#	connect("Spawned", self, "_on_enemy_spawned")
	PlayerStats.connect("EnemyDead", self, "on_EnemyDead")

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _on_Area2D_body_entered(body):
	if body.is_in_group("Player"):
		for i in range(0, list_of_enemies.size() -1):
			list_of_enemies[i].can_hunt = true
	

func on_EnemyDead(body):
	if list_of_enemies.has(body):
		list_of_enemies.erase(body)
		if amount < amount_allowed:
			can_spawn = true

func _on_EnemySpawner1_Spawned(body):
	amount += 1
	if amount >= amount_allowed:
		can_spawn = false
	list_of_enemies.append(body)


func _on_Area2D_body_exited(body):
	if body.is_in_group("Player"):
		for i in range(0, list_of_enemies.size() -1):
			list_of_enemies[i].can_hunt = false
	
