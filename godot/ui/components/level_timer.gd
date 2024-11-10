extends Control

@onready var timer_label = %Timer
@onready var timer_clock_icon = %TimerClockIcon

@export var time = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	timer_clock_icon.time = time
	#timer_label.text = _format_time(time)
	timer_label.text = "%03d" % time
