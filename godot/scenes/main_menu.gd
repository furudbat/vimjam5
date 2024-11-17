extends Node2D

@onready var continue_button := %ContinueButton
@onready var new_game_button := %NewGameButton
@onready var exit_button := %ExitButton
@onready var button_sound := %ButtonSoundPlayer

var new_game = true

func _ready() -> void:
	continue_button.visible = SaveGame.has_save() and SaveGame.ENABLED
	# @NOTE: disabled for web
	exit_button.visible = false
	
	# connect signals
	new_game_button.pressed.connect(_on_new_game_button_pressed)
	continue_button.pressed.connect(_on_continue_button_pressed)
	exit_button.pressed.connect(_on_exit_button_pressed)
	
	TitleBgm.autoplay = true
	TitleBgm.play()
	
func _on_new_game_button_pressed() -> void:
	# @FIXME: play button across scene transition
	#button_sound.play()
	get_tree().change_scene_to_file("res://scenes/prolog.tscn")
	
func _on_continue_button_pressed() -> void:
	new_game = false
	# @FIXME: play button across scene transition
	#button_sound.play()
	get_tree().change_scene_to_file("res://scenes/prolog.tscn")

func _on_exit_button_pressed() -> void:
	get_tree().quit()
