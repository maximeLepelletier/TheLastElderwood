extends Node

class_name StatsCalculator

static func compute(base: float, bonus: float, cumult :float, multiplier: float) -> float:
	return (base + bonus) * (1 + cumult) * multiplier
