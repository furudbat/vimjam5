extends Node

const BORDER_WIDTH = 2

# Function to set up a global theme
func setup_global_theme():
	var theme = load("res://ui/theme.tres")
	
	# Configure styles for specific types of nodes
	# For example, setting colors for Label nodes
	if theme is Theme:
		# Background colors (for StyleBox backgrounds, etc.)
		var flat_filled_stylebox = StyleBoxFlat.new()
		flat_filled_stylebox.bg_color = ColorPalette.FONT_COLOR
		flat_filled_stylebox.corner_detail = 2
		
		var flat_bg_stylebox = StyleBoxFlat.new()
		flat_bg_stylebox.bg_color = ColorPalette.BACKGROUND
		flat_bg_stylebox.corner_detail = 2
		
		var flat_disabled_stylebox = StyleBoxFlat.new()
		flat_disabled_stylebox.bg_color = ColorPalette.FONT_COLOR
		flat_disabled_stylebox.corner_detail = 2
		
		var focus_stylebox = StyleBoxFlat.new()
		focus_stylebox.bg_color = Color.TRANSPARENT
		focus_stylebox.corner_detail = 2
		focus_stylebox.border_width_left = BORDER_WIDTH
		focus_stylebox.border_width_top = BORDER_WIDTH
		focus_stylebox.border_width_right = BORDER_WIDTH
		focus_stylebox.border_width_bottom = BORDER_WIDTH
		focus_stylebox.border_color = ColorPalette.ACCENT

		var hover_stylebox = StyleBoxFlat.new()
		hover_stylebox.bg_color = ColorPalette.BACKGROUND
		hover_stylebox.corner_detail = 2
		hover_stylebox.border_width_left = BORDER_WIDTH
		hover_stylebox.border_width_top = BORDER_WIDTH
		hover_stylebox.border_width_right = BORDER_WIDTH
		hover_stylebox.border_width_bottom = BORDER_WIDTH
		hover_stylebox.border_color = ColorPalette.ACCENT
		
		var bordered_flat_stylebox = StyleBoxFlat.new()
		bordered_flat_stylebox.bg_color = ColorPalette.BACKGROUND
		bordered_flat_stylebox.corner_detail = 2
		bordered_flat_stylebox.border_width_left = BORDER_WIDTH
		bordered_flat_stylebox.border_width_top = BORDER_WIDTH
		bordered_flat_stylebox.border_width_right = BORDER_WIDTH
		bordered_flat_stylebox.border_width_bottom = BORDER_WIDTH
		bordered_flat_stylebox.border_color = ColorPalette.FONT_COLOR
		
		var grabber_stylebox = StyleBoxFlat.new()
		grabber_stylebox.bg_color = ColorPalette.ACCENT
		grabber_stylebox.corner_detail = 8

		# Label
		## Font color (Label)
		theme.set_color("font_color", "Label", ColorPalette.FONT_COLOR)
		theme.set_color("font_outline_color", "Label", ColorPalette.FONT_COLOR)

		# Button
		## colors
		theme.set_color("font_color", "Button", ColorPalette.FONT_COLOR)
		theme.set_color("font_disabled_color", "Button", ColorPalette.BACKGROUND)
		theme.set_color("font_focus_color", "Button", ColorPalette.FONT_COLOR)
		theme.set_color("font_hover_color", "Button", ColorPalette.FONT_COLOR)
		theme.set_color("font_hover_pressed_color", "Button", ColorPalette.BACKGROUND)
		theme.set_color("font_outline_color", "Button", ColorPalette.FONT_COLOR)
		theme.set_color("font_pressed_color", "Button", ColorPalette.FONT_COLOR)
		theme.set_color("icon_disabled_color", "Button", ColorPalette.BACKGROUND)
		theme.set_color("icon_focus_color", "Button", ColorPalette.FONT_COLOR)
		theme.set_color("icon_hover_color", "Button", ColorPalette.FONT_COLOR)
		theme.set_color("icon_hover_pressed_color", "Button", ColorPalette.FONT_COLOR)
		theme.set_color("icon_normal_color", "Button", ColorPalette.FONT_COLOR)
		theme.set_color("icon_pressed_color", "Button", ColorPalette.FONT_COLOR)
		## bgs
		theme.set_stylebox("disabled", "Button", flat_filled_stylebox)
		theme.set_stylebox("focus", "Button", focus_stylebox)
		theme.set_stylebox("hover", "Button", hover_stylebox)
		theme.set_stylebox("normal", "Button", flat_bg_stylebox)
		theme.set_stylebox("pressed", "Button", bordered_flat_stylebox)
		
		# HSlider
		## bgs
		theme.set_stylebox("grabber_area", "HSlider", grabber_stylebox)
		theme.set_stylebox("grabber_area_highlight", "HSlider", grabber_stylebox)
		theme.set_stylebox("slider", "HSlider", bordered_flat_stylebox)

		# Apply the theme as a default theme for all nodes
		get_tree().root.theme = theme

func _ready():
	setup_global_theme()
