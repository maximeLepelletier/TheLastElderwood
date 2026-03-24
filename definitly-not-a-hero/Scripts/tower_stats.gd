extends Resource
class_name TowerStats
#-------------------------------------------------------------------------#
#PROJECTILES
#-------------------------------------------------------------------------#
@export var base := {
	"bullet": {
		"instance":Gamedata.BULLET,
		"damage": 10,
		"fire_rate": 0.8,
		"speed": 2000,
		"range": 3750,
		"mode": "",
		"damage_per_tick": 2.0,
		"dot_duration": 2,
		"dot_rate": 0.5,
		"explosion_radius": 1,
		"explosion_damage": 4,
		"explosion_count": 1,
		"shockwave_time":0.5,
		"chain_explosion":false,
		"thorn_damage_storage":2,
		"thorn_max_count":5,
		"thorn_max_flat_damage":200
	},
	"wood_trunk": {
		"instance":Gamedata.WOOD_TRUNK,
		"damage": 10,
		"speed": 1200,
		"range": 2500,
		"fire_rate": 7,
		"scale":1
	},
	"vamp_sting": {
		"instance":Gamedata.VAMP_STING,
		"damage": 3,
		"fire_rate": 5,
		"speed": 2000,
		"range": 3600,
		"heal": 1
	},
	"sylv_bomb": {
		"instance":Gamedata.SYLV_BOMB,
		"radius": 250,
		"damage": 5,
		"speed": 1000,
		"range": 1500,
		"fire_rate": 5,
		"multiplicated": false
	},
	"sylv_shield": {
		"instance":Gamedata.SYLV_SHIELD,
		"max_hp": 100,
		"current_HP": 100,
		"regen": 5,
		"radius":1
	},
	"root_aura": {
		"instance":Gamedata.ROOT_AURA,
		"damage_per_tick": 2.0,
		"slow_percent": 0.3,
		"fire_rate": 1,
		"radius":3
	},
	"leaf_storm": {
		"instance":Gamedata.LEAF_STORM,
		"damage": 2.0,
		"damage_per_tick": 1.0,
		"dot_duration": 4.0,
		"dot_rate": 1,
		"duration": 4,
		"radius":3,
		"speed":500,
		"fire_rate":10
	}
}
