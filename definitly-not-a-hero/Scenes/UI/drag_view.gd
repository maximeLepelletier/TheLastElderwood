extends Control

var dragging := false
var drag_start_mouse: Vector2
var drag_start_pos: Vector2

func _gui_input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			dragging = true
			drag_start_mouse = get_global_mouse_position()
			drag_start_pos = position
		else:
			dragging = false

	elif event is InputEventMouseMotion and dragging:
		var mouse_now := get_global_mouse_position()
		position = drag_start_pos + (mouse_now - drag_start_mouse)
		clamp_position()
		
func clamp_position():
	var view_size = $Wallpaper.size
	var content_size = size

	position.x = clamp(position.x, view_size.x - content_size.x, 0)
	position.y = clamp(position.y, view_size.y - content_size.y, 0)
