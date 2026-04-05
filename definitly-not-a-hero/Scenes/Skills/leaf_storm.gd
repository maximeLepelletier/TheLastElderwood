extends Node2D

# --- Stats du skill ---
var damage: float = 0.0
var damage_per_tick: float = 0.0
var dot_duration: float = 0.0
var radius: float = 1.0
var duration: float = 3.0
var speed: float = 200.0
var fire_rate: float = 0.5

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
	up_scale()
	$Timer.wait_time= duration
	apply_particles()



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

# --------------------------------------------------
# Adapter les particules au radius
# --------------------------------------------------

func apply_particles():
	if $leaf_Particle:
		$leaf_Particle.emission_sphere_radius *= radius
	if $trail_Particle:
		$leaf_Particle.emission_sphere_radius *= radius

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
		enemy.take_damage(damage,"physical")

	if enemy.has_method("apply_dot"):
		enemy.apply_dot(damage_per_tick,dot_duration,fire_rate,"blunt","leaf_storm")

# --------------------------------------------------
# Tick damage pendant la tempête
# --------------------------------------------------

func _on_tick_timer_timeout():

	for enemy in enemies_in_area:
		if is_instance_valid(enemy) and enemy.has_method("take_damage"):
			enemy.take_damage(damage,"physical")
