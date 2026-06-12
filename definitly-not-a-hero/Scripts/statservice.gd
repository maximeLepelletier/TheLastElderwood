extends Node
class_name StatsService

static func get_stat(
	base_stats: Dictionary,
	bonuses: Dictionary,
	percent_bonuses: Dictionary,
	multipliers: Dictionary,
	active_buffs: Array,
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
	#ajout des buffs dynamiques (compétences activables)
	
	var dynamic_bonus :float = 0.0
	var dynamic_percent :float = 0.0
	var dynamic_mult :float = 0.0
	for active_buff in active_buffs:
		var buff =BuffData.get_buff(active_buff.name)
		if buff.is_empty():
			continue
			
		if buff.skill != "*"  and buff.skill != skill:
			continue
		var match_stat := false
		if buff.stat == stat:
			match_stat = true
		elif StatFamilies.stat_match(buff.stat,stat):
			match_stat = true
		if not match_stat:
			continue	
		#if buff.stat != stat:
			#continue
		match buff.type:
			"flat":
				dynamic_bonus += buff.value
			"percent":
				dynamic_percent += buff.value
			"mult":
				dynamic_mult *= buff.value
		print("Buff ",buff.id," appliqué sur ",stat)
	
	return StatsCalculator.compute(base, bonus + dynamic_bonus , percent + dynamic_percent , mult + dynamic_mult)
	
