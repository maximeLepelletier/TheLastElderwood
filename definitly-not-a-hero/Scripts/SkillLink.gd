extends Control
class_name SkillLink

@export var required_id: String

func update_progress(current: int, max_stack: int):
	$ProgressBar.value = float(current) / float(max_stack) * 100.0
