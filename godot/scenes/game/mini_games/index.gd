extends Node

@onready var MiniGames = {
	"boulders": preload("res://scenes/game/mini_games/boulders/boulders.tscn"),
	"bugs": preload("res://scenes/game/mini_games/bugs/bugs.tscn"),
	"vines": preload("res://scenes/game/mini_games/vines/vines.tscn"),
	"boulders2": preload("res://scenes/game/mini_games/boulders/boulders_2.tscn"),
	"bugs2": preload("res://scenes/game/mini_games/bugs/bugs_2.tscn"),
	"vines2": preload("res://scenes/game/mini_games/vines/vines_2.tscn"),
}

func get_scene(scene_name: String):
	return MiniGames.get(scene_name)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
