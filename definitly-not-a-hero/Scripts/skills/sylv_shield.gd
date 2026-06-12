extends Node2D

var tower
var shield_max_hp := 100
var shield_current_hp
var shield_regen
var shield_regen_interval
var mode

var shockwave_damage_incremental
var shockwave_pool:float =0
var shockwave_damage_limit
var shockwave_radius
var shockwave_speed
var shockwave_max_hp
var shockwave_current_hp
var shockwave_cooldown
var is_active :bool = true

var reflect :bool
@onready var sprite_2d: Sprite2D = $Sprite2D

func setup(owner) -> void:
	tower = owner
	global_position = tower.global_position
	shield_max_hp = tower.get_stat("sylv_shield", "shield_max_hp")
	shield_current_hp = shield_max_hp
	shield_regen = tower.get_stat("sylv_shield", "shield_regen")
	shield_regen_interval = tower.get_stat("sylv_shield", "shield_regen_interval")
	shockwave_damage_incremental = tower.get_stat("sylv_shield","shockwave_damage_incremental")
	shockwave_damage_limit = tower.get_stat("sylv_shield","shockwave_damage_limit")
	shockwave_radius = tower.get_stat("sylv_shield","shockwave_radius")
	shockwave_speed = tower.get_stat("sylv_shield","shockwave_speed")
	shockwave_max_hp = tower.get_stat("sylv_shield","shockwave_max_hp")
	shockwave_current_hp = tower.get_stat("sylv_shield","shockwave_current_hp")
	shockwave_cooldown = tower.get_stat("sylv_shield","shockwave_cooldown")
	%Timer.wait_time = shield_regen_interval
	%Timer.start()
	trigger_behavior(shield_current_hp)
	Events.shield_broken.connect(_on_shield_broke)

func _refresh_from_tower() -> void:
	var old_max_hp = shield_max_hp
	mode = tower.get_property("sylv_shield","mode")	
	apply_mode()	
	shield_current_hp += shield_max_hp - old_max_hp
	shield_current_hp = min(shield_current_hp,shield_max_hp)
	trigger_behavior(shield_current_hp)
	
func apply_mode():
	match mode: 
		"shockwave":
			shockwave_damage_incremental = tower.get_stat("sylv_shield","shockwave_damage_incremental")
			shockwave_damage_limit = tower.get_stat("sylv_shield","shockwave_damage_limit")
			shockwave_radius = tower.get_stat("sylv_shield","shockwave_radius")
			shockwave_speed = tower.get_stat("sylv_shield","shockwave_speed")
			shockwave_max_hp = tower.get_stat("sylv_shield","shockwave_max_hp")
			shockwave_current_hp = tower.get_stat("sylv_shield","shockwave_current_hp")
			shockwave_cooldown = tower.get_stat("sylv_shield","shockwave_cooldown")
			shield_max_hp = shockwave_max_hp		
			%Timer.wait_time = min(%Timer.wait_time,shockwave_cooldown)
		"bloom":			
			tower.add_dynamic_buff("rage_lv1",5.0)
			print(StatFamilies.stat_match("damage","rock_damage"))			
		_:
			shield_max_hp = tower.get_stat("sylv_shield","shield_max_hp")
			shield_regen = tower.get_stat("sylv_shield","shield_regen")
			shield_regen_interval = tower.get_stat("sylv_shield","shield_regen_interval")
			%Timer.wait_time = shield_regen_interval
func absorb_damage(damage: float) -> float:
	if mode=="shockwave" and is_active == true:	
		shockwave_pool += shockwave_damage_incremental
		if shockwave_pool > shockwave_damage_limit:
			shockwave_pool = shockwave_damage_incremental			
	if shield_current_hp <= 0:
		return damage
	
	var absorbed = min(damage,shield_current_hp)
	if shield_current_hp - absorbed <=0:
		Events.shield_broken.emit()
	shield_current_hp -= absorbed	
	trigger_behavior(shield_current_hp)
	return damage - absorbed

func trigger_behavior(current_hp):
	if current_hp > 0:
		is_active = true
		$Sprite2D.visible=true		
	else:
		is_active = false
		$Sprite2D.visible = false
	
	if mode =="shockwave": 
		if is_active==true:
			%Timer.stop()
		else:
			%Timer.wait_time = shockwave_cooldown
			%Timer.start()	
	Events.shield_changed.emit()	
	

func _on_timer_timeout() -> void:
	if mode=="shockwave":
		reload_shield()
	else:	
		heal(shield_regen)

func heal(value):
	shield_current_hp += value
	shield_current_hp = min(shield_current_hp,shield_max_hp)
	trigger_behavior(shield_current_hp)
func reload_shield():	
	shield_current_hp = shockwave_max_hp
	trigger_behavior(shield_current_hp)
	
func _on_shield_broke():		
		if mode=="shockwave" :
			var stats :Dictionary 
			stats =	{
			"damage":shockwave_pool,
			"shockwave_radius":shockwave_radius,
			"shockwave_speed":shockwave_speed 				
			}
			shockwave_pool=0
			trigger_shockwave(stats)		
			

#mode shockwave
func trigger_shockwave(stats: Dictionary):
	var shockwave = Gamedata.SHOCKWAVE.instantiate()
	shockwave.global_position = global_position
	shockwave.setup(stats)
	get_tree().current_scene.add_child(shockwave)
