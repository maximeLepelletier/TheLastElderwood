extends Control

@onready var icon: TextureRect = $BackGround/icon
@onready var IconTitle: Label = $BackGround/icon/Title
@onready var progression: Label = $BackGround/icon/Progression
@onready var gaia_icon: TextureRect = $BackGround/ressources/GaiaIcon
@onready var gold_icon: TextureRect = $BackGround/ressources/GoldIcon
@onready var gaia_cost_label: Label = $BackGround/ressources/GaiaCostLabel
@onready var gold_cost_label: Label = $BackGround/ressources/GoldCostLabel
@onready var buy_button: TextureButton = $BackGround/Button/BuyButton
@onready var exit_button: TextureButton = $BackGround/Button/ExitButton
@onready var drag_view: Control = $"../DragView"


var skill_data : Dictionary
var current_stack : int
var gaia_actual_cost: int 
var gold_actual_cost: int 
func _init() -> void:
	Events.initSkillPanel.connect(_on_init_skill_panel)
	
func setup(skill: Dictionary, stack: int, resources: Dictionary):
	#instance du panel
	skill_data = skill
	current_stack = stack
	icon.texture = load(skill.icon)
	IconTitle.text = skill.text
	var current_value = skill.value * current_stack
	var next_value = skill.value * (current_stack + 1)
	progression.text = replaceTextValue(skill.text, skill.value,current_stack)
	# on coupe les interactions clic du dragview
	drag_view.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	#gestion ressources
	gaia_actual_cost =playerdata.concat_gaia_cost(playerdata.completed_skills,playerdata.gaia_cost)
	gold_actual_cost =playerdata.concat_gold_cost(playerdata.completed_skills,playerdata.gold_cost)

	gaia_cost_label.text = str(gaia_actual_cost)
	gold_cost_label.text = str(gold_actual_cost)
	
	#parametrage UI
	#GAIA
	if stack <= skill.max_stack and (playerdata.can_buy(playerdata.Ressourcetype.GAIASEED,gaia_actual_cost)):
		gaia_cost_label.remove_theme_color_override("font_color")
		gaia_cost_label.add_theme_color_override("font_color","white")
		buy_button.disabled = false	
	else:
		gaia_cost_label.remove_theme_color_override("font_color")
		gaia_cost_label.add_theme_color_override("font_color","red")
		buy_button.disabled = true
	#GOLD
	if stack <= skill.max_stack and (playerdata.can_buy(playerdata.Ressourcetype.GOLD,gold_actual_cost)):
		gold_cost_label.remove_theme_color_override("font_color")
		gold_cost_label.add_theme_color_override("font_color","white")
		buy_button.disabled = false	
	else:
		gold_cost_label.remove_theme_color_override("font_color")
		gold_cost_label.add_theme_color_override("font_color","red")
		buy_button.disabled = true
		
func _on_init_skill_panel(skill: Dictionary, stack: int, resources: Dictionary):
	setup(skill, stack, resources)
	visible = true

func replaceTextValue(skillText: String, skillValue: float,stack: int) -> String:
	var Value = int(100 * skillValue)
	var StackedTextValue = str(Value * stack)
	var replacedText = skillText.replace(str(Value),StackedTextValue)
	return replacedText

func _on_buy_button_pressed() -> void:
	Events.skill_purchased.emit(str(int(skill_data.id)), current_stack)
	Events.update_state_skill_tree.emit()
	playerdata.spend_resources(playerdata.Ressourcetype.GAIASEED,playerdata.Ressourcetype.GOLD,gaia_actual_cost,gold_actual_cost)	
	Events.resources_changed.emit()

	drag_view.mouse_filter = Control.MOUSE_FILTER_STOP
	visible=false

func _on_exit_button_pressed() -> void:
	visible=false
