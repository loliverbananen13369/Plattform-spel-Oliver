extends CanvasLayer

#Hud. Tagit kod från alien

onready var hpbar = $HPBar
onready var hpbarunder = $HPBarUnder
onready var xpbar = $XPBar
onready var xpbarunder = $XPBarUnder
onready var leveltext = $XPBarUnder/LevelText
onready var energybar = $EnergyBar
onready var energybarunder = $EnergyBarUnder
onready var hp_tween = $Tween
onready var xp_tween = $Tween2
onready var energy_tween = $Tween3
onready var animp = $AnimationPlayer

var max_xp = 40

# Called when the node enters the scene tree for the first time.
func _ready():  #När scenen instansieras uppdateras värdena till autoloaden "PlayerStats"
	hpbar.value = PlayerStats.hp
	hpbarunder.value = hpbar.value
	xpbar.value = PlayerStats.current_xp
	xpbarunder.value = xpbar.value
	xpbar.max_value = PlayerStats.xp_needed
	xpbarunder.max_value = xpbar.max_value
	leveltext.text = "Level: " + str(PlayerStats.current_lvl)
	energybar.value = 50
	energybarunder.value = 50


func _on_Player_HPChanged(hp):  #När spelarens hp ändras startas en tween för len animation
	hpbar.value = hp
	hp_tween.stop_all()
	hp_tween.interpolate_property(hpbarunder, "value", hpbarunder.value, hp, 0.5,Tween.TRANS_CUBIC)
	hp_tween.start()
	animp.play("TakeDamage")
	if hpbar.value < 30:
		animp.play("LowHP")

func _on_Player_XPChanged(_current_xp): #När spelarens xp ändras 
	#if xpbar.value < current_xp:
	xpbar.value = PlayerStats.current_xp
	xp_tween.stop_all()
	xp_tween.interpolate_property(xpbarunder, "value", xpbarunder.value, PlayerStats.current_xp, 0.5,Tween.TRANS_LINEAR)
	xp_tween.start()


func _on_Player_LvlUp(_current_lvl, xp_needed):  #Återställer xpbaren
	leveltext.text = "Level: " + str(PlayerStats.current_lvl)
	max_xp = xp_needed
	xpbar.value = 0
	xpbarunder.value = 0
	xpbar.max_value = max_xp
	xpbarunder.max_value = max_xp
	
func _on_Player_EnergyChanged(energy): #Tweenar spelarens energibar. Energi finns inte i PlayerStats
	energybar.value = energy
	energy_tween.stop_all()
	energy_tween.interpolate_property(energybarunder, "value", energybarunder.value, energy, 0.5,Tween.TRANS_LINEAR)
	energy_tween.start()
	
