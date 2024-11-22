extends HSlider

@export var property = ""

signal volume_changed(val)

var initialised = false

func _ready():
	value = UserSettings.get_value(property)

func _on_float_range_game_settings_option_value_changed(val):
	if !initialised:
		initialised = true
	else:
		volume_changed.emit(val)
	UserSettings.set_value(property, val)
