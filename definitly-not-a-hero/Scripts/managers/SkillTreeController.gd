extends Node

var all_skills := {}          # id → data JSON
var save_state := {}          # id → current_stack

var completed_skills : int = 0
@export var skill_data_path := "res://data/skillTree.json"
@export var save_data_path := "res://data_save_test.json"
@onready var skill_tree_panel: Control = $"../TreeViewport/SkillTreePanel"
@onready var gold_label: Label = $"../GoldLabel"
@onready var gaia_label: Label = $"../GaiaLabel"
@onready var gem_label: Label = $"../GemLabel"


func _ready():
	var skill_json = Global.load_json(skill_data_path)
	var save_json = Global.load_json(save_data_path)
	# Transformation en dictionnaire indexé par ID
	for skill in skill_json["skills"]:
		all_skills[str(int(skill["id"]))] = skill	

	for node in get_tree().get_nodes_in_group("skill_nodes"):
		var id :String = node.skill_id
		var stack :int = save_state.get(id, 0)
		node.setup(all_skills[id], stack)
	Events.skill_purchased.connect(_on_skill_purchased)
	Events.resources_changed.connect(update_resource_ui)
	get_completed_skill_count()
	update_resource_ui()	
	resolve_unlocks()

func load_data(json_data, save_data):
	for skill in json_data:
		all_skills[skill.id] = skill

	for s in save_data:
		save_state[s.id] = s.current_stack

func resolve_unlocks():
	for node in get_tree().get_nodes_in_group("skill_nodes"):
		var skill = all_skills[node.skill_id]

		var unlocked := true
		for req in skill.required_id:
			if save_state.get(str(int(req)), 0) < all_skills[str(int(req))].max_stack:
				unlocked = false

		node.unlocked = unlocked
		node.update_state()
		
func _on_skill_purchased(skill_id: String, stack: int):
	save_state[skill_id] = stack
	resolve_unlocks()

#region RESSOURCES

func update_resource_ui():
	gold_label.text = str(playerdata.get_resource(playerdata.Ressourcetype.GOLD))
	gaia_label.text = str(playerdata.get_resource(playerdata.Ressourcetype.GAIASEED))
	gem_label.text = str(playerdata.get_resource(playerdata.Ressourcetype.GEM))
	update_skilltree_Data()
	
func is_skill_completed(skill_id: String) -> bool:
	var current :int = save_state.get(skill_id, 0)
	var max_stack :int = all_skills[skill_id].max_stack
	return current >= max_stack
	
func get_completed_skill_count() -> int:
	var count := 0
	for skill_id in all_skills.keys():
		if is_skill_completed(skill_id):
			count += 1
	return count
	
func update_skilltree_Data():
	playerdata.completed_skills = get_completed_skill_count()

#endregion
