class_name SplitOnDeathModifier
extends ModifierManager

var amount :int
var radius:int =0
var enemy :String
var area
func _init(_params: Dictionary):
	params = _params.duplicate(true)
	amount = params.get("amount", 0)
	enemy=params.get("enemy", 0)
	
func on_death():
	if owner == null:
		return	
	if owner.has_node("deatharea"):
		area = owner.get_node("deatharea")
		var collision = area.get_node("deathCollider")	
		if collision.shape is CircleShape2D:
			radius = collision.shape.radius
			
	split()

func split():
	for i in range(amount):
		var pos = get_random_point_in_circle(owner.global_position, radius)
		spawn_enemy(pos)
		
func get_random_point_in_circle(center: Vector2, radius: float) -> Vector2:
	var angle = randf() * TAU
	var dist = sqrt(randf()) * radius
	return center + Vector2(cos(angle), sin(angle)) * dist
	
func spawn_enemy(pos: Vector2):
	if owner == null:
		return	
	WaveManager.call_deferred("sub_mob_spawn",enemy, pos)
