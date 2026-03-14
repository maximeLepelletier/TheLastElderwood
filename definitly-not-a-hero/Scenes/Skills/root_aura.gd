extends Area2D

var damage_per_tick: float 
var slow_percent: float 
var tick_rate: float 
var owner_tower: Node = null
var enemies_in_zone: Array = []
var radius:float = 1
@onready var timer: Timer = $Timer

func setup(tower: Node) -> void:
	owner_tower = tower
	_refresh_from_tower()

func _refresh_from_tower() -> void:
	if not owner_tower:
		return
	radius= owner_tower.get_stat("root_aura","radius")
	scale.x = radius
	scale.y = radius
	
	timer.wait_time = owner_tower.get_stat("root_aura", "fire_rate")
	print("timer root_aura : " + str(timer.wait_time))
	if timer.is_stopped():
			timer.start()

func _on_timer_timeout() -> void:
	if not owner_tower:
		return
	# attribution des degats
	damage_per_tick = owner_tower.get_stat("root_aura", "damage_per_tick")
	
	for enemy in enemies_in_zone:
		if enemy and enemy.is_inside_tree():
			if enemy.has_method("take_damage"):
				enemy.take_damage(damage_per_tick) # Replace with function body.
				print ("root_aura dmg : "+ str(damage_per_tick))

func _on_body_entered(body: Node2D) -> void:
	slow_percent = owner_tower.get_stat("root_aura", "slow_percent")
	if body.is_in_group("enemy"):
		enemies_in_zone.append(body)
		if body.has_method("apply_slow"):
			body.apply_slow(slow_percent)

func _on_body_exited(body: Node2D) -> void:
	slow_percent = owner_tower.get_stat("root_aura", "slow_percent")
	if body.is_in_group("enemy"):
		enemies_in_zone.erase(body)
		if body.has_method("remove_slow"):
			body.remove_slow(slow_percent)
			
