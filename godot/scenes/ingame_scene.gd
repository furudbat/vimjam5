extends Node2D

# Scene Nodes
@onready var main_scene_container = %MainSceneContainer
@onready var beast_meter = %BeastMeter
@onready var distance_label = %Distance
@onready var level_timer = %LevelTimer
@onready var timer_ui = %TimerUI

# Scenes
var intro_scene = preload("res://scenes/intro.tscn")
var dummy_scene = preload("res://scenes/mini-games/dummy.tscn")
var main_scene_instance = null

var level = 0
var section = 0
var levels = [
	[ preload("res://scenes/maps/map_01.tscn") ]
]

# distance
var distance: int = Constants.START_DISTANCE
var player_pos_m: Vector2 = Vector2(0, distance)
var enemy_pos_m: Vector2 = Vector2(0, 0)

# movement/velocity
var player_velocity: Vector2 = Constants.START_PLAYER_VELOCITY
var player_acceleration_factor: float = Constants.START_PLAYER_ACCELERATION_FACTOR

var enemy_velocity: Vector2 = Constants.START_ENEMY_VELOCITY
var enemy_velocity_boost: float = Constants.START_ENEMY_VELOCITY_BOOST
var enemy_acceleration_factor: float = Constants.START_ENEMY_ACCELERATION_FACTOR
var enemy_boosted: bool = false


# game stats
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
	intro_instance.exit_intro.connect(_exit_intro)
	main_scene_instance = intro_instance
	main_scene_container.add_child(main_scene_instance)
	game_state = GameState.INTRO
	
	level_timer.autostart = false
	level_timer.one_shot = true
	level_timer.stop()
	level_timer.timeout.connect(_on_timer_timeout)
	
func _process(delta: float) -> void:
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
		player_velocity *= exp(player_acceleration_factor * delta)
		enemy_velocity *= exp(enemy_acceleration_factor * delta)
		player_velocity.y = min(player_velocity.y, Constants.PLAYER_MAX_VELOCITY.y)
		enemy_velocity.y = min(enemy_velocity.y, Constants.ENEMY_MAX_VELOCITY.y)
		if enemy_boosted:
			enemy_velocity_boost *= exp(enemy_acceleration_factor * delta)
		else:
			if player_state == CharacterState.STOPPED:
				enemy_velocity = Constants.ENEMY_VELOCITY_WHEN_PLAYER_STOPPED
		
		if player_state == CharacterState.RUNNING:
			player_pos_m = player_pos_m + (player_velocity * delta)
		if enemy_state == CharacterState.RUNNING:
			enemy_pos_m = enemy_pos_m + (enemy_velocity * delta * enemy_velocity_boost)
			
	if enemy_boosted:
		beast_meter.enemy_state = beast_meter.EnemyIconState.ANGRY
	else:
		beast_meter.enemy_state = beast_meter.EnemyIconState.NORMAL
	
	# Update distance
	distance = player_pos_m.y - enemy_pos_m.y
	## Game Over
	if distance <= 0:
		_game_over()
	beast_meter.distance = distance
	beast_meter.player_pos_m = player_pos_m.y
	beast_meter.enemy_pos_m = enemy_pos_m.y
	distance_label.text = "%4dm" % distance
	
	# Update timer
	timer_ui.time = level_timer.time_left
	
	# Update Map
	if game_state == GameState.MAP:
		if main_scene_instance != null:
			main_scene_instance.distance = distance
			main_scene_instance.player_velocity = player_velocity
			main_scene_instance.enemy_velocity = enemy_velocity
	
	# Debug
	if OS.is_debug_build():
		if Input.is_key_pressed(KEY_SPACE):
			player_state = CharacterState.STOPPED


func _exit_intro():
	if game_state == GameState.INTRO:
		game_state = GameState.MAP
		player_state = CharacterState.RUNNING
		enemy_state = CharacterState.RUNNING
		main_scene_container.remove_child(main_scene_instance)
		main_scene_instance = null
		level = 0
		section = 0
		_init_level()
		
func _next_level():
	# @TODO: go to next level
	_init_level()

func _init_level():
	var map_instance = levels[level][section].instantiate()
	map_instance.obstical_reached.connect(_obstical_reached)
	main_scene_instance = map_instance
	main_scene_container.add_child(main_scene_instance)
	level_timer.start(Constants.START_TIME_SEC)
	player_velocity = Constants.START_PLAYER_VELOCITY
	player_acceleration_factor = Constants.PLAYER_ACCELERATION_FACTOR
	
func _obstical_reached():
	# remove map scene
	main_scene_container.remove_child(main_scene_instance)
	main_scene_instance = null
	# @TODO: setup door scene
	var door_instance = dummy_scene.instantiate()
	door_instance.solve_puzzle.connect(_solve_puzzle)
	main_scene_instance = door_instance
	main_scene_container.add_child(main_scene_instance)
	game_state = GameState.OBSTACLE

func _game_over():
	game_state = GameState.GAME_OVER
	enemy_pos_m = player_pos_m
	distance = 0
	player_state = CharacterState.STOPPED
	enemy_state = CharacterState.STOPPED
	level_timer.stop()
	player_velocity = Vector2(0, 0)
	enemy_velocity = Vector2(0, 0)
	
func _solve_puzzle():
	if game_state == GameState.OBSTACLE:
		main_scene_container.remove_child(main_scene_instance)
		main_scene_instance = null
		_next_level()
		game_state = GameState.MAP
		# TODO: reset timer
		level_timer.start(30)
		enemy_boosted = false
		enemy_velocity_boost = 1.0
		player_velocity = Constants.START_PLAYER_VELOCITY
	
func _on_timer_timeout():
	enemy_boosted = true
	enemy_velocity_boost = 1.0
	
func _format_time(seconds: float):
	var minutes = int(seconds) / 60
	var remaining_seconds = int(seconds) % 60
	return "%02d:%02d" % [minutes, remaining_seconds]
	
