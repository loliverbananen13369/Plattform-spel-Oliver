extends Node2D

#Instansierar ett barn när spelaren har valt klass.

const NECRO_SKILLTREE = preload("res://Skill-Tree/Skill_Tree_Test.tscn")
const ASSASSIN_SKILLTREE = preload("res://Skill-Tree/Skill_Tree_TestAssassin.tscn")

var tree

func _ready() -> void:
	Quests.connect("ClassChosen", self, "_on_class_chosen")
	_on_class_chosen()

	

func _on_class_chosen() -> void:
	if PlayerStats.is_assassin:
		_add_assassin_tree()
	if PlayerStats.is_mage:
		_add_necro_tree()


func _add_assassin_tree():
	tree = ASSASSIN_SKILLTREE.instance()
	tree.get_child(0).visible = false
	add_child(tree)

func _add_necro_tree():
	tree = NECRO_SKILLTREE.instance()
	tree.get_child(0).visible = false
	add_child(tree)
