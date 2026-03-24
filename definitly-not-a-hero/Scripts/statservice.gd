extends Node
class_name StatsService

static func get_stat(
	base_stats: Dictionary,
	bonuses: Dictionary,
	percent_bonuses: Dictionary,
	multipliers: Dictionary,
	skill: String,
	stat: String
) -> float:
	
	if not base_stats.has(skill):
		push_error("Skill inconnu: " + skill)
		return 0.0
		
	if not base_stats[skill].has(stat):
		push_error("Stat inconnue %s.%s" % [skill, stat])
		return 0.0

	var base = base_stats[skill][stat]
	var bonus = bonuses.get(skill, {}).get(stat, 0.0)
	var percent = percent_bonuses.get(skill, {}).get(stat, 0.0)
	var mult = multipliers.get(skill, {}).get(stat, 1.0)
	
	return StatsCalculator.compute(base, bonus,percent, mult)
	
