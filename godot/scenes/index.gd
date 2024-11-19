extends Node

@onready var MainMenuScene = load("res://scenes/main.tscn")
@onready var PrologScene = load("res://scenes/prolog/prolog.tscn")
@onready var MainGameScene = load("res://scenes/game/game.tscn")
@onready var GameOverScene = load("res://scenes/game_over/game_over.tscn")
@onready var WinScene = load("res://scenes/win/win.tscn")

var Scenes = {
	MainMenu = "res://scenes/main.tscn",
	Prolog = "res://scenes/prolog/prolog.tscn",
	MainGame = "res://scenes/game/game.tscn",
	GameOver = "res://scenes/game_over/game_over.tscn",
	Win = "res://scenes/win/win.tscn",
}

# Function to load a scene dynamically
func change_scene(scene_path: String) -> void:
	var scene = load(scene_path)
	if scene:
		get_tree().change_scene_to_packed(scene)
	else:
		print("Error: Failed to load scene at path: ", scene_path)
