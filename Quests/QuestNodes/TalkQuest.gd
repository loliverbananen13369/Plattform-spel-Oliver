extends Node

export (String) var goal
export (String) var reward
export (String) var d_list

var list := []
var completed := false

onready var glabel = $GoLayer/GoLabel
onready var animp = $AnimationPlayer

onready var reward_scene = preload("res://Instance_Scenes/Reward.tscn")

signal quest_completed()
signal quest_dialouge_finished(npc)
signal talk_finished()

func _ready():
	var parent = get_parent()
	connect("talk_finished", self, "_on_talked_finished")
	glabel.text = "Go talk to  " + str(goal)

func _on_talked_finished():
	_quest_completed()

func _quest_completed():
	_add_reward()
	emit_signal("quest_completed")
	queue_free()

func _add_reward():
	var child = reward_scene.instance()
	child.reward = reward
	get_tree().get_root().add_child(child)

