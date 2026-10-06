extends Control


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	resized.connect(queue_redraw)


func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), Color("e6dfcf"))
	var random := RandomNumberGenerator.new()
	random.seed = 42
	for grain_index in range(900):
		var position := Vector2(random.randf() * size.x, random.randf() * size.y)
		draw_circle(position, random.randf_range(0.4, 1.5), Color(0.25, 0.21, 0.15, 0.035))
	for wash_index in range(5):
		var center := Vector2(size.x * 0.96, size.y * (0.28 + wash_index * 0.13))
		draw_circle(center, size.y * (0.15 + wash_index * 0.035), Color(0.23, 0.25, 0.22, 0.018))
	draw_line(Vector2(48, 48), Vector2(48, size.y - 48), Color(0.22, 0.20, 0.16, 0.16), 1)
	draw_line(Vector2(size.x - 48, 48), Vector2(size.x - 48, size.y - 48), Color(0.22, 0.20, 0.16, 0.16), 1)
