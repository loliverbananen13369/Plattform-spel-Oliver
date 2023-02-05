extends CanvasLayer


onready var hpbar = $HPBar
onready var hpbarunder = $HPBarUnder
onready var xpbar = $XPBar
onready var xpbarunder = $XPBarUnder
onready var tween = $Tween
onready var leveltext = $LevelText

var level = 1
var max_xp = 40
var _current_xp = 0
# Called when the node enters the scene tree for the first time.
func _ready():
	hpbar.value = 100
	hpbarunder.value = 100
	xpbar.value = 0
	xpbarunder.value = 0
	xpbar.max_value = max_xp
	xpbarunder.max_value = max_xp
	leveltext.text = "Level: " + str(level)


func _on_Player_HPChanged(hp):
	if hpbar.value > hp:
		#minskning
		hpbar.value = hp
		tween.stop_all()
		tween.interpolate_property(hpbarunder, "value", hpbarunder.value, hp, 0.5,Tween.TRANS_LINEAR)
		tween.start()

func _on_Player_XPChanged(current_xp):
	#if xpbar.value < current_xp:
	xpbar.value = current_xp
	tween.stop_all()
	tween.interpolate_property(xpbarunder, "value", xpbarunder.value, current_xp, 0.5,Tween.TRANS_LINEAR)
	tween.start()


func _on_Player_LvlUp(current_lvl, xp_needed):
	level += 1
	leveltext.text = "Level: " + str(current_lvl)
	max_xp = xp_needed
	xpbar.value = 0
	xpbarunder.value = 0
	xpbar.max_value = max_xp
	xpbarunder.max_value = max_xp
