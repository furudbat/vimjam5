extends Node2D

@onready var continue_button := %ContinueButton
@onready var new_game_button := %NewGameButton
@onready var exit_button := %ExitButton

var new_game = true
var start_scene = load("res://scenes/prolog.tscn")

func _ready() -> void:
	continue_button.visible = SaveGame.has_save() and SaveGame.ENABLED
	# @NOTE: disabled for web
	exit_button.visible = false
	
	# connect signals
	new_game_button.pressed.connect(_on_new_game_button_pressed)
	continue_button.pressed.connect(_on_continue_button_pressed)
	exit_button.pressed.connect(_on_exit_button_pressed)
	
	if continue_button.visible:
		continue_button.grab_focus()
	else:
		new_game_button.grab_focus()
	
func _on_new_game_button_pressed() -> void:
	get_tree().change_scene_to_packed(start_scene)
	
func _on_continue_button_pressed() -> void:
	new_game = false
	get_tree().change_scene_to_packed(start_scene)

func _on_exit_button_pressed() -> void:
	get_tree().quit()
