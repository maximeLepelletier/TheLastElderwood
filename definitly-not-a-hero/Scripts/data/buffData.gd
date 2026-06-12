extends Node
static var DATA = {

	"shield_bloom_lv1": {
		"id":"shield_bloom",
		"skill":"bullet",
		"stat":"damage",
		"type":"percent",
		"value":0.20
	},

	"shield_bloom_lv2": {
		"id":"shield_bloom",
		"skill":"bullet",
		"stat":"damage",
		"type":"percent",
		"value":0.40
	},

	"rage_lv1": {
		"id":"rage",
		"skill":"*",
		"stat":"damage",
		"type":"percent",
		"value":0.10
	}
}


#---------------------------------------------------------------#
#---------------------------helper------------------------------#
#---------------------------------------------------------------#
func get_buff(buff_name:String) -> Dictionary:

	if not DATA.has(buff_name):
		push_error("Buff inconnu : " + buff_name)
		return {}

	return DATA[buff_name]
