class_name ExplosionOnDeathModifier
extends ModifierManager

var damage: float=0
var area
func _init(_params: Dictionary):
	params = _params.duplicate(true)
	damage = params.get("damage", 20)

func on_death():
	if owner == null:
		return
	
	if owner.has_node("deatharea"):
		area = owner.death_area	

	call_deferred("apply_explosion_area")

func apply_explosion_area():	
	var bodies = area.get_overlapping_bodies()
	
	for enemy in bodies:
		if enemy == owner:
			continue
		if enemy.has_method("take_damage"):
			enemy.take_damage(damage,"physical","explosion_death")	
	
	area.monitoring = false
