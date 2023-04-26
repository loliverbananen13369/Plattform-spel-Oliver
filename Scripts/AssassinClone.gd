extends AnimatedSprite



#Lägger till en klon för divine warrior som attackerar en gång och sedan dör

func _ready():
	$SmearSprite.position.y = 5
	$NormalAttackArea/AttackGround.position.y = 5
	if flip_h == true:
		$SmearSprite.position.x = -20
		$NormalAttackArea/AttackGround.position.x = -36
	else:
		$SmearSprite.position.x = 20
		$NormalAttackArea/AttackGround.position.x = 36
	$SmearSprite.flip_h = flip_h	

#

func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "Spawn":
		$AnimationPlayer.play("Attack1")
