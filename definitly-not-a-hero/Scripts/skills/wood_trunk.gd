extends Area2D
var Speed = 1400
var RANGE = 700
var travelled_distance= 0
var damage = 0
var size = 1

var width :float = 0
var height :float = 0
var mode :String =""
#rock
var rock_width :float = 0
var rock_height :float = 0
var rock_damage :float = 0
var rock_range :float = 0
var rock_speed :float = 0	
var rock_scale :float = 0
var rock_growth_scale :float = 0
var throw_back :float = 0
var throw_width :float = 0
var throw_height :float = 0
var throw_damage :float = 0
var throw_range :float = 0
var throw_speed :float = 0
var throw_duration :float = 0
var current_growth :float = 0
var throw_growth_value :float = 0
var rock_growth_damage_value :float = 0
var target :TargetData


func setup(stats: Dictionary) -> void:
	damage = stats.get("damage", 0.0)
	Speed = stats.get("speed", 0.0)
	RANGE = stats.get("range", 0.0)
	width = stats.get("width",0.0)
	height = stats.get("height",0.0)
	mode = stats.get("mode",0.0)
	rock_width = stats.get("rock_width",0.0)
	rock_height = stats.get("rock_height",0.0)
	rock_damage = stats.get("rock_damage",0.0)
	rock_range = stats.get("rock_range",0.0)
	rock_speed = stats.get("rock_speed",0.0)
	rock_growth_damage_value = stats.get("rock_growth_damage_value",0.0)
	rock_growth_scale = stats.get("rock_growth_scale",0.0)
	rock_scale = stats.get("rock_scale",0.0)
	throw_width = stats.get("throw_width",0.0)
	throw_height = stats.get("throw_height",0.0)
	throw_damage = stats.get("throw_damage",0.0)
	throw_range = stats.get("throw_range",0.0)
	throw_speed = stats.get("throw_speed",0.0)
	throw_back = stats.get("throw_back",0.0)
	throw_duration = stats.get("throw_duration",0.0)
	throw_growth_value = stats.get("throw_growth_push_value",0.0)
	apply_mode(mode)
	
func apply_mode(skill_mode:String):
	match skill_mode:
		"rock":
			convert_to_rock()
		"throw":
			convert_to_throw()
		_:
			up_scale(width,throw_height)
			
func convert_to_rock():
	up_scale(rock_scale*rock_width,rock_scale*rock_height)
	print("rock")
func convert_to_throw():
	up_scale(throw_width,height)
	print("BELIER")
	
func _ready() -> void:
	pass
	
func _physics_process(delta: float) -> void:
	var direction = Vector2.RIGHT.rotated(rotation-PI/2)
	position += direction * Speed * delta
	travelled_distance += Speed * delta
	current_growth = (travelled_distance/RANGE)
	if mode=="rock":
		up_scale(compute_growth(rock_scale*rock_width,rock_growth_scale,current_growth),compute_growth(rock_scale*rock_height,rock_growth_scale,current_growth))
	if travelled_distance>=RANGE:
		queue_free()

func compute_growth(value : float , max_ratio :float,growth_progress)-> float:
	return value * (1.0 + (max_ratio  * growth_progress))
	
func up_scale(width: float,height: float) ->void:
	scale.x = width
	scale.y = height

func _on_body_entered(body: Node2D) -> void:
	print("Wood_trunk touché ! damages :" + str(damage))
	match mode:
		"throw":
			if body.has_method("apply_debuff"):
				body.apply_debuff(throw_duration,0 ,"slow",compute_growth(throw_back,throw_growth_value,current_growth))				
			if body.has_method("take_damage"):
				body.take_damage(throw_damage,"physical","wood_trunk_throw")
		"rock":
			rock_damage+=(rock_width+rock_height)/2
			if body.has_method("take_damage"):
				body.take_damage(compute_growth(rock_damage,rock_growth_damage_value,current_growth),"physical","woodtrunk_rock")		
		_:
			if body.has_method("take_damage"):
				body.take_damage(damage,"physical","wood_trunk")
				
