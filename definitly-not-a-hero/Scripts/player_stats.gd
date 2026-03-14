extends Node

class_name PlayerStats

var stats_base = {
#stats
"hp_max": 100,
"hp_regen": 0.5,
"damage": 5,
"attack_speed": 1.0	,
#UI
"current_level":1,
"max_level":20,
"current_gold":0,
"current_xp":0,
#SHIELD
"shield_max_hp":100,
"shield_current_HP":100,
"shield_active":false,
"shield_regen":5
}

var stats_bonus = {}
var stats_multiplier = {}

func _ready():
	reset_stats()

func reset_stats():
	stats_bonus = {}
	stats_multiplier = {}
	for key in stats_base.keys():
		stats_bonus[key] = 0
		stats_multiplier[key] = 1.0


func get_stat(name: String) -> float:
	return (stats_base[name] + stats_bonus[name]) * stats_multiplier[name]


func apply_buff(skill_data: Dictionary):
	if skill_data.has("bonus"):
		for key in skill_data.bonus:
			stats_bonus[key] += skill_data.bonus[key]
	if skill_data.has("multiplier"):
		for key in skill_data.multiplier:
			stats_multiplier[key] *= skill_data.multiplier[key]
