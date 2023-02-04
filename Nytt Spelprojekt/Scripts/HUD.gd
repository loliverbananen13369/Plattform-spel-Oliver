extends CanvasLayer


onready var hpbar = $HPBar
onready var hpbarunder = $HPBarUnder
onready var xpbar = $XPBar
onready var xpbarunder = $XPBarUnder
onready var tween = $Tween

# Called when the node enters the scene tree for the first time.
func _ready():
	hpbar.value = 100
	hpbarunder.value = 100
	xpbar.value = 0
	xpbarunder.value = 0


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
