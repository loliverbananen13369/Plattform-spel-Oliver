extends Node

export (String) var goal
export (String) var reward
export (String) var location

var list := []
var completed := false

onready var glabel = $GoLayer/GoLabel
onready var rlabel = $RewardLayer/RewardLabel
onready var animp = $AnimationPlayer

signal quest_completed()
signal quest_dialouge_finished(npc)
signal talk_finished()

func _ready():
	var parent = get_parent()
	connect("talk_finished", self, "_on_talked_finished")
	connect("quest_dialouge_finished", self, "_on_quest_dialouge_finished")
	glabel.text = "Go talk to  " + str(goal)

func _on_talked_finished():
	_quest_completed()

func _quest_completed():
	_give_reward()
	emit_signal("quest_completed")

func _give_reward():
	PlayerStats.current_xp += int(reward)
	print(reward)
	PlayerStats.player.emit_signal("XPChanged", PlayerStats.current_xp)
	rlabel.text = ("reward:  +" + str(reward))
	animp.stop(false)
	animp.play("Reward")
	yield(animp, "animation_finished")
	queue_free()

