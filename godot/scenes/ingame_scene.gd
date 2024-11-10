extends Node2D

@onready var main_scene_container = %MainSceneContainer
@onready var beast_meter = %BeastMeter
@onready var distance_label = %Distance

var intro_scene = preload("res://scenes/intro.tscn")
var dummy_scene = preload("res://scenes/dummy.tscn")
var main_scene_instance = null

const START_DISTANCE = 500

var distance: int = START_DISTANCE
var player_pos_m: Vector2 = Vector2(0, 0)
var enemy_pos_m: Vector2 = Vector2(0, player_pos_m.y - distance)

var player_velocity: Vector2 = Vector2(0, 5)
var enemy_velocity: Vector2 = Vector2(0, 3)
var enemy_velocity_boost: float = 1.0

enum CharacterState {
	RUNNING,
	STOPPED,
}
var player_state = CharacterState.STOPPED
var enemy_state = CharacterState.STOPPED

enum GameState {
	INTRO,
	MAP,
	OBSTACLE,
	GAME_OVER,
}
var game_state = GameState.INTRO


func _ready() -> void:
	var intro_instance = intro_scene.instantiate()
	game_state = GameState.INTRO
	intro_instance.exit_intro.connect(_exit_intro)
	main_scene_instance = intro_instance
	main_scene_container.add_child(main_scene_instance)
	
func _process(delta: float) -> void:
	if game_state == GameState.MAP:
		# TODO: process Map
		pass
		
	if OS.is_debug_build():
		if Input.is_key_pressed(KEY_ENTER):
			if game_state == GameState.MAP:
				game_state = GameState.OBSTACLE
				var dummy_instance = dummy_scene.instantiate()
				dummy_instance.solve_puzzle.connect(_solve_puzzle)
				main_scene_instance = dummy_instance
				main_scene_container.add_child(main_scene_instance)
		
	if player_state == CharacterState.RUNNING and game_state == GameState.OBSTACLE:
		player_state = CharacterState.STOPPED
	elif player_state == CharacterState.STOPPED and game_state == GameState.MAP:
		player_state = CharacterState.RUNNING
		
	if game_state == GameState.MAP or game_state == GameState.OBSTACLE:
		if player_state == CharacterState.RUNNING:
			player_pos_m = player_pos_m + (player_velocity * delta)
		if enemy_state == CharacterState.RUNNING:
			enemy_pos_m = enemy_pos_m + (enemy_velocity * delta * enemy_velocity_boost)
	
	distance = player_pos_m.y - enemy_pos_m.y
	if distance <= 0:
		_game_over()
	
	beast_meter.distance = distance
	distance_label.text = "%dm" % distance
	
	# Debug
	if OS.is_debug_build():
		if Input.is_key_pressed(KEY_SPACE):
			player_state = CharacterState.STOPPED


func _exit_intro():
	if game_state == GameState.INTRO:
		game_state = GameState.MAP
		player_state = CharacterState.RUNNING
		enemy_state = CharacterState.RUNNING
		# TODO: map scene
		main_scene_container.remove_child(main_scene_instance)
		main_scene_instance = null

func _game_over():
	game_state = GameState.GAME_OVER
	enemy_pos_m = player_pos_m
	distance = 0
	player_state = CharacterState.STOPPED
	enemy_state = CharacterState.STOPPED
	
func _solve_puzzle():
	if game_state == GameState.OBSTACLE:
		game_state = GameState.MAP
		# TODO: reset on map
		main_scene_container.remove_child(main_scene_instance)
		main_scene_instance = null
	
