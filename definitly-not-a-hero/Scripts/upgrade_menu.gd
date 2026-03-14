extends Node2D

var player
func show_choices():
	visible = true
	get_tree().paused = true
	var choices = UpgradeManager.get_random_choices()
	for i in range(3):
		var upgrade_id = choices[i]
		var data = UpgradeManager.get_upgrade_data(upgrade_id)
		var button = get_node("HBoxContainer/upgrade_%d" % (i + 1))	
		#on debind les ancien event du bouton
		if button.is_connected("pressed",Callable(self, "_on_upgrade_selected")):
			button.disconnect("pressed",Callable(self, "_on_upgrade_selected"))
		button.text = data.text
		button.connect("pressed", Callable(self, "_on_upgrade_selected").bind(upgrade_id))

func _on_upgrade_selected(upgrade_id):
	player.apply_upgrade(upgrade_id)
	visible = false
	get_tree().paused = false
