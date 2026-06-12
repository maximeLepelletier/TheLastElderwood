extends Node

const FAMILIES = {

	"damage": [
		"damage",
		"dot_damage",
		"razor_damage",
		"rock_damage",
		"throw_damage",
		"shockwave_damage"
	]

}




#---------------------------------------------------------------#
#---------------------------helper------------------------------#
#---------------------------------------------------------------#

func stat_match(category:String, stat:String) -> bool:

	if category == stat:
		return true
	if FAMILIES.has(category):
		return stat in FAMILIES[category]

	return false
