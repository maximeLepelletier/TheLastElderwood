extends Node2D

# --- Stats du skill ---
var damage: float = 0.0
var damage_per_tick: float = 0.0
var dot_duration: float = 0.0
var radius: float = 1.0
var duration: float = 3.0
var speed: float = 200.0
var fire_rate: float = 0.5
#mode
var mode :String=""
#RAZOR
var razor_tick_rate: float = 0
var razor_crit_rate:float = 0
var razor_damage: float = 0.0
#Sand
var sand_damage: float =0
var sand_slow :float = 0
var sand_debuff_duration :float = 0
var sand_debuff_cooldown: float = 0
var sand_tick_rate: float = 0
# direction du vent
var direction: Vector2 = Vector2.UP

# ennemis présents dans la zone
var enemies_in_area: Array = []

# --------------------------------------------------
# SETUP (appelé au spawn du skill)
# --------------------------------------------------
func setup(stats: Dictionary) -> void:

	damage = stats.get("damage", 0.0)
	damage_per_tick = stats.get("damage_per_tick", 0.0)
	dot_duration = stats.get("dot_duration", 0.0)
	radius = stats.get("radius", 0.0)
	duration = stats.get("duration", 0.0)
	speed = stats.get("speed", 0)
	fire_rate = stats.get("dot_rate", 0)
	mode = stats.get("mode", "")
	#RAZOR
	razor_crit_rate = stats.get("razor_crit_rate", 0)
	razor_damage = stats.get("razor_damage", 0.0)
	razor_tick_rate = stats.get("razor_tick_rate", 0)
	#SAND
	sand_damage = stats.get("sand_damage", 0.0)
	sand_slow = stats.get("sand_slow", 0)
	sand_debuff_duration = stats.get("sand_debuff_duration", 0)
	sand_debuff_cooldown =stats.get("sand_debuff_cooldown", 0)
	sand_tick_rate =stats.get("sand_tick_rate", 0)
	apply_mode(mode)
	$Timer.wait_time= duration
	
	
	



# --------------------------------------------------
# Mouvement de la tempête
# --------------------------------------------------

func _physics_process(delta):
	position += direction * speed * delta

# --------------------------------------------------
# Appliquer la taille de la zone
# --------------------------------------------------
func up_scale():
	#var shape = $Area2D/CollisionShape2D.shape
	#if shape is CircleShape2D:
		#shape.radius *= radius
	scale.x = radius	
	scale.y = radius
	apply_particles()
# --------------------------------------------------
# Adapter le mode de leaf_storm : normal / razor / sand
# --------------------------------------------------
func apply_mode(skill_mode:String):
	match skill_mode:
		"razor":
			convert_to_razor()
		"sand":
			convert_to_sand()
		_:
			up_scale()

func convert_to_razor():
	damage = razor_damage
	$leaf_Particle.color_initial_ramp =set_particle_gradient(Color("494949ff"),Color("979797ff"))
	$trail_Particle.color_initial_ramp =set_particle_gradient(Color("494949ff"),Color("979797ff"))

func convert_to_sand():
	$tick_rate.wait_time = sand_tick_rate
	damage = sand_damage
	$leaf_Particle.color_initial_ramp =set_particle_gradient(Color("e2b013ff"),Color("876906ff"))
	$trail_Particle.color_initial_ramp =set_particle_gradient(Color("e2b013ff"),Color("876906ff"))
	up_scale()

# --------------------------------------------------
# Adapter les particules au radius
# --------------------------------------------------

func apply_particles():
	if $leaf_Particle:
		$leaf_Particle.emission_sphere_radius *= radius
	if $trail_Particle:
		$trail_Particle.emission_sphere_radius *= radius

# --------------------------------------------------
# Durée de vie du sort
# --------------------------------------------------

func _on_timer_timeout() -> void:
	queue_free()

# --------------------------------------------------
# Détection ennemis
# --------------------------------------------------

func _on_area_2d_body_entered(body: Node2D) -> void:
		enemies_in_area.append(body)
		apply_hit(body)

func _on_area_2d_body_exited(body: Node2D) -> void:
	if enemies_in_area.has(body):
		enemies_in_area.erase(body)

# --------------------------------------------------
# Hit initial + DOT
# --------------------------------------------------

func apply_hit(enemy):

	if not enemy:
		return

	if enemy.has_method("take_damage"):
		if randf()< razor_crit_rate: 	
			enemy.take_damage(damage * 1.35,"crit")
		else:
			enemy.take_damage(damage,"physical")

	if mode == "":
		if enemy.has_method("apply_dot"):
			enemy.apply_dot(damage_per_tick,dot_duration,fire_rate,"blunt","leaf_storm")
	if mode == "sand":
		if enemy.has_method("apply_debuff"):
			enemy.apply_debuff(sand_debuff_duration,sand_debuff_cooldown ,"erode")
			enemy.apply_debuff(sand_debuff_duration,sand_debuff_cooldown ,"slow",sand_slow)
# --------------------------------------------------
# Tick damage pendant la tempête
# --------------------------------------------------

func _on_tick_rate_timeout() -> void:
	if mode!="":
		for enemy in enemies_in_area:
			if is_instance_valid(enemy) and enemy.has_method("take_damage"):
				enemy.take_damage(damage,"physical")
	else:
		return

func set_particle_gradient(start : Color , end : Color):

	var gradient := Gradient.new()

	gradient.add_point(0,start)
	gradient.add_point(1,end)

	$leaf_Particle.color_initial_ramp = gradient
