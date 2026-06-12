extends Node2D

var damage: float
var radius: float
var shockwave_speed: float = 0

var hit_enemies := []

signal animation_end

@onready var area: Area2D = $Area2D
@onready var collision: CollisionShape2D = $Area2D/CollisionShape2D
@onready var sprite: Sprite2D = $Sprite2D
var current_radius := 0.0
var target_radius := 0.0


func setup(stats: Dictionary):
	damage = stats.get("damage", 1)
	radius = stats.get("radius", 1)
	shockwave_speed = stats.get("shockwave_speed", 300.0)

	trigger_explosion()


func trigger_explosion():

	current_radius = 0.0
	target_radius = radius
	scale = Vector2.ZERO


func _process(delta: float) -> void:

	current_radius += shockwave_speed * delta

	if current_radius >= target_radius:
		emit_signal("animation_end")
		queue_free()
		return
	_update_visuals()


func _update_visuals():

	scale = Vector2(current_radius,current_radius)

	# Le sprite doit être dessiné avec un rayon de référence de 1
	sprite.scale = Vector2.ONE * current_radius


func _apply_damage(target):
	if target == null:
		pass
	if target.is_in_group("enemy"):
		if target.has_method("take_damage"):
			target.take_damage(	damage,"nature",self,true)


func _on_area_2d_body_entered(body: Node2D) -> void:
	_apply_damage(body)
