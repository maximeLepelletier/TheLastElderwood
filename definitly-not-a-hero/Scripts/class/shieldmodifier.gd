class_name ShieldModifier
extends ModifierManager

var hits_left := 0

func _init(_params: Dictionary):
	hits_left = _params.get("hits", 3)
	
	

func on_hit(damage_data):
	if hits_left > 0:
		hits_left -= 1		
		flash_shield()
		if hits_left <= 0:
			break_shield()
		damage_data.damage = 0		
	return damage_data
	
func flash_shield():
	print("coup absorbé / coups restants : " + str(hits_left))
	
func break_shield():
	print("bouclier detruit")

	# optionnel : petit effet
	# spawn particles ici plus tard

	# supprimer le modifier
	remove_self()
	
func remove_self():
	if owner.modifiers.has(self):
		owner.modifiers.erase(self)
