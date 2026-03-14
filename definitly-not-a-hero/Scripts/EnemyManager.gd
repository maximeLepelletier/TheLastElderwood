extends Node
#DATA---------------------
var enemy_data = {} #contient les donnés Json
var stats = {} #contient les iables XP/GOLD ETC
var speed
var max_hp
var gold
var xp
var damage
#-------------------------
func _ready():
	load_enemy_data()
	
func load_enemy_data():
	var file = FileAccess.open("res://data/enemy.json", FileAccess.READ)
	if file:
		var data = JSON.parse_string(file.get_as_text())
		if typeof(data) == TYPE_DICTIONARY:
			for enemy in data["enemies"]:
				enemy_data[enemy["id"]] = enemy
			print("✅ Enemy data loaded:", enemy_data.keys())
		else:
			push_error("❌ Invalid JSON format in enemies.json")
	else:
		push_error("❌ Could not open enemies.json")
		
func get_enemy_stats(id: String) -> Dictionary:
	if enemy_data.has(id):
		return enemy_data[id]
	push_warning("⚠️ Enemy ID not found: " + id)
	return {}		
	
