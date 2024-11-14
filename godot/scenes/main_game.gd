extends Node2D

# Scene Nodes
@onready var beast_meter = %BeastMeter
@onready var distance_label: Label = %Distance
@onready var level_timer: Timer = %LevelTimer
@onready var timer_ui = %TimerUI
@onready var content_container = %ContentContainer
@onready var player_path = %PlayerPath
@onready var player = %Player
@onready var enemy_path = %EnemyPath
@onready var enemy = %Enemy

# Scenes
var current_obstical_scene = null

var level = 0
var section = 0

# distance
var distance = Constants.START_DISTANCE
var player_pos_m: Vector2 = Vector2(0, distance)
var enemy_pos_m: Vector2 = Vector2(0, 0)

# movement/velocity
var player_velocity: Vector2 = Constants.START_PLAYER_VELOCITY
var player_acceleration_factor: float = Constants.START_PLAYER_ACCELERATION_FACTOR

var enemy_velocity: Vector2 = Constants.START_ENEMY_VELOCITY
var enemy_velocity_boost: float = Constants.START_ENEMY_VELOCITY_BOOST
var enemy_acceleration_factor: float = Constants.START_ENEMY_ACCELERATION_FACTOR
var enemy_boosted: bool = false

# door
var current_door = null

# game stats
enum CharacterState {
	RUNNING,
	STOPPED,
}
var player_state = CharacterState.STOPPED
var enemy_state = CharacterState.STOPPED

enum GameState {
	MAP,
	OBSTACLE,
	GAME_OVER,
	WIN,
}
var game_state = GameState.MAP
var door_markers = []
var doors = []


func _ready() -> void:
	for door in get_tree().get_nodes_in_group("Doors"):
		door.connect("body_entered", func(body): _on_door_entered(door, body))
		door.connect("body_exited", func(body): _on_door_exited(door, body))
		doors.append(door)
	for marker in get_tree().get_nodes_in_group("DoorMarkers"):
		door_markers.append(marker)
		
	level_timer.autostart = false
	level_timer.one_shot = true
	level_timer.stop()
	level_timer.timeout.connect(_on_timer_timeout)
	
	assert(Constants.MAX_LEVELS <= Constants.LEVELS.size())
	
	player_state = CharacterState.RUNNING
	enemy_state = CharacterState.RUNNING
	level = 0
	section = 0
	_init_level()
	
func _process(delta: float) -> void:
	if OS.is_debug_build():
		if Input.is_key_pressed(KEY_ENTER):
			if game_state == GameState.MAP:
				current_obstical_scene = load("res://scenes/mini-games/dummy.tscn").instantiate()
				current_obstical_scene.solve_puzzle.connect(_solve_puzzle)
				content_container.add_child(current_obstical_scene)
				game_state = GameState.OBSTACLE
				return
		
	if player_state == CharacterState.RUNNING and game_state == GameState.OBSTACLE:
		player_state = CharacterState.STOPPED
	elif player_state == CharacterState.STOPPED and game_state == GameState.MAP:
		player_state = CharacterState.RUNNING
			
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
	if game_state == GameState.MAP or game_state == GameState.OBSTACLE:
		timer_ui.time = level_timer.time_left
	
	# Update Map
	if game_state == GameState.MAP:
		pass
	
	# Debug
	if OS.is_debug_build():
		if Input.is_key_pressed(KEY_SPACE):
			player_state = CharacterState.STOPPED

func _physics_process(delta: float) -> void:
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
			
		if player_state == CharacterState.RUNNING:
			player_path.progress = player_path.progress + player_velocity.y
			
		enemy_path.progress = player_path.progress - distance*Constants.TILE_PX_PER_M

		
func _next_level():
	var current_level: Array = Constants.LEVELS[level]
	if section < current_level.size()-1:
		section = section + 1
	else:
		if level < Constants.MAX_LEVELS-1:
			level = level + 1
			section = 0
		else:
			# Last level pass, no level left ... win
			return false
			
	_init_level()
	return true

func _init_level():
	assert(level < Constants.LEVELS.size())
	assert(section < Constants.LEVELS[level].size())
	assert(level < Constants.LEVELS_TIME_SEC.size())
	
	# init level
	var map_marker = Constants.LEVELS[level][section]
	
	# setup player/enemy
	player_acceleration_factor = Constants.PLAYER_ACCELERATION_FACTOR
	if not enemy_boosted:
		level_timer.start(Constants.LEVELS_TIME_SEC[level])
		enemy_velocity_boost = 1.0
		if level == 0 and section == 0:
			player_velocity = Constants.START_PLAYER_VELOCITY
		else:
			player_velocity = Constants.NEXT_LEVEL_START_PLAYER_VELOCITY
	
func _obstical_reached(door):
	# overlay scene on map
	current_obstical_scene = load("res://scenes/mini-games/game1.tscn").instantiate()
	current_obstical_scene.solve_puzzle.connect(_solve_puzzle)
	content_container.add_child(current_obstical_scene)
	game_state = GameState.OBSTACLE
	current_door = door

func _game_over():
	game_state = GameState.GAME_OVER
	enemy_pos_m = player_pos_m
	distance = 0
	player_state = CharacterState.STOPPED
	enemy_state = CharacterState.STOPPED
	level_timer.stop()
	player_velocity = Vector2(0, 0)
	enemy_velocity = Vector2(0, 0)
	
func _win_game():
	game_state = GameState.WIN
	distance = 0
	player_state = CharacterState.STOPPED
	enemy_state = CharacterState.STOPPED
	level_timer.stop()
	player_velocity = Vector2(0, 0)
	enemy_velocity = Vector2(0, 0)
	# @TODO: go to win scene
	
func _solve_puzzle():
	if game_state == GameState.OBSTACLE:
		content_container.remove_child(current_obstical_scene)
		current_obstical_scene = null
		var door_collision: CollisionShape2D = current_door.get_node("CollisionShape2D")
		door_collision.disabled = true
		current_door = null
		if _next_level():
			game_state = GameState.MAP
		else:
			_win_game()
	
func _on_timer_timeout():
	enemy_boosted = true
	enemy_velocity_boost = 1.0
	
	

func _on_door_entered(door, body):
	if body.name == "Player":
		player_state = CharacterState.STOPPED
		_obstical_reached(door)

func _on_door_exited(door, body):
	pass
	
