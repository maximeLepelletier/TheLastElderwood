extends Node2D

var scaling :float
var stun_duration :float
var stun_damage :float 
var stun_cooldown :float
var life_time :float
# ennemis présents dans la zone
var enemies_in_area: Array = []
@onready var timer: Timer = $Timer

func setup(_spawn_point :Vector2 , stats: Dictionary) -> void:
	scaling = stats.get("scaling",0)
	stun_duration =stats.get("stun_duration",0)
	stun_damage =stats.get("stun_damage",0) 
	stun_cooldown =stats.get("stun_cooldown",0)
	life_time =stats.get("life_time",0)	
	global_position= _spawn_point
	timer.wait_time = stun_cooldown
	
# --------------------------------------------------
# Détection ennemis
# --------------------------------------------------

func _on_area_2d_body_entered(body: Node2D) -> void:
		enemies_in_area.append(body)
		apply_hit(body)

func _on_area_2d_body_exited(body: Node2D) -> void:
	if enemies_in_area.has(body):
		enemies_in_area.erase(body)
		
func apply_hit(enemy):

	if not enemy:
		return

	if enemy.has_method("take_damage"):
		enemy.take_damage(stun_damage,"thunder","stun_lichen")

	if enemy.has_method("apply_debuff") :#ajouter enemi not stun
		enemy.apply_debuff(stun_duration,stun_cooldown,"stun")
		

func _process(delta: float) -> void:
	life_time-=delta
	if life_time<=0:
		queue_free()	
		
