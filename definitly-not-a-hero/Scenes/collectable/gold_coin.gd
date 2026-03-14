extends Sprite2D


var player
var gold_label

func _ready():
	player = get_tree().get_first_node_in_group("player")
	var gold_label = get_tree().get_first_node_in_group("gold_label")
	var ui_global_pos: Vector2 = get_global_transform_with_canvas() * gold_label.global_position
	# Coordonnées monde correspondantes
	var tw = create_tween()
	# Petit flottement (random)
	var offset = Vector2(randf_range(-30,30), randf_range(-30,0))
	tw.tween_property(self, "position", position + offset, 0.25)

	# Micro délai
	await get_tree().create_timer(0.3).timeout

	# Vol vers la barre d’XP
	var target = ui_global_pos
	tw = create_tween()
	tw.tween_property(self, "global_position", target, 0.6).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)

	await tw.finished
	if player.has_method("add_exp"):
		player.add_gold(1)
	queue_free()
