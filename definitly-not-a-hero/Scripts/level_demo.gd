extends Node2D


@onready var player: CharacterBody2D = $Player
@onready var gold_label: Label = $HUD/Gold/Gold_label
@onready var exp_label: Label = $HUD/exp_Bar/Exp_label
@onready var upgrade_menu: Node2D = $HUD/Upgrade_menu
@onready var upgrade_manager = $"/root/UpgradeManager"
@onready var exp_bar: ProgressBar = $HUD/exp_Bar
@onready var exp_marker: Marker2D = $HUD/exp_Bar/exp_marker
@onready var gold_marker: Marker2D = $HUD/Gold/gold_marker
@onready var animator: AnimationPlayer = $HUD/Next_wave_panel/AnimationPlayer
@onready var Wave_label: Label = $HUD/Next_wave_panel/PanelContainer/next_wave_label




func _ready():
	Events.leveling_up.connect(_on_player_level_up)
	Events.stats_changed.connect(_on_stats_changed)
	Events.next_wave.connect(set_wave)
	WaveManager.set_spawn_path(%SpawnCurves)  # spawnCurves est ton Path2D
	WaveManager.start_next_wave()	
	UpgradeManager.set_player(player)
	exp_marker.add_to_group("xp")
	gold_marker.add_to_group("gold_label")
	exp_bar.max_value = player.exp_to_next
	exp_bar.value = player.exp_actuel
	exp_label.text = "XP: O / "+ str(player.exp_to_next)
	
func _on_stats_changed(gold: int, xp: int) -> void:
	gold_label.text = " : " + str(gold) + " GOLD"
	exp_label.text = "XP: " + str(xp) + " / " + str(player.exp_to_next)
	animate_bar_to(player.exp_actuel)


func _on_player_level_up():
	upgrade_menu.player = player
	upgrade_menu.show_choices()
	exp_bar.max_value = player.exp_to_next

func animate_bar_to(new_value):
	var tw = create_tween()
	tw.tween_property(exp_bar, "value", new_value, 0.4).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)

func set_wave(current_wave,bosswave:bool = false):
	if bosswave:
		Wave_label.text = "!! BOSS !!"
	else:
		Wave_label.text = "Vague " + str(current_wave)
	animator.play("new wave")
