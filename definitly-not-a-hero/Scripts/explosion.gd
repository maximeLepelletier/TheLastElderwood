extends Node2D

var damage: float
var radius: float
var shockwave_time: float
var explosion_count: int = 1
var damage_type := "explosion"
var hit_enemies := []
signal animation_end

func setup(stats: Dictionary):

	damage = stats.get("damage", 10.0)
	radius = stats.get("radius",1)
	shockwave_time = stats.get("shockwave_time", 1)
	explosion_count = stats.get("explosion_count", 1)
	damage_type = stats.get("damage_type", "explosion")
	
	# appliquer rayon
	$Area2D/explosionRadius.shape.radius = radius
	animation_end.connect(_on_animation_animation_finished)
	up_scale()
	await get_tree().physics_frame
	trigger_explosion()
	
func trigger_explosion():
	hit_enemies.clear()
	for body in $Area2D.get_overlapping_bodies():
		if body.has_method("take_damage"):
			body.take_damage(damage, damage_type)
			print("ennemy exploded")
			
	$animation.play("boom")
	explosion_count -= 1

func _on_timer_timeout():
	trigger_explosion()

func up_scale():
	$Area2D/explosionRadius.shape.radius= 100 * radius
	scale.x = radius	
	scale.y = radius

func _on_animation_animation_finished() -> void:
	if explosion_count >= 1:
		$Timer.start(shockwave_time)
	else:
			queue_free()
