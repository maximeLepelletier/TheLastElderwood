extends Node
#-------------------------------------------------------------------------#
#PROJECTILES
#-------------------------------------------------------------------------#
#BULLET
const BULLET = preload("res://Scenes/Skills/bullet.tscn")
var damage = 20
var fire_rate  
var bullet_speed = 1200
var bullet_range = 2000
#-------------------------------------------------------------------------#
#WOOD_TRUNK
const WOOD_TRUNK = preload("res://Scenes/Skills/wood_trunk.tscn")
var damage_wood_trunk = 10
var fire_rate_wood_trunk  
var trunk_speed = 400
var trunk_range = 1400
#-------------------------------------------------------------------------#
#VAMP_STING
const VAMP_STING = preload("res://Scenes/Skills/vamp_sting.tscn")
var damage_vamp_sting = 2
var fire_rate_vamp_sting
var vamp_sting_speed = 1000
var vamp_sting_range = 1800
var vamp_sting_heal = 1000
#-------------------------------------------------------------------------#
#SYLV_BOMB
const SYLV_BOMB = preload("res://Scenes/Skills/sylv_bomb.tscn")
var sylv_bomb_radius = 80
var sylv_bomb_damage = 5
var sylv_bomb_speed = 1000
