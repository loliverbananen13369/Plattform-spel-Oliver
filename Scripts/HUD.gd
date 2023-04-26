extends CanvasLayer

#Hud. Tagit kod från alien

onready var hpbar = $HPBar
onready var hpbarunder = $HPBarUnder
onready var xpbar = $XPBar
onready var xpbarunder = $XPBarUnder
onready var hp_tween = $Tween
onready var xp_tween = $Tween2
onready var leveltext = $LevelText
onready var animp = $AnimationPlayer

var level = 1
var max_xp = 40
var _current_xp = 0

func _ready():
	hpbar.value = PlayerStats.hp
	hpbarunder.value = hpbar.value
	xpbar.value = PlayerStats.current_xp
	xpbarunder.value = xpbar.value
	xpbar.max_value = PlayerStats.xp_needed
	xpbarunder.max_value = xpbar.max_value
	leveltext.text = "Level: " + str(PlayerStats.current_lvl)


func _on_Player_HPChanged(hp):
	hpbar.value = hp
	hp_tween.stop_all()
	hp_tween.interpolate_property(hpbarunder, "value", hpbarunder.value, hp, 0.5,Tween.TRANS_CUBIC)
	hp_tween.start()
	animp.play("TakeDamage")
	if hpbar.value < 30:
		animp.play("LowHP")

func _on_Player_XPChanged(_current_xp):
	
	#if xpbar.value < current_xp:
	xpbar.value = PlayerStats.current_xp
	xp_tween.stop_all()
	xp_tween.interpolate_property(xpbarunder, "value", xpbarunder.value, PlayerStats.current_xp, 0.5,Tween.TRANS_LINEAR)
	xp_tween.start()

func _on_Player_LvlUp(_current_lvl, xp_needed):
	leveltext.text = "Level: " + str(PlayerStats.current_lvl)
	max_xp = xp_needed
	xpbar.value = 0
	xpbarunder.value = 0
	xpbar.max_value = max_xp
	xpbarunder.max_value = max_xp
