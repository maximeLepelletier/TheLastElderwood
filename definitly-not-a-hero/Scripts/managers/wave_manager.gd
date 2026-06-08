extends Node

var waves = []
var current_wave = 0
var spawning = false
var spawn_path: PathFollow2D = null
var current_wave_id: int = 0
var enemies_alive: int 
var total_waves: int = 0

#PRELOAD des scenes enemis----------------
var enemy_scenes = {
	"white_square_enemy": preload("res://Scenes/ennemies/square_enemy.tscn"),
	"white_circle_enemy": preload("res://Scenes/ennemies/circle_enemy.tscn"),
	"white_hexa_enemy": preload("res://Scenes/ennemies/hexa_enemy.tscn"),
	"white_star_enemy": preload("res://Scenes/ennemies/Star_enemy.tscn"),
	"bat": preload("res://Scenes/ennemies/bat.tscn"),
	"boss1_enemy": preload("res://Scenes/ennemies/boss1_enemy.tscn")        
}
#-----------------------------------------

func _ready():
	Events.enemy_died.connect(_on_enemy_died)
	load_waves()

func load_waves():
	var file = FileAccess.open("res://data/waves.json", FileAccess.READ)
	if not file:
		push_error("❌ Could not open waves.json")
		return
	var text = file.get_as_text()
	file.close()
	var data = JSON.parse_string(text)
	if typeof(data) != TYPE_DICTIONARY:
		push_error("❌ Invalid JSON format in waves.json")
		return
	for wave in data["waves"]:
		waves.append(wave)
	print("✅ Waves data loaded:")

func start_next_wave():
	if current_wave >= waves.size():
		print("✅ All waves completed!")
		return
	spawning = true
	var wave_data = waves[current_wave]
	spawn_wave(wave_data)
	current_wave += 1
	Events.wave_counter.emit()

func spawn_wave(wave_data: Dictionary) -> void:
	if wave_data.has("boss"):
		Events.next_wave.emit(current_wave+1,true)
		Events.wave_counter.emit()
		for enemy_info in wave_data["boss"]:
			enemies_alive+=enemy_info["count"]
			for i in range(enemy_info["count"]):
				await get_tree().create_timer(enemy_info["spawn_delay"],false).timeout
				mob_spawn(enemy_info["type"])
		print("nombre d'ennemis de la vague :" + str(enemies_alive))
	else:
		Events.next_wave.emit(current_wave+1)
	if wave_data.has("enemies"):
		for enemy_info in wave_data["enemies"]:
			enemies_alive+=enemy_info["count"]
			for i in range(enemy_info["count"]):
				await get_tree().create_timer(enemy_info["spawn_delay"],false).timeout
				mob_spawn(enemy_info["type"])
		print("nombre d'ennemis de la vague :" + str(enemies_alive))
	

func mob_spawn(enemy_id: String):		
	if not enemy_scenes.has(enemy_id):
		push_error("Enemy scene not found: " + enemy_id)
		return		
	var enemy_instance = enemy_scenes[enemy_id].instantiate()
	spawn_path.progress_ratio = randf()
	enemy_instance.position = spawn_path.global_position
	add_child(enemy_instance)
	enemy_instance.init(enemy_id)	
	enemy_instance.add_to_group("enemy")
	
func sub_mob_spawn(enemy_id: String, position: Vector2):		
	var enemy_instance = enemy_scenes[enemy_id].instantiate()
	enemy_instance.position = position
	add_child(enemy_instance)
	enemy_instance.init(enemy_id)
	enemy_instance.is_sub_mob = true
	enemy_instance.add_to_group("enemy")	

func _on_enemy_died() -> void:
	enemies_alive -=1
	print("nombre d'ennemi encore en vie : " + str(enemies_alive))
	Events.enemy_died_signal.emit()
	if enemies_alive <= 0:
		await get_tree().create_timer(1.0).timeout
		start_next_wave()

func set_spawn_path(path) -> void:
	spawn_path = path
