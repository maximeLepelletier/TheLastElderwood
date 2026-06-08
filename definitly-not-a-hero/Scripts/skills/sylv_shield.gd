extends Node2D

@export var max_shield := 100
@export var shield_regen_rate := 5
@export var regen_interval := 5.0   # toutes les X secondes
var shield_current_hp = 100
var reflect :bool
@onready var sprite_2d: Sprite2D = $Sprite2D


func _ready():
	%Timer.wait_time = regen_interval
	%Timer.start()
	shield_current_hp = max_shield
	Events.update_shield.connect(_on_update_shield)
	Events.update_shield.emit(max_shield,max_shield,shield_regen_rate)
	reflect = false

func _on_timer_timeout() -> void:
	if shield_current_hp < max_shield:
		shield_current_hp = min(shield_current_hp + shield_regen_rate, max_shield)
		Events.update_shield.emit(max_shield,shield_current_hp,shield_regen_rate)	
		Events.shield_heal.emit(shield_current_hp)
	

func _on_update_shield(max_hp_shield,shield_current_hp,shield_regen):
	set_max_shield(max_hp_shield)
	set_shield_regen_rate(shield_regen)
	set_current_hp_shield(shield_current_hp)
	if shield_current_hp<=0:
		visible=false
	else:
		visible=true
		
func set_max_shield(value):
	max_shield = value
func set_shield_regen_rate(value):
	shield_regen_rate= value
func set_regen_interval(value):
	regen_interval= value
func set_current_hp_shield(value):
	shield_current_hp= value
