extends Control

@onready var timer_label: Label = %Timer
@onready var timer_clock_icon = %TimerClockIcon

@export var time = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if time <= Constants.CLOCK_LOW_TIME_SEC:
		timer_label.add_theme_color_override("font_color", Color("#db7546"))
	else:
		timer_label.add_theme_color_override("font_color", Color("#bfcce2"))
		
	timer_clock_icon.time = time
	#timer_label.text = _format_time(time)
	timer_label.text = "%03d" % time
		
