extends Node

var upgrades = {}
var player: Node = null
var tower: Node = null

func _ready():
	load_upgrades()

func set_player(p):
	player = p
	# Si la tour est un enfant du joueur, on la relie direct ici :
	if player.has_node("Tower"):
		tower = player.get_node("Tower")	

func load_upgrades():
	var file = FileAccess.open("res://Data/upgrades.json", FileAccess.READ)
	if file:
		upgrades = JSON.parse_string(file.get_as_text())
	file.close()

func get_random_choices(count: int = 3) -> Array:
	var valid_keys: Array = []
	var valid_super: Array = []
	var valid_fusion: Array = []
	var super_families: Array = []

	for upgrade_id in upgrades.keys():
		var data = upgrades[upgrade_id]		
		# ================================
		#  Traitement des super skills
		# ================================
		if data.type == "skill_super":
			var base = data.requires
			#on ne debloque qu'une fois le superskill
			if data.has("unique") and data.unique and tower.has_skill(upgrade_id): 
				continue	
			if tower.has_skill(base) and tower.get_upgrade_count(base) == 3:
				valid_super.append(upgrade_id)
				super_families.append(base)  # <<< on ajoute la famille
			continue		

		# ================================
		# 2) Traitement des upgrades "normaux"
		# ================================	
		var skip_this_upgrade := false

		#bloquer les amélioration classique si la super est selectionnée
		for fam in super_families:
			# cas 1 : c’est le skill de base lui-même
			if upgrade_id == fam:
				skip_this_upgrade = true
				break
			# cas 2 : upgrade de la même famille
			if data.has("requires") and data.requires == fam:
				skip_this_upgrade = true
				break
		if skip_this_upgrade:
			continue		
			
		# -- Bloquer compétences si la base n'est pas debloquée --
		if data.has("requires") and not tower.has_skill(data.requires):
			continue
		# -- Bloquer compétences uniques déjà prises --
		if data.has("unique") and data.unique and tower.has_skill(upgrade_id):
			continue
		# -- Bloquer les upgrades nécessitant un skill non appris --
		if data.has("available") and tower.get_upgrade_count(upgrade_id) == data.available: 
			continue
		# -- Bloquer compétences si un mode est deja associé a la competence
		if data.has("target") and data.target=="mode":
			if tower.get_property("bullet","mode","") != "":
				continue
		else:
			if data.has("mode_skill"):
				if data.mode_skill != tower.get_property("bullet","mode",""):
					continue				
				
		valid_keys.append(upgrade_id)
	# Mélange 
	valid_keys.shuffle()
	valid_super.shuffle()
	
	#on cree un nouveau pool de super + normaux
	var pool :=  valid_super + valid_keys
	return pool.slice(0, count)	
	
func get_upgrade_data(id: String) -> Dictionary:
	return upgrades.get(id, {})
