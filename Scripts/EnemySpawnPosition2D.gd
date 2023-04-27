extends Position2D

#Kollar hur många fiender som finns inom arean, och spawnar om den kan spawna nya fiender

export (int) var amount_allowed
var list_of_enemies = []
export (bool) var can_spawn = true
var amount = 0

export (int) var diameter = 0
export (SpriteFrames) var skin
export (SpriteFrames) var hit
export (int) var hp_max
export (int) var damage_dealt
export (String) var enemy_type
export (Color) var enemy_hp_bar_color

signal can_spawn(can)

func _ready():
	PlayerStats.connect("EnemyDead", self, "on_EnemyDead")

func _on_Area2D_body_entered(body):   #Ger att fiender inte ska följa spelaren till en annan plattform, dvs hoppa av
	if body.is_in_group("Player"):
		for i in range(0, list_of_enemies.size() -1):
			list_of_enemies[i].can_hunt = true
	

func on_EnemyDead(body):  #Kollar när fienden dör och skickar signal till enemyspawner1
	if list_of_enemies.has(body):
		list_of_enemies.erase(body)
		amount -= 1
		if amount < amount_allowed:
			can_spawn = true
			emit_signal("can_spawn", can_spawn)

func _on_EnemySpawner1_Spawned(body): #Tar emot signal från enemyspawner
	amount += 1
	if amount >= amount_allowed:
		can_spawn = false
		emit_signal("can_spawn", can_spawn)
		
	list_of_enemies.append(body)


func _on_Area2D_body_exited(body): #Så enemies inte ska följa med till nästa plattform. Fungerar inte helt, men hjälper lite
	if body.is_in_group("Player"):
		for i in range(0, list_of_enemies.size() -1):
			list_of_enemies[i].can_hunt = false
	
