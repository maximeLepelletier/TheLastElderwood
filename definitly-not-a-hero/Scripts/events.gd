extends Node

#ingame events
signal hp_empty	
signal next_wave(current_wave)
signal wave_counter
signal stats_changed(gold: int, xp: int)
signal leveling_up
signal enemy_died_signal(gold: int, xp: int)
signal enemy_died()
signal shield_unlock
signal shield_changed
signal shield_broken
signal shield_restored
signal growth_root
#UI event

signal initSkillPanel(skill: Dictionary, stack: int, resources: Dictionary)
signal skill_purchased(id,current_stack)
signal update_state_skill_tree()
signal resources_changed
