extends Node

"""
När ett dödaruppdrag instansieras, kollar den varje gång en fiende dör. När tillräckligt har dött, skickar den signalen att uppdraget är utfört
"""


export (String) var skeleton_type
export (String) var goal
export (String) var reward
export (String) var d_list

var list := []
var completed := false

signal quest_completed()

onready var glabel = $FirstLayer/GoalLabel
onready var kclabel = $OnKillLayer/KillCountLabel
onready var rlabel = $RewardLayer/RewardLabel
onready var animp = $AnimationPlayer

var killcount := 0

func _ready():
	Quests.connect("EnemyDead", self, "_on_enemy_dead")
	rlabel.visible = false
	glabel.text = ("kill  " + str(goal) + "  " + str(skeleton_type) + "  " + "skeletons")
	

func _on_enemy_dead(type):
	if skeleton_type == type:
		if not completed:
			killcount += 1
			kclabel.text = str(killcount) + " / " + str(goal)
			_check_killcount()
		animp.play("Kill")
	
func _check_killcount():
	if killcount >= int(goal):
		killcount = int(goal)
		completed = true
		_quest_completed()

func _give_reward():
	PlayerStats.player.current_xp += int(reward)
	rlabel.visible = true
	rlabel.text = ("reward:  +" + str(reward))
	animp.stop(false)
	animp.play("Reward")
	yield(animp, "animation_finished")
	queue_free()

func _quest_completed():
	_give_reward()
	emit_signal("quest_completed")

		
	


