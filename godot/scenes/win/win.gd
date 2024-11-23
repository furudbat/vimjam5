extends Node2D

@export var time = 0

@onready var time_label := %Time

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# @TODO: play winning screen music
	SoundManager.stop_music(0.3)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	time_label.text = _format_time(time)


func _on_back_to_main_menu_pressed() -> void:
	GlobalScenes.change_scene(GlobalScenes.Scenes.MainMenu)

func _format_time(seconds: int) -> String:
	var minutes = seconds / 60
	var remaining_seconds = seconds % 60
	return "%02d:%02d" % [minutes, remaining_seconds]
