extends Sprite2D

@export var duration := 0.6
var bullet_damage: float = 5
var arc_height: float = 360
var Speed = 0.5
var explosion_radius: float = 250
var stats_bombs: Dictionary

func setup(stats: Dictionary) -> void:
	stats_bombs = stats

func set_target_position(target_enemy):
	global_position = target_enemy.global_position
	
func _ready():	
	var tw = create_tween()
	tw.tween_property(self, "scale", Vector2(1.1, 1.1), 0.3).set_trans(Tween.TRANS_SINE)
	tw.tween_property(self, "scale", Vector2(1.0, 1.0), 0.3)
	tw.finished.connect(falling_bomb(Gamedata.SYLV_BOMB,stats_bombs,global_position))
	
func falling_bomb(projectile: PackedScene,stats: Dictionary,target_position: Vector2):
	var new_projectile = projectile.instantiate()
	new_projectile.global_position = global_position + Vector2(0, -1000)
	if new_projectile.has_method("setup"):
		new_projectile.setup(stats)
	if new_projectile.has_method("set_target_position"):
		new_projectile.set_target_position(target_position)
	get_parent().add_child(new_projectile)
