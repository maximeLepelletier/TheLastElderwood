extends CharacterBody2D

#CONSTANTES:
# 100 / 130 / 170 /290/370/470/600/760/950/1200/1500/1850/2300/2900/3600/4500/5600/7000
const XP_TABLE = [
	10, 20, 30, 40, 50,
	50, 50, 50, 50, 50,
	50, 50, 50, 2300, 2900,
	3600, 4500, 5600, 7000
]
#VARIABLES
var currrent_level = 1
var or_actuel=0
var exp_actuel=0
var exp_to_next = 10
#lifebar	
var max_hp = 300
var current_HP = 0
var regen_hp=0.5
#shieldbar
var shield_max_hp
var shield_current_HP = 0
var shield_active = false
var shield_regen
var shield_reflect
#SIGNALS
var skill_up ={}

#DEPENDANCES 
@onready var Tower: Area2D = %Tower

func _ready() -> void:
	current_HP = max_hp
	%LifeBar.max_value = max_hp
	%LifeBar.value = current_HP
	exp_to_next = get_xp_to_next_level(currrent_level)
	Events.shield_unlock.connect(_on_shield_unlocked)
	Events.shield_heal.connect(on_shield_heal)
	add_to_group("player")
	
func _physics_process(_delta: float) -> void:		
	%LifeBar.value = current_HP
	if shield_active == true:
		%ShieldBar.value = shield_current_HP
	if current_HP<=0.0:
		Events.hp_empty.emit()
	
func add_gold(nb_or,multiplier: int =1):	
	or_actuel+=(nb_or*multiplier)
	Events.stats_changed.emit(or_actuel,exp_actuel)
	print("OR : " + str(or_actuel))
	
func add_exp(nb_exp):	
	exp_actuel += nb_exp
	if exp_actuel >= exp_to_next:
		exp_actuel -= exp_to_next
		level_up()
	Events.stats_changed.emit(or_actuel,exp_actuel)	

func level_up():
	currrent_level += 1
	exp_to_next = get_xp_to_next_level(currrent_level)  # progression exponentielle
	Events.leveling_up.emit()  # Signal pour l’UI ou le système d’upgrade

func get_xp_to_next_level(level: int) -> int:
	if level - 1 < XP_TABLE.size():
		return XP_TABLE[level - 1]
	return XP_TABLE[-1]
		
func apply_upgrade(upgrade_id: String):
	var data = UpgradeManager.get_upgrade_data(upgrade_id)
	if data.type == "stat":
		var stat = data.target
		if stat == "regen":
			add_regen(data.value)	
		elif stat == "hp":
			add_hp_max(data.value)	
	if data.type == "skill":		
		Tower.unlockSkill(upgrade_id)
	if data.type == "skill_upgrade":		
	#on passe les infos du bouclier a l'update		
		if upgrade_id.begins_with("sylv_shield"):
			shield_max_hp= Tower.get_stat("sylv_shield","max_hp")
			shield_current_HP =  Tower.get_stat("sylv_shield","current_HP")
			shield_regen =  Tower.get_stat("sylv_shield","regen")			
		Tower.upgradeSkill(data.requires,upgrade_id,data.value)
	if data.type == "skill_super":
		var base = data.requires
		Tower.applySuperSkill(base, upgrade_id, data.value)
		return
			
			
func add_regen(value):
	regen_hp+=value

func add_hp_max(value):
	max_hp+=value
	heal(value)	

func take_damage(value):
	if shield_active:
		shield_take_damage(value)			
	else:
		current_HP-= value
			
func heal(value):
	current_HP+= value
	
func _on_regen_hp_timeout() -> void:
	if current_HP < max_hp:
		heal(regen_hp)
		if current_HP> max_hp:
			current_HP=max_hp
			print("HP :"+ str(current_HP))


#shield
func _on_shield_unlocked(shield_hp,regen):
	shield_max_hp = shield_hp
	shield_current_HP = shield_hp
	shield_regen = regen
	shield_reflect = false
	%ShieldBar.max_value = shield_hp
	%ShieldBar.value = shield_hp	
	%ShieldBar.visible = true
	print("Bouclier activé !")
	shield_active=true
	Events.update_shield.emit(shield_max_hp,shield_current_HP,shield_regen)

func shield_take_damage(amount: float) -> void:
	shield_current_HP-= amount
	if shield_current_HP <= 0:
		shield_active=false
		%ShieldBar.visible = false
	Events.update_shield.emit(shield_max_hp,shield_current_HP,shield_regen)

func on_shield_heal(amount: float) -> void:
	shield_current_HP= amount
	if shield_current_HP > 0:
		shield_active=true
		%ShieldBar.visible = true
	Events.update_shield.emit(shield_max_hp,shield_current_HP,shield_regen)
