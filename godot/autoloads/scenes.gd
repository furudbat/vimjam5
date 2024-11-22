extends Node

@onready var MainMenuScene = load("res://scenes/main.tscn")
@onready var PrologScene = load("res://scenes/prolog/prolog.tscn")
@onready var MainGameScene = load("res://scenes/game/game.tscn")
@onready var GameOverScene = load("res://scenes/game_over/game_over.tscn")
@onready var WinScene = load("res://scenes/win/win.tscn")

# @NOTE(Scenes): add new (main) scenes here
var Scenes = {
	MainMenu = "res://scenes/main.tscn",
	Prolog = "res://scenes/prolog/prolog.tscn",
	MainGame = "res://scenes/game_main/game_main.tscn",
	GameOver = "res://scenes/game_over/game_over.tscn",
	Win = "res://scenes/win/win.tscn",
}
# @NOTE: use paths for scene, can preload scenes (cuz circle dependencies)

# check for valid path (strings)
func _ready() -> void:
	for scene_name in Scenes.keys():
		var scene_path = Scenes[scene_name]
		assert(ResourceLoader.exists(scene_path), "Invalid path: %s" % scene_path)

# Function to load a scene dynamically
func change_scene(scene_path: String) -> void:
	var scene = load(scene_path)
	if scene:
		get_tree().change_scene_to_packed(scene)
	else:
		push_error("Failed to load scene at path: ", scene_path)

func change_scene_by_name(scene_name: String) -> void:
	assert(Scenes[scene_name])
	var scene = load(Scenes[scene_name])
	if scene:
		get_tree().change_scene_to_packed(scene)
	else:
		push_error("Failed to load scene: ", scene_name)
