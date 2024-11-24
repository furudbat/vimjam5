extends Node

# @NOTE(MiniGames): add new MiniGames here, for tiles (mini game name in tile: mini game scene)
@onready var MiniGames = {
	"boulders1": preload("res://scenes/game_main/mini_games/boulders_mini_game/boulders_mini_game_1.tscn"),
	"bugs1": preload("res://scenes/game_main/mini_games/bugs_mini_game/bugs_mini_game_1.tscn"),
	"vines1": preload("res://scenes/game_main/mini_games/vines_mini_game/vines_mini_game_1.tscn"),
	"discs1": preload("res://scenes/game_main/mini_games/discs_mini_game/discs_mini_game_1.tscn"),
	"boulders2": preload("res://scenes/game_main/mini_games/boulders_mini_game/boulders_mini_game_2.tscn"),
	"bugs2": preload("res://scenes/game_main/mini_games/bugs_mini_game/bugs_mini_game_2.tscn"),
	"vines2": preload("res://scenes/game_main/mini_games/vines_mini_game/vines_mini_game_2.tscn"),
	"discs2": preload("res://scenes/game_main/mini_games/discs_mini_game/discs_mini_game_2.tscn"),
}

func get_scene(scene_name: String):
	assert(MiniGames.has(scene_name))
	return MiniGames.get(scene_name)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
