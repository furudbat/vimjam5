# LineDrawer.gd
extends Node2D

var line_start: Vector2
var line_end: Vector2
var is_drawing = false

func _draw():
	if is_drawing:
		draw_line(line_start, line_end, ColorPalette.ACCENT, 2)
