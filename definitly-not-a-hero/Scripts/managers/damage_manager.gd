extends Node2D

var damage_text_scene = preload("res://Scenes/UI/damageText.tscn")
var pool: Array = []
var active: Array = []

var pool_size := 150

func _ready():
	for i in range(pool_size):
		var instance = damage_text_scene.instantiate()
		instance.visible = false
		instance.set_process(false)
		add_child(instance)
		pool.append(instance)

func spawn(pos: Vector2, damage: float, type: String,vul_Or_Res: String):
	print("POOL:", pool.size(), "ACTIVE:", active.size())
	if active.size() > pool_size:
		return
	var instance
	if pool.size() > 0:
		instance = pool.pop_back()
	else:
		instance = damage_text_scene.instantiate()
		add_child(instance)		
	active.append(instance)		
	instance.setup(damage, type,pos,vul_Or_Res)
