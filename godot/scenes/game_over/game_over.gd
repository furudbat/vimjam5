extends Node2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SoundManager.play_music_from_player($Bgm)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_back_to_main_menu_pressed() -> void:
	GlobalScenes.change_scene(GlobalScenes.Scenes.MainMenu)

func _on_restart_pressed() -> void:
	GlobalScenes.change_scene(GlobalScenes.Scenes.MainGame)
