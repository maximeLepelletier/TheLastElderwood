extends Node2D

var max_height :float = 80
var direction :Vector2
var total_distance
var distance :float
var to_target :Vector2
var progress :float
var start_pos :Vector2
var target
var scaling :float
var stun_duration :float
var stun_damage :float 
var stun_cooldown :float
var speed :float
var params :Dictionary
@onready var shadow :Sprite2D = $shadow

func setup(_params :Dictionary):
	params = _params.duplicate(true)
	speed = params.get("speed", 0)	
	start_pos = global_position
	

func _process(delta):
	to_target = target.position - global_position
	distance = to_target.length()	
	if distance < speed * delta:
		global_position = target.position
		impact()
		return
	direction = to_target.normalized()
	global_position += direction * speed * delta
	var current_distance = global_position.distance_to(target.position)
	var progress = 1.0 - (current_distance / total_distance)
	progress = clamp(progress, 0.0, 1.0)
	update_shadow()
	
	
		
func impact():
	var patch = Gamedata.STUNLICHEN.instantiate()
	get_tree().current_scene.add_child(patch)	
	patch.setup(global_position, params)	
	queue_free()
		
func set_target_position(target_enemy):
	target = target_enemy	
	total_distance = start_pos.distance_to(target.position)
	
func update_shadow():
	var current_distance = global_position.distance_to(target.position)
	var progress = 1.0 - (current_distance / total_distance)
	progress = clamp(progress, 0.0, 1.0)
	var factor = abs(progress - 0.5) * 2.0
	factor = pow(factor, 0.25)	
	
	var min_scale = 0.5
	var max_scale = 1.0
	
	var scale_value = lerp(min_scale, max_scale, factor)
	shadow.scale = Vector2.ONE * scale_value
	shadow.position.y = lerp(500, 0, factor)
