class_name IntangibleModifier
extends ModifierManager

var duration:float
var intangible_cooldown: bool
var is_on_cooldown := false
var is_intangible :bool

func _init(_params: Dictionary):
	params = _params.duplicate(true)
	duration = params.get("duration", 0)
	intangible_cooldown=params.get("cooldown", 0)
	
func on_hit(damage_data):
	if is_intangible and not is_on_cooldown :
		return	
	start_intangible()
	return damage_data
	
func start_intangible():
	if owner == null:
		return	
	is_intangible = true
	owner.modulate.a = 0.5
	if owner.has_node("CollisionShape2D"):
		owner.get_node("CollisionShape2D").set_deferred("disabled", true)
	await owner.get_tree().create_timer(duration).timeout	
	stop_intangible()
	
func stop_intangible():
	if owner == null:
		return	
	is_intangible = false

	owner.modulate.a = 1.0

	if owner.has_node("CollisionShape2D"):
		owner.get_node("CollisionShape2D").set_deferred("disabled", false)
	is_on_cooldown = true
	owner.get_tree().create_timer(intangible_cooldown).timeout.connect(func():
		resetcooldown()
		)

func resetcooldown():
	is_on_cooldown=false
		
