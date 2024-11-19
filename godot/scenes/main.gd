extends Node2D

# private
var _new_game: bool = true

@onready var continue_button := %ContinueButton
@onready var new_game_button := %NewGameButton
@onready var exit_button := %ExitButton
@onready var button_sound := %ButtonSoundPlayer

#
# build-in
#

func _ready() -> void:
	continue_button.visible = SaveGame.has_save() and SaveGame.ENABLED
	# @NOTE: disabled for web
	exit_button.visible = false
	
	TitleBgm.autoplay = true
	TitleBgm.play()
	

#
# private
#

func _on_new_game_button_pressed() -> void:
	# @FIXME: play button across scene transition
	#button_sound.play()
	GlobalScenes.change_scene(GlobalScenes.Scenes.Prolog)
	
func _on_continue_button_pressed() -> void:
	_new_game = false
	# @FIXME: play button across scene transition
	#button_sound.play()
	GlobalScenes.change_scene(GlobalScenes.Scenes.Prolog)

func _on_exit_button_pressed() -> void:
	get_tree().quit()
