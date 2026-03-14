extends Node

# --- CONSTANTES GLOBALES ---
const GAME_VERSION = "1.0.0"
const DEBUG_MODE = true

# --- FONCTIONS UTILES ---
func load_json(path: String) -> Dictionary:
	var file = FileAccess.open(path, FileAccess.READ)
	if file:
		return JSON.parse_string(file.get_as_text())
	return {}
	
func save_json(path: String, data: Dictionary) -> void:
	var file = FileAccess.open(path, FileAccess.WRITE)
	file.store_string(JSON.stringify(data, "\t"))

func log(msg):
	if DEBUG_MODE:
		print("[DEBUG]: ", msg)
