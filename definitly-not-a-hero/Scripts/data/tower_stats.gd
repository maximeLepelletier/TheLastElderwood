extends Resource
class_name TowerStats
#-------------------------------------------------------------------------#
#PROJECTILES
#-------------------------------------------------------------------------#
@export var base := {
	"bullet": {
		"instance":Gamedata.BULLET,
		"damage": 10.0,
		"fire_rate": 0.8,
		"speed": 2000,
		"range": 3750,
		"mode": "",
		#fire
		"damage_per_tick": 2.0,
		"dot_duration": 2,
		"dot_rate": 0.5,
		#explosion
		"explosion_radius": 1,
		"explosion_damage": 4,
		"explosion_count": 1,
		"shockwave_time":0.5,
		"chain_explosion":false,
		#thorn
		"thorn_damage_storage":2,
		"thorn_max_count":5,
		"thorn_max_flat_damage":200
	},
	"wood_trunk": {
		"instance":Gamedata.WOOD_TRUNK,
		"damage": 5,
		"speed": 1200,
		"range": 2500,
		"fire_rate": 10,
		"width":2,
		"height":2,
		"mode": "",
		#rock
		"rock_width":0.75,
		"rock_height":1.5,
		"rock_damage":7,
		"rock_range":3500,
		"rock_speed":200,
		"rock_growth_scale":0,		
		"rock_growth_damage_value":0, #correspond au facteur de damage  supplémentaire par la distance
		'rock_scale':1,
		#throw_back
		"throw_width":1,
		"throw_height":2,
		"throw_damage":3.5,
		"throw_range":2500,
		"throw_speed":700,
		"throw_fire_rate":10,
		"throw_back":2.5,
		"throw_duration":0.5,
		"throw_count":1,
		"throw_growth_push_value":0, # correspond au facteur de push supplémentaire par la distance
		
	},
	"vamp_sting": {
		"instance":Gamedata.VAMP_STING,
		"damage": 3.0,
		"fire_rate": 5,
		"speed": 2000,
		"range": 3600,
		"heal": 1,
		"mode": ""
	},
	"sylv_shield": {
		"instance":Gamedata.SYLV_SHIELD,
		"shield_max_hp": 100,
		"shield_regen": 5,
		"shield_regen_interval":5,
		"mode": "",
		"shockwave_damage_incremental":0.5,
		"shockwave_damage_limit":10,
		"shockwave_radius":1.2,
		"shockwave_speed":3.5,
		"shockwave_max_hp":50,
		"shockwave_current_hp":50,
		"shockwave_cooldown":12
	},
	"root_aura": {
		"instance":Gamedata.ROOT_AURA,
		"damage_per_tick": 2.0,
		"slow_percent": 0.3,
		"fire_rate": 1,
		"radius":3,
		"mode": "",
		"overgrowth_kill_ratio":0.005,	
		"overgrowth_damage":1.5,
		"overgrowth_tickrate":0.7,
		"overgrowth_radius":2.5,
		"overgrowth_level":0,
		"overgrowth_scale_damage":0,
		"binding_damage_limit":0.1,
		"binding_radius":4,
		"binding_damage":2,
		"binding_ennemy_scale":0,
		"binding_reroll_limit":0

	},
	"leaf_storm": {
		"instance":Gamedata.LEAF_STORM,
		"damage": 3.0,
		"damage_per_tick": 1.0,
		"dot_duration": 4.0,
		"dot_rate": 1,
		"duration": 4,
		"radius":3,
		"speed":500,
		"fire_rate":10,
		#razor
		"razor_tick_rate":1,
		"razor_damage":4.0,
		"razor_crit_rate":0,
		#sand
		"sand_debuff_duration":2,
		"sand_slow":0.2,
		"sand_debuff_cooldown":3,
		"sand_damage": 1,
		"sand_tick_rate":0.75,
		"mode": ""		
	},
	"stun_lichen": {
		"instance":Gamedata.STUNLICHEN,
		"scale": 1.0,
		"stun_duration": 1.5,
		"stun_damage": 5.0,
		"stun_cooldown":4,
		"life_time":4,
		"stun_fire_rate":10,
		"speed":900,
		"mode": ""
	},
	"rafflesia_guardian": {
		"instance":Gamedata.RAFFLESIA_GUARDIAN,
		"rate":0.5,
		"max_bullet": 5,
		"max_turn": 1,
		"bullet_damage":3.0,
		"bullet_range":350,
		"bullet_speed":800,
		"same_bullet":false		
	}
	
}
