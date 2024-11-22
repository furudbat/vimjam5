extends Node2D

# private
var _new_game: bool = true

@onready var continue_button := %ContinueButton
@onready var new_game_button := %NewGameButton
@onready var exit_button := %ExitButton

#
# build-in
#

func _ready() -> void:
	SoundManager.set_default_music_bus("Music")
	SoundManager.set_default_sound_bus("Sound")
	continue_button.visible = SaveGame.has_save() and SaveGame.ENABLED
	# @NOTE: disabled for web
	exit_button.visible = false
	SoundManager.play_music($Bgm1.stream)
	

#
# private
#

func _on_new_game_button_pressed() -> void:
	SoundManager.play_ui_sound($MenuSelect.stream)
	GlobalScenes.change_scene(GlobalScenes.Scenes.Prolog)
	
func _on_continue_button_pressed() -> void:
	SoundManager.play_ui_sound($MenuSelect.stream)
	_new_game = false
	GlobalScenes.change_scene(GlobalScenes.Scenes.Prolog)

func _on_exit_button_pressed() -> void:
	get_tree().quit()
