extends Node2D

@onready var label = $damageTextLabel

func setup(damage: float, type: String,pos: Vector2,Weak_Or_Res: String):
	
	label.text = str(float(damage))
	position = pos
	modulate.a =1
	set_process(true)
	# couleur selon type
	match type:
		"fire":
			label.modulate = Color(1,0.4,0.2)
		"thorn":
			label.modulate = Color(0.2, 0.65, 0.75, 1.0)
		"explosion":
			label.modulate = Color(0.9, 0.8, 0.1)	
		"heal":
			label.modulate = Color(0.566, 0.891, 0.53, 1.0)
		"crit":
			label.modulate = Color(0.629, 0.115, 0.106, 1.0)	
		_:
			label.modulate = Color(1,1,1)
	match Weak_Or_Res:
		"weaknesses":
			label.scale = Vector2(1.3, 1.3)
		"resistances":
			label.scale = Vector2(0.7, 0.7)			
	animate()
	
func animate():

	var tween = create_tween()
	visible = true
	tween.tween_property(self, "position:y", position.y - 50, 0.6)
	tween.tween_property(self, "modulate:a", 0.0, 0.6)	
	tween.finished.connect(deactivate)
	
func deactivate():
	visible = false
	set_process(false)
	
	recycle(self)

func recycle(instance):
	if not DamageManager.pool.has(instance):
		DamageManager.pool.append(instance)
	DamageManager.active.erase(instance)
