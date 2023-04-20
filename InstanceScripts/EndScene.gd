extends CanvasLayer


func _ready() -> void:
	Quests.queue_free()
	Pause.queue_free()
	SkillTree.queue_free()

func _on_AnimationPlayer_animation_finished(_anim_name: String) -> void:
	get_tree().quit()
