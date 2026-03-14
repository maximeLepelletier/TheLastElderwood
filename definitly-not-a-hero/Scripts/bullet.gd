extends Area2D
var speed = 1200
var RANGE = 800
var travelled_distance= 0
var bullet_damage = 0

func setup(stats: Dictionary) -> void:
	bullet_damage = stats.get("damage", 0.0)
	speed = stats.get("speed", 0.0)
	RANGE = stats.get("range", 0.0)
	
func _physics_process(delta: float) -> void:
	var direction = Vector2.RIGHT.rotated(rotation-PI/2)
	position += direction * speed * delta
	travelled_distance += speed * delta
	if travelled_distance>=RANGE:
		queue_free()

func _on_body_entered(body: Node2D) -> void:
	queue_free()
	if body.has_method("take_damage"):
		body.take_damage(bullet_damage)
		
func set_damage(value: int) -> void:
	bullet_damage = value

func set_speed(value: int) -> void:
	speed = value
	
func set_range(value: int) -> void:
	RANGE = value
