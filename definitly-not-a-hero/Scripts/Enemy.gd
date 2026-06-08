extends CharacterBody2D
#DATA---------------------
#stats
var enemy_data = {} #contient les donnés Json
var stats = {} #contient les iables XP/GOLD ETC
var speed:int
var base_speed:int
var max_hp:float
var current_hp:float
var gold:int
var xp:int
var damage
#parametres
var player
var slowed_amount = 0.0
var is_in_range = false
var attack_range=250
var timer_activated = false
var direction
@onready var death_area: Area2D = $deatharea
@onready var death_collider: CollisionShape2D = $deatharea/deathCollider

#debuff
var is_stunned
var is_eroded
var is_slowed
var is_rooted
var is_binded
var bind_ratio :float = 0.1
#damages
var active_dots: Array = []
var active_debuff: Array = []
var weaknesses : Array = []
var resistances : Array = []
var stacked_effects: Dictionary = {}
var already_diying: bool = false
var on_hit_weak_or_resist: String =""
var damage_source
#modifier
var modifiers : Array = []
var modifierinstances : Array = []
#dashmodifier
var override_speed :int = 0
var is_overriding_movement := false
var debug_label
#split modifier
var is_sub_mob = false


const XP_ORB = preload("res://Scenes/collectable/xp_orb.tscn")
const GOLD_COIN = preload("res://Scenes/collectable/gold_coin.tscn")
#DEPENDENCIES
#-------------------------


func _process(delta: float) -> void:		
	#gestion des modifiers	
	for mod in modifierinstances:
		if has_method("process"):
			mod._process(delta)		
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
	elif is_stunned:
		velocity = Vector2.ZERO		
	else:	
			if override_speed != 0 :
				if direction != null and override_speed !=null:
					velocity = direction * override_speed 
			else:
				direction = global_position.direction_to(player.global_position)
				velocity = direction * speed 
				#if not is_attack_player:
			var collide = move_and_collide(velocity * delta)
			if collide:
				is_in_range=true			
	
	#GERSTIONNAIRE DES DOTS
	update_dots(delta)	
	#gestionnaire des debuffs
	update_debuffs(delta)
	active_debuff = active_debuff.filter(func(d):
		return d.active or d.cooldown_left > 0)
	
#region damage manager					
func take_damage(damage:float, damage_type: String,damage_source: Variant=null,can_bind:bool = false):
	var damage_data = {
		"damage": damage,
		"damage_type": damage_type,
		"damage_source": damage_source,
		"can_bind":can_bind
	}
	if is_binded and damage_data.can_bind:
		if player.Tower.unlocked_skills.has("root_aura"):
			bind_ratio = player.Tower.get_stat("root_aura","binding_damage_limit")
		propagate_bind_damage(damage*bind_ratio)			
		
		
	for mod in modifierinstances.duplicate():
		if mod.has_method("on_hit"):
			damage_data = mod.on_hit(damage_data)
	if damage_data.damage <= 0:
		return 
		
	#%Animation.play("hurt")
	set_hit_type(damage_type)
	
	%hit_type.emitting = true
	var final_damage = compute_type_damage(damage_data.damage, damage_data.damage_type)
	DamageManager.spawn(global_position, damage_data.damage, damage_data.damage_type,on_hit_weak_or_resist)
	current_hp-=damage_data.damage
	if current_hp<=0:	
		die()

func propagate_bind_damage(damage):
	var binded =get_tree().get_nodes_in_group("binded")
	for enemy in binded:
		if enemy == self:
			continue			
		enemy.take_damage(damage,"bind",null,false)

func heal(amount:float):
	#si jamais supérieur a max hp on garde maxhp 
	current_hp = min(current_hp+amount,max_hp)
	DamageManager.spawn(global_position, amount, "heal" ,"")

	

func apply_dot(damage: float, duration: float, tick_rate: float ,damage_type: String, source: String ):
	active_dots.append({
		"damage": damage,
		"duration": duration,
		"tick_rate": tick_rate,
		"elapsed": 0.0,
		"tick_elapsed": 0.0,
		"damage_type":damage_type,
		"source": source
	})
func update_dots(delta):
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
			
func apply_debuff(duration :float,cooldown: float ,debuff_name: String,value = null):
	for debuff in active_debuff:
		if debuff.name == debuff_name:
			return  # déjà appliqué ou en cooldown
	active_debuff.append({		
		"name": debuff_name,
		"duration": duration,
		"time_left":duration,
		"cooldown": cooldown,
		"cooldown_left": cooldown,
		"value":value,
		"active": true
	})

func update_debuffs(delta):
	for debuff in active_debuff:		
		if debuff.active:
			debuff.time_left -= delta			
			if debuff.time_left <= 0:
				debuff.active = false
				debuff.cooldown_left = debuff.cooldown		
		else:
			debuff.cooldown_left -= delta
	compute_debuffs()
			
func compute_debuffs():
	#ajouter ici les parametres:
	is_stunned = false	
	is_eroded = false
	is_slowed = false
	is_rooted = false
	for debuff in active_debuff:
		if not debuff.active:
			continue		
		match debuff.name:
			"stun":
				is_stunned = true
			"erode":
				is_eroded = true
			"slow":
				is_slowed=true
				apply_slow(debuff.value,debuff.duration)
			"rooted":
				is_rooted=true	
			"binded":
				is_binded=true
				add_to_group("binded")
		
func compute_type_damage(damage: float, damage_type: String) -> float:
	# Par défaut, pas de modification
	var multiplier = 1.0
	# Vérifie si le type existe dans le JSON de l'ennemi
	if "weaknesses" in stats and damage_type in stats["weaknesses"]:
		multiplier *= 1.5  # +50% dégâts
		on_hit_weak_or_resist = "weaknesses"
	if not is_eroded:
		if "resistances" in stats and damage_type in stats["resistances"]:
			multiplier *= 0.5  # -50% dégâts
			on_hit_weak_or_resist = "resistances"
	return damage * multiplier

func set_hit_type(damage_type):
	match damage_type:
		"physical": 
			%hit_type.color = Color("ff1119")
		"fire":
			%hit_type.color = Color("ffa119")
		"thorn":
			%hit_type.color = Color("077384")
		"thunder":
			%hit_type.color = Color("abab16ff")
func attack():
	if player and player.has_method("take_damage"):
		player.take_damage(damage)

func die() -> void:
	for body in death_area.get_overlapping_bodies():
		print("Detected body:", str(body))
		
	if not already_diying:
		if not is_sub_mob:
			Events.enemy_died.emit()
			already_diying=true
			for mod in modifierinstances.duplicate():
				if mod.has_method("on_death"):
					mod.on_death()
			spawn_gold(gold)
			spawn_xp_orb(xp)
			if is_rooted:			
				Events.growth_root.emit()
	if player.Tower.unlocked_skills.has("rafflesia_guardian"):
		player.Tower.try_death_summon_skill("rafflesia_guardian",global_position)	
	queue_free()
	

#endregion
	
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
		weaknesses = stats.get("weaknesses", []).duplicate(true)
		resistances = stats.get("resistances", []).duplicate(true)
		player = get_tree().get_first_node_in_group("player")
		current_hp = max_hp
		modifiers = stats.get("modifiers", []).duplicate(true)
		death_collider.shape.radius = stats["death_collider_radius"]

	for mod_data in modifiers:
		var mod = ModifierManager.create(mod_data)
		mod.attach(self)
		modifierinstances.append(mod)
		settingdeathCollider(mod_data)

func settingdeathCollider(data:Dictionary):
	match data.type:
		"healondeath":
			death_area.collision_mask |= 1<<1
		"explosionondeath":
			death_area.collision_mask |= 1<<0
			
func apply_slow(percent :float , duration :float):
	print("speed : "+ str(speed))
	slowed_amount = max(slowed_amount, percent) # garde le plus fort slow
	speed = base_speed * (1.0 - slowed_amount)
	print("apply : "+ str(slowed_amount))
	print("speed : "+ str(speed))
	await get_tree().create_timer(duration).timeout	
	remove_slow(percent)


func remove_slow(percent):
	#slowed_amount = max(0.0, slowed_amount - percent)
	#speed = speed * (1.0 - slowed_amount)
	#print("apply slow : "+str((1.0 - slowed_amount)))
	speed = base_speed

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
