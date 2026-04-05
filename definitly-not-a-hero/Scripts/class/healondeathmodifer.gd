class_name HealOnDeathModifier
extends ModifierManager

var radius:int =0
var amount: float=0
var area
func _init(_params: Dictionary):
	params = _params.duplicate(true)
	amount = params.get("amount", 20)

func on_death():
	if owner == null:
		return
	
	if owner.has_node("deatharea"):
		area = owner.death_area	

	call_deferred("apply_heal_area")

func apply_heal_area():	
	var bodies = area.get_overlapping_bodies()
	
	for enemy in bodies:
		if enemy == owner:
			continue
		if enemy.has_method("heal"):
			enemy.heal(amount)	
	
	area.monitoring = false
