extends Node

@export var tower_stats: TowerStats
func _init():
	tower_stats = load("res://ressources/tower_stats.tres") as TowerStats
	assert(tower_stats != null)

#PREFAB
const BULLET = preload("res://scenes/skills/bullet.tscn")
const WOOD_TRUNK = preload("res://Scenes/Skills/wood_trunk.tscn")
const VAMP_STING = preload("res://Scenes/Skills/vamp_sting.tscn")
const SYLV_BOMB = preload("res://Scenes/Skills/sylv_bomb.tscn")
const SYLV_SHIELD = preload("res://Scenes/Skills/sylv_shield.tscn")
const ROOT_AURA = preload("res://Scenes/Skills/root_aura.tscn")
const LEAF_STORM = preload("res://Scenes/Skills/leaf_storm.tscn")
const EXPLOSION = preload("res://Scenes/Skills/explosion.tscn")
const STUNLICHEN = preload("res://Scenes/Skills/stun_lichen.tscn")
const LICHENBULLET = preload("res://Scenes/Skills/lichen_bullet.tscn")
const RAFFLESIA_GUARDIAN = preload("res://Scenes/Skills/rafflesia_guardian.tscn")
const MARKER = preload("res://Scenes/Skills/target_marker.tscn")


#UI
const SKILLNODE := preload("res://Scenes/UI/skill_node.tscn")
const SKILLLINK := preload("res://Scenes/UI/skill_link.tscn")
