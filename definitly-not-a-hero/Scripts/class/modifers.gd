class_name ModifierManager

var owner
var params: Dictionary = {}


func attach(_owner):
	owner = _owner

func _on_remove():
	owner = null

static func create(mod_data):
	match mod_data.type:
		"dash":
			return DashModifier.new(mod_data) 
		"shield":
			return ShieldModifier.new(mod_data)
		"healondeath":
			return HealOnDeathModifier.new(mod_data)
		"explosionondeath":
			return ExplosionOnDeathModifier.new(mod_data)
		"intangible":
			return IntangibleModifier.new(mod_data)
		"splitondeath":
			return SplitOnDeathModifier.new(mod_data)
