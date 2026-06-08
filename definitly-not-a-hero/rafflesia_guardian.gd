extends Node2D

var max_bullet :int
var max_turn :int

var bullet_damage :float
var bullet_range :float
var bullet_speed :float

var mode = "physical"
var damage_per_tick :float = 0
var dot_duration :float =0
var dot_rate :float =0

var explosion_radius :float
var explosion_damage :float
var explosion_count :int =1

var damage_storage :float
var thorn_max_count :int
var thorn_max_flat_damage

var shots_fired := 0
var baseangle := 0.0
var angle := 0.0

@onready var weaponrotation: Marker2D = $weaponrotation

var shot_interval := 0.35

func setup(_spawn_point :Vector2 , stats: Dictionary) -> void:

	max_bullet = stats.get("max_bullet",0)
	max_turn = stats.get("max_turn",0)
	bullet_damage = stats.get("max_turn",0)
	bullet_range = stats.get("bullet_range",0)
	bullet_speed  = stats.get("bullet_speed",0)	
	mode =stats.get("mode",0)
	damage_per_tick =stats.get("damage_per_tick",0)
	dot_duration =stats.get("dot_duration",0)
	dot_rate =stats.get("dot_rate",0)
	explosion_radius =stats.get("explosion_radius",0)
	explosion_damage =stats.get("explosion_damage",0)	
	explosion_count =stats.get("explosion_count",0)	
	damage_storage =stats.get("damage_storage",0)	
	thorn_max_count =stats.get("thorn_max_count",0)	
	thorn_max_flat_damage = stats.get("thorn_max_flat_damage",0)
	baseangle = TAU / max_bullet		
	_process_fire()
	
func _process_fire():
	if shots_fired >= (max_bullet * max_turn):
		queue_free()
		return	
	fire_step()

func fire_step():	
	weaponrotation.global_rotation = weaponrotation.global_rotation + baseangle
	await get_tree().create_timer(shot_interval, false).timeout 
	shooting()	
	shots_fired+=1
	_process_fire()
	
func shooting():
	var stats: Dictionary
	stats = {
		"damage":bullet_damage,
		"speed":bullet_speed,
		"range":bullet_range,
		"mode":mode,
		"damage_per_tick": damage_per_tick,
		"dot_duration": dot_duration,
		"dot_rate": dot_rate,
		"explosion_radius": explosion_radius,
		"explosion_damage": explosion_damage,
		"explosion_count": explosion_count,
		"thorn_damage_storage":damage_storage,
		"thorn_max_count":thorn_max_count,
		"thorn_max_flat_damage":thorn_max_flat_damage,		
		}
	call_deferred("shoot",Gamedata.BULLET,stats)

func shoot(projectile,stats: Dictionary):
	var new_projectile = projectile.instantiate()
	new_projectile.global_rotation = %ShootingPoint.global_rotation	
	new_projectile.global_position = %ShootingPoint.global_position	
	if new_projectile.has_method("setup"):
		new_projectile.setup(stats)
	#rend indépendant le projectile tirer pour nepas tourner avec la tour
	var root = get_tree().get_current_scene() 
	root.add_child(new_projectile)
	print("shoot:" + str(shots_fired))
	
	
	
