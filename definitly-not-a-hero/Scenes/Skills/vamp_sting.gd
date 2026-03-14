extends Area2D
var Speed 
var RANGE 
var scaling = 1
var travelled_distance= 0
var bullet_damage 
var enemy_hitted = 0
var heal_amount 
var shooting_position
var player
var maxrange_flip
var direction

@onready var sprite_2d: Sprite2D = $Sprite2D

func setup(stats: Dictionary) -> void:
	bullet_damage = stats.get("damage", 0.0)
	heal_amount = stats.get("heal", 0.0)
	Speed = stats.get("speed", 0.0)
	RANGE = stats.get("range", 0.0)
	
func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")
	
func _physics_process(delta: float) -> void:
	if not maxrange_flip:
		direction = Vector2.RIGHT.rotated(rotation-PI/2)
	else:
		sprite_2d.flip_h=true
		sprite_2d.flip_v=true
		direction = -Vector2.RIGHT.rotated(rotation-PI/2)
	position += direction * Speed * delta
	travelled_distance += Speed * delta
	if travelled_distance>=RANGE:
		maxrange_flip=true
		if player.global_position.distance_to(global_position) < 20:
			player.heal(heal_amount * enemy_hitted)
			print("vamp_sting soin par ennemi touché :" + str(heal_amount))
			print("vamp_sting soin ! heal :" + str(heal_amount * enemy_hitted))
			queue_free()

func _on_body_entered(body: Node2D) -> void:
	enemy_hitted+=1
	print("vamp_sting touché ! damages :" + str(bullet_damage))
	if body.has_method("take_damage"):
		body.take_damage(bullet_damage)
	
func set_damage(value: int) -> void:
	bullet_damage = value

func set_speed(value: int) -> void:
	Speed = value

func set_range(value: int) -> void:
	RANGE = value
