extends CanvasLayer


onready var hpbar = $HPBar
onready var hpbarunder = $HPBarUnder
onready var manabar = $ManaBar
onready var manabarunder = $ManaBarUnder
onready var tween = $Tween

# Called when the node enters the scene tree for the first time.
func _ready():
	hpbar.value = 100
	hpbarunder.value = 100
	manabar.value = 100
	manabarunder.value = 100






func _on_Player_HPChanged(hp):
	if hpbar.value > hp:
		#minskning
		hpbar.value = hp
		tween.stop_all()
		tween.interpolate_property(hpbarunder, "value", hpbarunder.value, hp, 0.5,Tween.TRANS_LINEAR)
		tween.start()
