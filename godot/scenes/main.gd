extends Node2D

# private
var _new_game: bool = true

@onready var continue_button := %ContinueButton
@onready var new_game_button := %NewGameButton
@onready var exit_button := %ExitButton
@onready var transition := %Transition

#
# build-in
#

func _ready() -> void:
	SoundManager.set_default_music_bus("Music")
	SoundManager.set_default_sound_bus("Sound")
	continue_button.visible = SaveGame.has_save() and SaveGame.ENABLED
	if OS.has_feature("HTML5"):
		# @NOTE: disabled for web
		exit_button.visible = false
	SoundManager.play_music_from_player($Bgm1)
	
func _input(event: InputEvent) -> void:
	if OS.is_debug_build() or (OS.has_feature("Windows") or OS.has_feature("OSX") or OS.has_feature("Linux")):
		if event is InputEventKey and not event.pressed:
			if event.keycode == KEY_F11:
				UserSettings.toggle_fullscreen()

#
# private
#

func _on_new_game_button_pressed() -> void:
	#SoundManager.play_ui_sound_from_player($MenuSelect)
	Transition.change_scene(GlobalScenes.Scenes.Prolog, 0.5)
	
func _on_continue_button_pressed() -> void:
	#SoundManager.play_ui_sound_from_player($MenuSelect)
	_new_game = false
	Transition.change_scene(GlobalScenes.Scenes.Prolog, 0.5)

func _on_exit_button_pressed() -> void:
	get_tree().quit()
