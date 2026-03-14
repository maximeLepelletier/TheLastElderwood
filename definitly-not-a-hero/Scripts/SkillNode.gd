extends Button

@export var skill_id: String
@export var links: Array[Control]

var skill_data
var current_stack: int = 0
var unlocked: bool

func setup(skill: Dictionary, stack: int):
	# Récupérer tous les SkillLink enfants
	#for child in get_tree().get_nodes_in_group("Skill_link"):
	Events.update_state_skill_tree.connect(update_state)
	for child in get_children():
		if child is SkillLink:
				links.append(child)	
	skill_data = skill
	current_stack = stack
	$StackedLabel.text = str(current_stack) + "/" + str(int(skill_data.max_stack))
	$CenterContainer/Icon.texture = load(skill.icon)
	$Description.text = skill.text	
	update_state()
	
	
func purchase():
	Events.initSkillPanel.emit(skill_data,current_stack,playerdata._resources)

func update_state():
	$StackedLabel.text = str(current_stack) + "/" + str(int(skill_data.max_stack))
	var completed :bool = current_stack >= skill_data.max_stack

	for link in links:
		link.update_progress(current_stack, skill_data.max_stack)

func _on_pressed() -> void:	
	print("skillID: ",skill_id," upgraded")
	if not unlocked:
		return
	if current_stack >= skill_data.max_stack:
		return
	current_stack += 1
	purchase()
