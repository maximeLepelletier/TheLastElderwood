class_name DashModifier
extends ModifierManager

var cooldown_timer :float = 0.0
var is_dashing := false
var dash_cooldown := false
var duration : float =0
var dash_speed : float =0
var dashparams : Dictionary ={}

func _init(_params: Dictionary):
	params = _params.duplicate(true)
	cooldown_timer = params.get("cooldown", 1)
	dash_speed = params.get("speed", 1)
	duration = params.get("duration", 1)
	
func on_hit(damagedata :Dictionary):
	print(	"HIT | mod:", self.get_instance_id(),	"| owner:", owner.get_instance_id()	)
	if not is_dashing and not dash_cooldown:
		start_dash()
	return damagedata
	
func start_dash():
	if owner != null:
		is_dashing = true
		owner.modulate = Color.RED
		owner.is_overriding_movement = true
		owner.override_speed = dash_speed
		duration = params.get("duration", 0.2)
		owner.get_tree().create_timer(duration).timeout.connect(func():
			stop_dash()
		)
		print(		"DASH | mod:", self.get_instance_id(),		"| owner:", owner.get_instance_id()		)
		

func stop_dash():
	if owner != null:
		owner.is_overriding_movement = false
		owner.override_speed = 0
		is_dashing = false
		owner.modulate = Color.WHITE
		print("stop dash"+ str(owner))
		owner.get_tree().create_timer(cooldown_timer).timeout.connect(func():
			resetcooldown()
		)
func resetcooldown():
	dash_cooldown=false
		
