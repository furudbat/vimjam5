# LineDrawer.gd
extends Node2D

var line_start: Vector2
var line_end: Vector2
var is_drawing = false

@export var minimum_cut_length: float

func _draw():
	if is_drawing:
		var line_color = ColorPalette.ACCENT  # Default color
		if line_start.distance_to(line_end) < minimum_cut_length:
			line_color = ColorPalette.FONT_COLOR  # Change to a warning color (e.g., red)
		draw_line(line_start, line_end, line_color, 2)
