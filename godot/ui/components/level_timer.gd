extends Control

@onready var timer_label: Label = %Timer
@onready var timer_clock_icon = %TimerClockIcon

@export var time: int = -1
var current_font_color = ColorPalette.FONT_COLOR

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if time >= 0:
		var new_font_color = ColorPalette.ACCENT if time <= Constants.CLOCK_LOW_TIME_SEC else ColorPalette.FONT_COLOR
		
		if current_font_color != new_font_color:
			current_font_color = new_font_color
			timer_label.add_theme_color_override("font_color", current_font_color)
			
		timer_clock_icon.time = time
		#timer_label.text = _format_time(time)
		timer_label.text = "%03d" % time
		
