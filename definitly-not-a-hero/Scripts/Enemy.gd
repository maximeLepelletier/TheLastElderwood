extends CharacterBody2D
#DATA---------------------
var enemy_data = {} #contient les donnés Json
var stats = {} #contient les iables XP/GOLD ETC
var speed:int
var base_speed:int
var max_hp:int
var current_hp:int
var gold:int
var xp:int
var damage
var player
var slowed_amount = 0.0
var is_in_range = false
var attack_range=100
var timer_activated = false
var active_dots: Array = []
var weaknesses : Array = []
var resistances : Array = []
var stacked_effects: Dictionary = {}
var already_diying: bool = false


const XP_ORB = preload("res://Scenes/collectable/xp_orb.tscn")
const GOLD_COIN = preload("res://Scenes/collectable/gold_coin.tscn")
#DEPENDENCIES
#-------------------------


func _process(delta: float) -> void:		
	var dist = global_position.distance_to(player.global_position)
	#gestion flip sprite
	if global_position.x > player.global_position.x:
		%sprite.flip_h=true
	else:
		%sprite.flip_h=false
			
	if dist < attack_range:
		is_in_range = true
	else:
		is_in_range = false
	#ATTACK		
	if is_in_range:
		velocity = Vector2.ZERO
		if not timer_activated:
			%Timer.start()
			timer_activated=true
	else:
		var direction = global_position.direction_to(player.global_position)
		velocity = direction * speed
		#if not is_attack_player:
		var collide = move_and_collide(velocity * delta)
		if collide:
			is_in_range=true
	#GERSTIONNAIRE DES DOTS
	if active_dots.is_empty():
		return
	for dot in active_dots.duplicate():
		dot["elapsed"] += delta
		dot["tick_elapsed"] += delta
		if dot["tick_elapsed"] >= dot["tick_rate"]:
			dot["tick_elapsed"] = 0.0
			take_damage(dot["damage"],dot["source"])
		if dot["elapsed"] >= dot["duration"]:
			active_dots.erase(dot)
						
func take_damage(damage, damage_type: String = "physical"):
	%Animation.play("hurt")
	set_hit_type(damage_type)
	
	%hit_type.emitting = true
	var final_damage = compute_type_damage(damage, damage_type)
	current_hp-=damage
	if current_hp<=0:	
		die()
	

func apply_dot(damage: float, duration: float, tick_rate: float , source: String ):
	active_dots.append({
		"damage": damage,
		"duration": duration,
		"tick_rate": tick_rate,
		"elapsed": 0.0,
		"tick_elapsed": 0.0,
		"source": source
	})
func compute_type_damage(damage: float, damage_type: String) -> float:
	# Par défaut, pas de modification
	var multiplier = 1.0
	# Vérifie si le type existe dans le JSON de l'ennemi
	if "weaknesses" in stats and damage_type in stats["weaknesses"]:
		multiplier *= 1.5  # +50% dégâts
	if "resistances" in stats and damage_type in stats["resistances"]:
		multiplier *= 0.5  # -50% dégâts
	
	return damage * multiplier

func set_hit_type(damage_type):
	match damage_type:
		"physical": 
			%hit_type.color = Color("ff1119")
		"fire":
			%hit_type.color = Color("ffa119")
		"thorn":
			%hit_type.color = Color("077384")
func attack():
	if player and player.has_method("take_damage"):
		player.take_damage(damage)

func die() -> void:
	if not already_diying:
		Events.enemy_died.emit()
		already_diying=true
		spawn_gold(gold)
		spawn_xp_orb(xp)
		queue_free()
	
#region Stacked effect
func add_stack(effect_name: String, value: float, max_stack: int):
	if not stacked_effects.has(effect_name):
		stacked_effects[effect_name] = {
			"stacks": [],
			"max": max_stack
		}	
	var effect = stacked_effects[effect_name]	
	# update du max_effect
	if max_stack > effect.max:
		effect.max = max_stack	

	effect.stacks.append(value)	
	
	if effect.stacks.size() > effect.max:
		effect.stacks.pop_front()
		
	on_effect_updated(effect_name)

func on_effect_updated(effect_name: String):
	match effect_name:
		"thorn":
			handle_thorn()

func handle_thorn():
	var effect = stacked_effects["thorn"]	
	var execution_cap :float = 0
	var handle_thorn_damages:float = 0
	for stack_damage in effect.stacks:
		execution_cap += stack_damage
	handle_thorn_damages = max_hp * (execution_cap / 100.0)
	if effect.stacks.size() >= effect.max:
		trigger_thorn_explosion(handle_thorn_damages)
		effect.stacks.clear()
	
		
func trigger_thorn_explosion(total_damage: float):
	#execute
	if current_hp <= total_damage and current_hp>0:
		die()
		return	
	if not already_diying:
		take_damage(total_damage, "thorn")
#endregion
	
func init(enemy_id: String):
	stats = EnemyManager.get_enemy_stats(enemy_id)
	if stats.is_empty():
		push_error("❌ Enemy data not found for " + enemy_id)
	else:
		max_hp = stats["hp"]
		damage = stats["damage"]
		base_speed = stats["speed"]
		speed=base_speed
		gold = stats["gold_reward"]
		xp = stats["xp_reward"]
		weaknesses = stats.get("weaknesses", [])
		resistances = stats.get("resistances", [])
		player = get_tree().get_first_node_in_group("player")
		current_hp = max_hp

func apply_slow(percent):
	print("speed : "+ str(speed))
	slowed_amount = max(slowed_amount, percent) # garde le plus fort slow
	speed = base_speed * (1.0 - slowed_amount)
	print("apply : "+ str(slowed_amount))
	print("speed : "+ str(speed))

func remove_slow(percent):
	slowed_amount = max(0.0, slowed_amount - percent)
	speed = speed * (1.0 - slowed_amount)
	print("apply slow : "+str((1.0 - slowed_amount)))

func _on_timer_timeout() -> void:
	attack()
	
func spawn_xp_orb(nb_xp):
	for i in range(nb_xp): # nombre d'xp a collecter
		var xp_item = XP_ORB.instantiate()
		xp_item.global_position = global_position
		get_tree().current_scene.add_child(xp_item)
		await 0.15
		
func spawn_gold(nb_gold):
	for i in range(nb_gold): # nombre d'xp a collecter
		var gold_item = GOLD_COIN.instantiate()
		gold_item.global_position = global_position
		get_tree().current_scene.add_child(gold_item)
		await 0.15
