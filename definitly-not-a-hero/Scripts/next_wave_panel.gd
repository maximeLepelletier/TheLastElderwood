extends Node2D


@onready var next_wave_label: Control = %next_wave_label
var wave_panel =self
var screen_width: float
var panel_width: float

var current_wave = 1

func _ready():	
	reset_panel_position()
	%next_wave_label.visible = false
	
	
func play_wave_panel():
	%next_wave_label.text = "VAGUE " + str(current_wave)
	%next_wave_label.visible = false
	
	var tween := create_tween()
	tween.set_trans(Tween.TRANS_QUAD)
	tween.set_ease(Tween.EASE_OUT)

	# 1. Entrée rapide vers le centre
	tween.tween_property(
		wave_panel,
		"position:x",
		(screen_width - panel_width) / 2.0,
		0.35
	)

	# 2. Pause au centre (1 seconde)
	tween.tween_interval(1.0)

	# 3. Apparition du label
	tween.tween_callback(func():
		%next_wave_label.visible = true
	)

	# (optionnel) Fade-in du texte
	tween.tween_property(
		%next_wave_label,
		"modulate:a",
		1.0,
		0.25
	)

	# 4. Sortie rapide vers la droite
	tween.set_ease(Tween.EASE_IN)
	tween.tween_property(
		wave_panel,
		"position:x",
		screen_width + panel_width,
		0.35
	)

	# 5. Reset hors écran à gauche
	tween.tween_callback(reset_panel_position)
	
func reset_panel_position() -> void:
	wave_panel.position.x = -panel_width
	%next_wave_label.visible = false
	%next_wave_label.modulate.a = 0.0

func set_wave():
	current_wave+=1
	play_wave_panel()
