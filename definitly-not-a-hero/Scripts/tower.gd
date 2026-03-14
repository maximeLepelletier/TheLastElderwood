extends Area2D

@onready var weapon_rotation: Marker2D = $WeaponRotation
@onready var shooting_point: Marker2D = %ShootingPoint
@onready var targetmarker: Sprite2D = %targetmarker

#Visée manuelle
var manual_target_active: bool = false
var manual_target_position: Vector2
var last_aim_position: Vector2
var has_last_aim := false

var unlocked_skills := {}
var skill_upgrades_count:={}
var skill_child_instance
var bonuses := {}
var multipliers := {}
var cumult := {}
#-------------------------------------------------------------------------#
#CIBLAGE ENUMERATOR
#-------------------------------------------------------------------------#
enum TargetMode { CLOSEST, FARTHEST, DENSEST, MANNUAL }
var is_rotating = false
var rotation_threshold = 0.05  # environ 3 degrés

func _ready() -> void:
	%Timer.wait_time = get_stat("bullet","fire_rate")
	unlockSkill("bullet")

#region TARGET
func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		manual_target_active = event.pressed
		if event.pressed:
			manual_target_position = event.position

	elif event is InputEventScreenDrag:	
		manual_target_active = true
		manual_target_position = event.position

	elif event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			manual_target_active = event.pressed
			if event.pressed:
				manual_target_position = event.position

	elif event is InputEventMouseMotion and manual_target_active:
		manual_target_position = event.position
	
	var dir := (manual_target_position - global_position).normalized()
	manual_target_position = global_position + dir * get_stat("bullet","range")
		
func get_world_target_position(manual_target) -> Vector2:	
	return get_global_mouse_position()
	
func _physics_process(_delta: float) -> void:
	var TargetEnnemy = get_target(TargetMode.CLOSEST,manual_target_position)
	update_rotation(TargetEnnemy, _delta)
	if TargetEnnemy == null or is_rotating:
		%Timer.paused=true
		%wood_trunk_Timer.paused=true		
		%vamp_sting_Timer.paused=true
		%sylv_bomb_Timer.paused=true		
	else:
		%Timer.paused=false
		%wood_trunk_Timer.paused=false		
		%vamp_sting_Timer.paused=false		
		%sylv_bomb_Timer.paused=false		

func get_target(mode: TargetMode, origin: Vector2) -> TargetData:
	var t :TargetData
	if manual_target_active:
		t =get_manual_target_data(origin)
		targetmarker.global_position = t.position
		targetmarker.visible = true
		return t
	targetmarker.visible = false	
	return get_auto_target(mode)
	
func update_rotation(target: TargetData, delta: float) -> void:
	if target==null:
		if has_last_aim:
			is_rotating = true
			rotate_toward_position(last_aim_position, delta)
		else:
			is_rotating = false
			has_last_aim = false
		return	
	
	last_aim_position = target.position
	has_last_aim = true	
	rotate_toward_position(target.position, delta)
		
func rotate_toward_position(target_pos: Vector2, delta: float) -> void:
	is_rotating = true
	var dir := target_pos - weapon_rotation.global_position
	if dir.length_squared() == 0:
		is_rotating = false
		return
	var target_angle := dir.angle()
	var desired := target_angle + PI / 2
	weapon_rotation.rotation = lerp_angle(weapon_rotation.rotation,desired,10.0 * delta)
	if abs(angle_difference(weapon_rotation.rotation, desired)) < rotation_threshold:
		weapon_rotation.rotation = desired
		is_rotating = false
		
func get_closest_enemy() -> Node2D:
	var ennemies_in_range = get_overlapping_bodies()
	var closest_enemy = null
	var min_distance = INF
	for enemy in ennemies_in_range:
		if not enemy or not enemy.has_method("get_global_position"):
			continue
		var dist = global_position.distance_to(enemy.global_position)
		if dist < min_distance:
			min_distance = dist
			closest_enemy = enemy
	return closest_enemy

func get_farthest_enemy() -> Node2D:
	var enemies_in_range = get_overlapping_bodies()
	var farthest_enemy = null
	var max_distance = -INF
	for enemy in enemies_in_range:
		if not enemy or not enemy.has_method("get_global_position"):
			continue
		var dist = global_position.distance_to(enemy.global_position)
		if dist > max_distance:
			max_distance = dist
			farthest_enemy = enemy
	return farthest_enemy
	
func get_largest_group_enemy(cluster_radius := 80.0) -> Node2D:
	var enemies = get_overlapping_bodies()
	var best_enemy = null
	var best_count = 0
	for enemy in enemies:
		if not enemy or not enemy.has_method("get_global_position"):
			continue
		var count = 0
		for other in enemies:
			if other == enemy:
				continue
			if enemy.global_position.distance_to(other.global_position) <= cluster_radius:
				count += 1
		if count > best_count:
			best_count = count
			best_enemy = enemy
	return best_enemy
	
func get_auto_target(mode: TargetMode)-> TargetData:
	var t := TargetData.new()
	var target = null
	match mode:
		TargetMode.CLOSEST:
			target= get_closest_enemy()
		TargetMode.FARTHEST:
			target= get_farthest_enemy()
		TargetMode.DENSEST:
			target= get_largest_group_enemy()
	if not target == null:
		t.node = target
		t.position = target.global_position
	else:
		t = null
	return t
	
func get_manual_target_data(origin: Vector2) -> TargetData:
	var t := TargetData.new()
	t.is_manual = true
	t.position = get_world_target_position(origin)
	return t	

#endregion
 
#region SHOOTING
func _on_timer_timeout() -> void:
	var stats: Dictionary
	stats = {
		"damage":get_stat("bullet","damage"),
		"speed":get_stat("bullet","speed"),
		"range":get_stat("bullet","range")
		}
	shoot(Gamedata.BULLET,stats,get_target(TargetMode.CLOSEST,manual_target_position))

func can_shoot() -> bool:
	return not is_rotating and has_last_aim
	
func shoot(projectile,stats: Dictionary,target_position):
	var new_projectile = projectile.instantiate()
	new_projectile.global_rotation = %ShootingPoint.global_rotation	
	new_projectile.global_position = %ShootingPoint.global_position	
	if new_projectile.has_method("setup"):
		new_projectile.setup(stats)
	if new_projectile.has_method("set_target_position"):
		new_projectile.set_target_position(target_position)
	#rend indépendant le projectile tirer pour nepas tourner avec la tour
	var root = get_tree().get_current_scene() 
	root.add_child(new_projectile)

func _on_wood_trunk_timer_timeout() -> void:
	var stats : Dictionary
	stats = {
	"damage":get_stat("wood_trunk","damage"),
	"speed":get_stat("wood_trunk","speed"),
	"range":get_stat("wood_trunk","range"),
	"scale":get_stat("wood_trunk","scale")
	}
	shoot(Gamedata.WOOD_TRUNK,stats,get_target(TargetMode.FARTHEST,manual_target_position))

func _on_vamp_sting_timer_timeout() -> void:
	var stats: Dictionary
	stats = {
		"damage":get_stat("vamp_sting","damage"),
		"speed":get_stat("vamp_sting","speed"),
		"range":get_stat("vamp_sting","range"),
		"heal":get_stat("vamp_sting","heal")
		}
	shoot(Gamedata.VAMP_STING,stats,get_target(TargetMode.FARTHEST,manual_target_position))

func _on_sylv_bomb_timer_timeout() -> void:
	var stats: Dictionary
	stats = {
		"damage":get_stat("sylv_bomb","damage"),
		"speed":get_stat("sylv_bomb","speed"),
		"radius":get_stat("sylv_bomb","radius")			
		}
	shoot(Gamedata.MARKER,stats,get_target(TargetMode.FARTHEST,manual_target_position))


func _on_leaf_storm_timer_timeout() -> void:
	var stats: Dictionary
	stats = {
		"damage": get_stat("leaf_storm","damage"),
		"damage_per_tick":get_stat("leaf_storm","damage_per_tick"),
		"dot_duration": get_stat("leaf_storm","dot_duration"),
		"duration":get_stat("leaf_storm","duration"),
		"radius":get_stat("leaf_storm","radius"),
		"dot_rate":get_stat("leaf_storm","dot_rate"),
		"speed":get_stat("leaf_storm","speed"),
		"fire_rate":get_stat("leaf_storm","fire_rate")
		}
	shoot(Gamedata.LEAF_STORM,stats,get_target(TargetMode.CLOSEST,manual_target_position))


#endregion

#region UPGRADES
func has_skill(skill_ID) -> bool:
	return unlocked_skills.has(skill_ID)
	
func get_upgrade_count(skill: String) -> int:
	return skill_upgrades_count.get(skill, 0)

func unlockSkill(skill_ID):
	var skills = Node2D
	if skill_ID == "bullet":
		skills = Gamedata.BULLET 
		skill_child_instance = skills.instantiate()
		add_child(skill_child_instance)
		#unlocked_skills[skill_ID]=skills
		unlocked_skills[skill_ID] = {"scene": skills,"instance": skill_child_instance}
	if skill_ID == "root_aura":
		skills = Gamedata.ROOT_AURA 
		skill_child_instance = skills.instantiate()
		add_child(skill_child_instance)
		skill_child_instance.setup(self)
		#unlocked_skills[skill_ID]=skills	
		unlocked_skills[skill_ID] = {"scene": skills,"instance": skill_child_instance}
	if skill_ID == "wood_trunk":
		skills = Gamedata.WOOD_TRUNK
		%wood_trunk_Timer.wait_time = get_stat("wood_trunk","fire_rate")
		%wood_trunk_Timer.start()
		skill_child_instance = skills.instantiate()
		unlocked_skills[skill_ID] = {"scene": skills,"instance": skill_child_instance}
	if skill_ID == "vamp_sting":
		skills = Gamedata.VAMP_STING
		%vamp_sting_Timer.wait_time = get_stat("vamp_sting","fire_rate")
		%vamp_sting_Timer.start()
		skill_child_instance = skills.instantiate()
		#unlocked_skills[skill_ID]=skills
		unlocked_skills[skill_ID] = {"scene": skills,"instance": skill_child_instance}
	if skill_ID == "sylv_bomb":
		skills = Gamedata.SYLV_BOMB
		%sylv_bomb_Timer.wait_time = get_stat("sylv_bomb","fire_rate")
		%sylv_bomb_Timer.start()
		#unlocked_skills[skill_ID]=skills
		unlocked_skills[skill_ID] = {"scene": skills,"instance": skill_child_instance}
	if skill_ID == "leaf_storm":
		skills = Gamedata.LEAF_STORM
		%leaf_storm_Timer.wait_time = get_stat("leaf_storm","fire_rate")
		%leaf_storm_Timer.start()
		#unlocked_skills[skill_ID]=skills
		unlocked_skills[skill_ID] = {"scene": skills,"instance": skill_child_instance}
	if skill_ID == "sylv_shield":
		skills = Gamedata.SYLV_SHIELD
		skill_child_instance=skills.instantiate()
		add_child(skill_child_instance)
		#unlocked_skills[skill_ID]=skills
		unlocked_skills[skill_ID] = {"scene": skills,"instance": skill_child_instance}
		Events.shield_unlock.emit(get_stat("sylv_shield","max_hp"),get_stat("sylv_shield","regen"))
	if not skill_upgrades_count.has(skill_ID):
		skill_upgrades_count[skill_ID] = 0
		
func upgradeSkill(base_skill: String, skill_upgrade: String, data_value: float) -> void:
	# comptage
	skill_upgrades_count[base_skill] = skill_upgrades_count.get(base_skill, 0) + 1
	skill_upgrades_count[skill_upgrade] = skill_upgrades_count.get(skill_upgrade, 0) + 1
	if not unlocked_skills.has(base_skill):
		push_warning("Base skill '%s' non trouvé" % base_skill)
		return
	# mapping upgrade → stat impactée
	var upgrade_map = {
		"fire_rate_plus":       { "stat": "fire_rate", "mode": "cumult" },
		"damage_plus":       	{ "stat": "damage", "mode": "add" },
		"root_damage_up":       { "stat": "damage_per_tick", "mode": "cumult" },
		"root_fire_rate_up":    { "stat": "fire_rate", "mode": "cumult" },
		"root_radius_up":       { "stat": "radius", "mode": "add" },
		"root_slow_up":         { "stat": "slow_percent", "mode": "cumult" },
		"wood_trunk_damage_up": { "stat": "damage", "mode": "cumult" },
		"wood_trunk_speed_up":  { "stat": "speed",  "mode": "cumult" },		
		"wood_trunk_size_up":  { "stat": "scale",  "mode": "cumult" },
		"wood_trunk_fire_rate_up":  { "stat": "fire_rate",  "mode": "cumult" },
		"vamp_sting_heal_up":   { "stat": "heal",   "mode": "cumult" },
		"vamp_sting_speed_up":  { "stat": "speed",  "mode": "cumult" },
		"vamp_sting_damage_up":  { "stat": "damage",  "mode": "cumult" },
		"vamp_sting_fire_rate_up":  { "stat": "fire_rate",  "mode": "cumult" },
		"sylv_bomb_damage_up":  { "stat": "damage", "mode": "cumult" },
		"sylv_bomb_radius_up":  { "stat": "radius", "mode": "cumult" },
		"sylv_shield_tank":     { "stat": "max_hp", "mode": "cumult" },
		"sylv_shield_speed_regen": { "stat": "regen", "mode": "cumult" },
		"leaf_storm_damage_up":  { "stat": "damage",  "mode": "cumult" },
		"leaf_storm_dot_up":  { "stat": "damage_per_tick",  "mode": "cumult" },
		"leaf_storm_duration_up":  { "stat": "duration",  "mode": "cumult" },
		"leaf_storm_dot_time_up":  { "stat": "dot_duration",  "mode": "cumult" },
		"leaf_storm_width_up":  { "stat": "radius",  "mode": "cumult" },

	}

	var upgrade = upgrade_map.get(skill_upgrade)
	if upgrade == null:
		push_warning("Upgrade inconnu: " + skill_upgrade)
		return
	_apply_stat_upgrade(base_skill, upgrade.stat, upgrade.mode, data_value)
	_refresh_skill(base_skill)

func _apply_stat_upgrade(skill: String, stat: String, mode: String, value: float) -> void:
	match mode:
		"add":
			if not bonuses.has(skill):
				bonuses[skill] = {}
			bonuses[skill][stat] = bonuses[skill].get(stat, 0.0) + value
		"mult":
			if not multipliers.has(skill):
				multipliers[skill] = {}
			multipliers[skill][stat] = multipliers[skill].get(stat, 1.0) * value
		"cumult":
			if not cumult.has(skill):
				cumult[skill] = {}
			cumult[skill][stat] = cumult[skill].get(stat, 0) + value
			print("FINAL:" + str(cumult[skill][stat]))
		
	# refresh UI / shield si besoin
	if skill == "sylv_shield":
		Events.update_shield.emit(
			get_stat("sylv_shield", "max_hp"),
			get_stat("sylv_shield", "current_HP"), # ou current hp
			get_stat("sylv_shield", "regen")
		)
		# update Timer si la stat est fire_rate
	if stat == "fire_rate":
		_update_skill_timer(skill)

func apply_upgrade(skill: String, stat: String, value: float):
	if not bonuses.has(skill):
		bonuses[skill] = {}
	bonuses[skill][stat] = bonuses[skill].get(stat, 0) + value

func _update_skill_timer(skill):
	var t: Timer = null
	
	# On récupère le timer correspondant selon le skill
	match skill:
		"bullet":
			t = %Timer
		"wood_trunk":
			t = %wood_trunk_Timer
		"vamp_sting":
			t = %vamp_sting_Timer
		"sylv_bomb":
				t = %sylv_bomb_Timer
		
		_:
			return # pas de timer associé

	if t:
		t.wait_time = get_stat(skill, "fire_rate")
		if t.is_stopped():
			t.start()

func applySuperSkill(base_skill,super_skill_upgrade,data_value):
	print("skill de base ! ", base_skill)
	print("SUPER POWER-UP ! ", super_skill_upgrade)
	print("valeur du super_skill", data_value)
	
#endregion


func get_stat(skill: String, stat: String) -> float:
	return StatsService.get_stat(
		Gamedata.tower_stats.base,
		bonuses,
		cumult,
		multipliers,
		skill,
		stat
	)

func _refresh_skill(skill: String) -> void:
		if skill=="root_aura":
			var aura = unlocked_skills["root_aura"].instance
			if aura :
				aura._refresh_from_tower()
