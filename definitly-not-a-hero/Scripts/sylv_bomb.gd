extends Node2D


var explosion_radius: float = 250
var bullet_damage: float = 5
var arc_height: float = 360
var Speed = 0.5
var exploded = false
var fall_time = 0.5
var target:Vector2
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var marker: Node2D 

func setup(stats: Dictionary) -> void:
	bullet_damage = stats.get("damage", 0.0)
	Speed = stats.get("speed", 0.0)
	explosion_radius = stats.get("raduis", 0.0)	


func set_target_position(target_enemy):
	target = target_enemy.global_position
	#launch(global_position,target,arc_height)

func cast_sylv_bomb(target_pos: Vector2):
	# 1. Marker
	marker = Gamedata.MARKER.instantiate()
	marker.global_position = target
	add_child(marker)

	# 2. Delay
	await (0.6)

	## 3. Bombe
	#var bomb = Gamedata.SYLV_BOMB.instantiate()
	#bomb.global_position = target + Vector2(0, -800)
	#add_child(bomb)
	#var tw = create_tween()
	#tw.tween_property(self, "global_position", bomb.global_position, fall_time)\
		#.set_trans(Tween.TRANS_QUAD)\
		#.set_ease(Tween.EASE_IN)
	#tw.finished.connect(explode)
	
#func bezier(p0: Vector2, p1: Vector2, p2: Vector2, t: float) -> Vector2:
	#return p0.lerp(p1, t).lerp(p1.lerp(p2, t), t)
#
#func launch(p_start:Vector2, p_end:Vector2, curve_strength := 80.0):
	#start = p_start
	#end   = p_end
	#var global_position  = start
	#var mid = (start + end) * 0.5
	#var perp = (end - start).normalized().orthogonal() * curve_strength
	#ctrl = mid + perp
	#time = 0.0
	#$AnimationPlayer.play("flying")

#func _physics_process(delta):
	#if time >= life_time:
		#if not exploded:
			#explode()
			#return
	#time += delta * Speed
	#global_position = bezier(start, ctrl, end, time)

func explode():
	# 1. Ajuste le radius
	var circle := %ExplosionCollision.shape as CircleShape2D
	if circle:
		circle.radius = explosion_radius
	# 3. Attend un frame pour que la détection s'actualise
	await get_tree().process_frame
	
	for body in %Explosion.get_overlapping_bodies():
		if body.has_method("take_damage"):
			body.take_damage(bullet_damage)
	# 5. Effet visuel et suppression
	$AnimationPlayer.play("splashin")
	exploded = true
	await get_tree().create_timer(0.2).timeout
	queue_free()
	
