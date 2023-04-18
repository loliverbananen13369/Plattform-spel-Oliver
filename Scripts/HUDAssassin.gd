extends CanvasLayer


onready var hpbar = $HPBar
onready var hpbarunder = $HPBarUnder
onready var xpbar = $XPBar
onready var xpbarunder = $XPBarUnder
onready var leveltext = $XPBarUnder/LevelText
onready var energybar = $EnergyBar
onready var energybarunder = $EnergyBarUnder
onready var tween = $Tween


var max_xp = 40

# Called when the node enters the scene tree for the first time.
func _ready():
	hpbar.value = 100
	hpbarunder.value = 100
	xpbar.value = PlayerStats.current_xp
	xpbarunder.value = xpbar.value
	xpbar.max_value = PlayerStats.xp_needed
	xpbarunder.max_value = xpbar.max_value
	leveltext.text = "Level: " + str(PlayerStats.current_lvl)
	energybar.value = 50
	energybarunder.value = 50


func _on_Player_HPChanged(hp):
	#if hpbar.value > hp:
		#minskning
	hpbar.value = hp
	#tween.stop_all()
	tween.interpolate_property(hpbarunder, "value", hpbarunder.value, hp, 0.5,Tween.TRANS_CUBIC)
	tween.start()
	$AnimationPlayer.play("TakeDamage")
	if hpbar.value < 30:
		$AnimationPlayer.play("LowHP")

func _on_Player_XPChanged(_current_xp):
	#if xpbar.value < current_xp:
	xpbar.value = PlayerStats.current_xp
	tween.stop_all()
	tween.interpolate_property(xpbarunder, "value", xpbarunder.value, PlayerStats.current_xp, 0.5,Tween.TRANS_LINEAR)
	tween.start()


func _on_Player_LvlUp(_current_lvl, xp_needed):
	leveltext.text = "Level: " + str(PlayerStats.current_lvl)
	max_xp = xp_needed
	xpbar.value = 0
	xpbarunder.value = 0
	xpbar.max_value = max_xp
	xpbarunder.max_value = max_xp
	
func _on_Player_EnergyChanged(energy):
	energybar.value = energy
	tween.stop_all()
	tween.interpolate_property(energybarunder, "value", energybarunder.value, energy, 0.5,Tween.TRANS_LINEAR)
	tween.start()
	
