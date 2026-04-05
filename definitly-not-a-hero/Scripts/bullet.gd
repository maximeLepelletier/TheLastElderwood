extends Area2D
var speed = 1200
var RANGE = 800
var travelled_distance :float = 0
var bullet_damage :float = 0
var mode = "physical"
var damage_per_tick :float = 0
var dot_duration :float =0
var dot_rate :float =0
var explosion_radius :float
var explosion_damage :float
var explosion_count :int =1
var damage_storage :float
var thorn_max_count :int

func setup(stats: Dictionary) -> void:
	bullet_damage = stats.get("damage", 0.0)
	speed = stats.get("speed", 0.0)
	RANGE = stats.get("range", 0.0)
	mode = stats.get("mode", 0.0)
	damage_per_tick = stats.get("damage_per_tick", 0.0)
	dot_duration = stats.get("dot_duration", 0.0)
	dot_rate = stats.get("dot_rate", 0.0)
	explosion_radius = stats.get("explosion_radius", 0.0)
	explosion_damage = stats.get("explosion_damage", 0.0)
	explosion_count= stats.get("explosion_count", 1)
	damage_storage = stats.get("damage_storage", 1)
	thorn_max_count = stats.get("thorn_max_count", 1)
	set_mode(mode)

	
func _physics_process(delta: float) -> void:
	var direction = Vector2.RIGHT.rotated(rotation-PI/2)
	position += direction * speed * delta
	travelled_distance += speed * delta
	if travelled_distance>=RANGE:
		queue_free()

func _on_body_entered(body: Node2D) -> void:
	queue_free()	
	if body.has_method("take_damage"):
		body.take_damage(bullet_damage,mode)
	match mode:
		"fire":
			if body.has_method("apply_dot"):
				body.apply_dot(damage_per_tick, dot_duration, dot_rate ,mode,mode)
		"explosion":
			call_deferred("explode")			
		"thorn":
			if body.has_method("add_stack"):
				body.add_stack("thorn", damage_storage, thorn_max_count)
				
func explode():
	var explosion = Gamedata.EXPLOSION.instantiate()
	get_tree().current_scene.add_child(explosion)
	explosion.global_position = global_position

	explosion.setup({
		"damage": explosion_damage,
		"radius": explosion_radius,
		"shockwave_time": 0.25,
		"explosion_count": explosion_count,
		"damage_type": "explosion"
	})
	queue_free()

		
func set_mode(mode: String)-> void:
	match mode:
		"fire":
			enable_fire()
		"explosion":
			enable_explosion()
		"thorn":
			enable_thorn()
		"":
			return

		
func enable_fire():
	modulate = Color("ff4700")
	#$mode.texture = preload("res://Assets/textures/fire_01.png")
	#$mode.color = Color("ff4700")
func enable_explosion():
	modulate = Color("eaea25")
	#$mode.texture = preload("res://Assets/textures/fire_01.png")
	#$mode.color = Color("eaea25")
func enable_thorn():
	modulate = Color("077384")
	#$mode.texture = preload("res://Assets/textures/fire_01.png")
	#$mode.color = Color("077384")
	
func set_damage(value: int) -> void:
	bullet_damage = value

func set_speed(value: int) -> void:
	speed = value
	
func set_range(value: int) -> void:
	RANGE = value
