extends Node

export (String) var skeleton_type
export (String) var goal
export (String) var reward
export (String) var location

var list := []
var completed := false

signal quest_completed()

onready var glabel = $FirstLayer/GoalLabel
onready var rlabel = $FirstLayer/RewardLabel
onready var kclabel = $OnKillLayer/KillCountLabel
onready var animp = $AnimationPlayer

var killcount := 0

func _ready():
	PlayerStats.connect("EnemyDead", self, "_on_enemy_dead")
	#var list_instance := [goal, reward, location, skeleton_type]
	#print(list_instance)
	rlabel.visible = false
	glabel.text = ("kill  " + str(goal) + "  " + str(skeleton_type) + "  " + "skeletons")
	rlabel.text = ("reward:  " + str(reward))

func _on_enemy_dead(_dead):
	if not completed:
		killcount += 1
		kclabel.text = str(killcount) + " / " + str(goal)
		_check_killcount()
	animp.play("Kill")
	
func _check_killcount():
	if killcount >= goal:
		killcount = goal
		completed = true
		emit_signal("quest_completed")
		
	


