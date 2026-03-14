extends CharacterBody2D
#DATA---------------------
var enemy_data = {} #contient les donnés Json
var stats = {} #contient les iables XP/GOLD ETC
var speed
var base_speed
var max_hp
var gold
var xp
var damage
var player
var slowed_amount = 0.0
var is_in_range = false
var attack_range=100
var timer_activated = false
var active_dots: Array = []

const XP_ORB = preload("res://Scenes/collectable/xp_orb.tscn")
const GOLD_COIN = preload("res://Scenes/collectable/gold_coin.tscn")
#DEPENDENCIES
#-------------------------

func _process(delta: float) -> void:		
	var dist = global_position.distance_to(player.global_position)
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
			take_damage(dot["damage"])
		if dot["elapsed"] >= dot["duration"]:
			active_dots.erase(dot)
						
func take_damage(damage):
	%Animation.play("hurt")
	%blood.emitting = true
	max_hp-=damage
	if max_hp<=0:	
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

func attack():
	if player and player.has_method("take_damage"):
		player.take_damage(damage)

func die() -> void:
	Events.enemy_died.emit()
	spawn_gold(gold)
	spawn_xp_orb(xp)
	queue_free()
	
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
		player = get_tree().get_first_node_in_group("player")

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
