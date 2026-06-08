extends Area2D

var damage_per_tick: float 
var slow_percent: float 
var tick_rate: float 
var owner_tower: Node = null
var enemies_in_zone: Array = []
var radius:float = 1
var mode :String = ""
var current_level :int
#overgrowth
var enemy_growth_killed :float =0
var overgrowth_kill_ratio :float =0
var overgrowth_damage :float =0
var overgrowth_tickrate :float =0
var overgrowth_radius :float =0
var overgrowth_level :float =0
var overgrowth_scale_damage :float =0

@onready var timer: Timer = $Timer

func setup(tower: Node) -> void:	
	owner_tower = tower
	Events.growth_root.connect(root_growth_up)
	Events.wave_counter.connect(root_level_growth_up)
	_refresh_from_tower()

func _refresh_from_tower() -> void:
	if not owner_tower:
		return
	mode = owner_tower.get_property("root_aura", "mode")
	apply_mode(mode)

func apply_mode(skill_mode:String):
	match skill_mode:
		"growth":
			convert_to_growth()
		"binding":
			convert_to_binding()
		_:
			basic_mode()
		
func basic_mode():
	damage_per_tick = owner_tower.get_stat("root_aura", "damage_per_tick")
	radius= owner_tower.get_stat("root_aura","radius")
	scale.x = radius
	scale.y = radius
	timer.wait_time = owner_tower.get_stat("root_aura", "fire_rate")
	
	print("timer root_aura : " + str(timer.wait_time))
	if timer.is_stopped():
			timer.start()
	
func convert_to_growth():
	
	damage_per_tick = owner_tower.get_stat("root_aura", "overgrowth_damage") + (enemy_growth_killed* owner_tower.get_stat("root_aura", "overgrowth_scale_damage"))
	tick_rate = owner_tower.get_stat("root_aura", "overgrowth_tickrate")	
	radius = owner_tower.get_stat("root_aura", "overgrowth_radius") * (1 +(enemy_growth_killed*owner_tower.get_stat("root_aura", "overgrowth_kill_ratio")) + ((current_level*owner_tower.get_stat("root_aura", "overgrowth_level"))))
	scale.x = radius
	scale.y = radius
	timer.wait_time = tick_rate

func convert_to_binding():
	damage_per_tick = owner_tower.get_stat("root_aura", "binding_damage") 
	tick_rate = owner_tower.get_stat("root_aura", "tickrate")	
	radius = owner_tower.get_stat("root_aura", "binding_radius") 
	scale.x = radius
	scale.y = radius
	timer.wait_time = tick_rate		
	

func _on_timer_timeout() -> void:
	if not owner_tower:
		return
	
	for enemy in enemies_in_zone:
		if enemy and enemy.is_inside_tree():
			if enemy.has_method("take_damage"):
				enemy.take_damage(damage_per_tick,"physical",self) # Replace with function body.
				print ("root_aura dmg : "+ str(damage_per_tick))

func _on_body_entered(body: Node2D) -> void:
	slow_percent = owner_tower.get_stat("root_aura", "slow_percent")
	if body.is_in_group("enemy"):
		enemies_in_zone.append(body)
		if body.has_method("apply_debuff"):
			match mode:
				"":
					body.apply_debuff(20,0,"slow",slow_percent)
				"growth":
					body.apply_debuff(1,0,"rooted")
				"binding":
					body.apply_debuff(1,0,"binded")	


func _on_body_exited(body: Node2D) -> void:
	slow_percent = owner_tower.get_stat("root_aura", "slow_percent")
	if body.is_in_group("enemy"):
		enemies_in_zone.erase(body)
		if body.has_method("remove_slow"):
			body.remove_slow(slow_percent)
			
func root_growth_up():
	enemy_growth_killed+=1
	_refresh_from_tower()		
	
func root_level_growth_up():
	current_level+=1
	_refresh_from_tower()		
