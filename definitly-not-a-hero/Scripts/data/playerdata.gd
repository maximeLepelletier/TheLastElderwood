extends Node

class_name playerdata 


#region RESSOURCES

enum Ressourcetype {GOLD,GAIASEED,GEM}
static var gaia_cost :int = 4
static var gold_cost :int = 100

static var completed_skills=0
static var _resources := {
	Ressourcetype.GOLD: 1000,
	Ressourcetype.GAIASEED: 1000,
	Ressourcetype.GEM: 1000,
} 
static func get_resource(type: playerdata.Ressourcetype) -> int:
	var test = _resources.get(type, 0)
	return _resources.get(type, 0)

static func can_buy(type: playerdata.Ressourcetype,cost: int) -> bool:
	return get_resource(type) >= cost

static func spend_resources(type1: playerdata.Ressourcetype,type2: playerdata.Ressourcetype,cost1: int,cost2: int) -> bool:
	if not can_buy(type1,cost1):
		return false
	if not can_buy(type2,cost2):
		return false
	set_resource(type1,get_resource(type1)-cost1)
	set_resource(type2,get_resource(type2)-cost2)
	Events.resources_changed.emit()
	return true
	
static func set_resource(type: playerdata.Ressourcetype,value: int) -> void:
	_resources[type] = max(value, 0)
	Events.resources_changed.emit()
	
static func add_resource(type: playerdata.Ressourcetype,value: int) -> void:
	set_resource(type, get_resource(type) + value)

static func concat_gaia_cost (unlockNodes:int , cost) -> int:
	return ceil((cost + unlockNodes) * 1.25)
	
static func concat_gold_cost (unlockNodes:int , cost) -> int:
	return ceil(cost * ((unlockNodes + 1) * 1.2))
#endregion

func get_save_data() -> Dictionary:
	var data := {}
	for type in _resources.keys():
		data[str(type)] = _resources[type]
	return data
