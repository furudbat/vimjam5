extends Node2D

@export var time = 0

@onready var time_label := %Time

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SoundManager.play_music_from_player($Bgm, 0.3)

func _on_transition_finished(params):
	time = params.time

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	time_label.text = _format_time(time)


func _on_back_to_main_menu_pressed() -> void:
	Transition.change_scene(GlobalScenes.Scenes.MainMenu, 0.3)

func _format_time(seconds: int) -> String:
	var minutes = seconds / 60
	var remaining_seconds = seconds % 60
	return "%02d:%02d" % [minutes, remaining_seconds]
