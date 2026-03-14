extends Area2D
var Speed = 1400
var RANGE = 700
var scaling = 1
var travelled_distance= 0
var bullet_damage = 0
var size = 1

func setup(stats: Dictionary) -> void:
	bullet_damage = stats.get("damage", 0.0)
	Speed = stats.get("speed", 0.0)
	RANGE = stats.get("range", 0.0)
	up_scale(stats.get("scale", 0.0))
func _ready() -> void:
	pass
	
func _physics_process(delta: float) -> void:
	var direction = Vector2.RIGHT.rotated(rotation-PI/2)
	position += direction * Speed * delta
	travelled_distance += Speed * delta
	if travelled_distance>=RANGE:
		queue_free()

		
func set_damage(value: int) -> void:
	bullet_damage = value

func set_speed(value: int) -> void:
	Speed = value

func set_range(value: int) -> void:
	RANGE = value

func up_scale(value: float) ->void:
	scale.x *= (size * value)
	scale.y *= (size * value)

func _on_body_entered(body: Node2D) -> void:
	print("Wood_trunk touché ! damages :" + str(bullet_damage))
	if body.has_method("take_damage"):
		body.take_damage(bullet_damage)
	
