extends Control

@onready var btn_skills: TextureButton = $"../../HBoxContainer/BtnSkills"
@onready var btn_play: TextureButton = $"../../HBoxContainer/BtnPlay"
@onready var btn_shop: TextureButton = $"../../HBoxContainer/BtnShop"
@onready var btn_settings: TextureButton = $"../../HBoxContainer/BtnSettings"


enum Tab {PLAY,SHOP,SKILLS,SETTINGS}
func _ready():
	btn_play.pressed.connect(func(): _on_tab_pressed(Tab.PLAY))
	btn_shop.pressed.connect(func(): _on_tab_pressed(Tab.SHOP))
	btn_skills.pressed.connect(func(): _on_tab_pressed(Tab.SKILLS))
	btn_settings.pressed.connect(func(): _on_tab_pressed(Tab.SETTINGS))


func _on_tab_pressed(tab: int) -> void:
	_play_transition()
	_load_tab(Tab.keys()[tab])
	
func _play_transition():
	print("Transition...")
	
func _load_tab(tab_name: String) -> void:
	print("Scene chargée :", tab_name)
