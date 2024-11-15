extends Node2D

# Scene Nodes
@onready var beast_meter = %BeastMeter
@onready var distance_label: Label = %Distance
@onready var level_timer: Timer = %LevelTimer
@onready var game_timer: Timer = %GameTimer
@onready var timer_ui = %TimerUI
@onready var content_container = %ContentContainer
@onready var path = %Path2D
@onready var player_path = %PlayerPath
@onready var player = %Player
@onready var enemy_path = %EnemyPath
@onready var enemy = %Enemy


var level = 0
var section = 0
var game_time = 0

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

# obstical
var current_obstical_scene = null
var current_obstical = null

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
	_reset_timer()
	
func _process(delta: float) -> void:
	if OS.is_debug_build():
		if Input.is_key_pressed(KEY_ENTER):
			if game_state == GameState.MAP:
				current_obstical_scene = load("res://scenes/mini-games/dummy.tscn").instantiate()
				current_obstical_scene.puzzle_solved.connect(_puzzle_solved)
				content_container.add_child(current_obstical_scene)
				game_state = GameState.OBSTACLE
				return
			
	if enemy_boosted:
		beast_meter.enemy_state = beast_meter.EnemyIconState.ANGRY
	else:
		beast_meter.enemy_state = beast_meter.EnemyIconState.NORMAL
	
	# Update distance
	distance = player_pos_m.y - enemy_pos_m.y
	beast_meter.distance = distance
	beast_meter.player_pos_m = player_pos_m.y
	beast_meter.enemy_pos_m = enemy_pos_m.y
	distance_label.text = "%4dm" % distance
	
	# Update timer
	if game_state == GameState.MAP or game_state == GameState.OBSTACLE:
		timer_ui.time = level_timer.time_left
	
	# Update Map
	if game_state == GameState.MAP:
		var enemy_direction = _get_direction_at_progress(path, enemy_path.progress_ratio)
		enemy.is_moving = enemy_state == CharacterState.RUNNING
		enemy.direction = enemy_direction
		enemy.enemy_velocity = enemy_velocity
		
		var player_direction = _get_direction_at_progress(path, player_path.progress_ratio)
		player.is_moving = player_state == CharacterState.RUNNING
		player.direction = player_direction
		player.player_velocity = player_velocity
		
		## Win
		if player_path.progress_ratio >= 1.0:
			_win_game()
			return
			
	if game_state == GameState.MAP or game_state == GameState.OBSTACLE:
		## Game Over
		if distance <= 0:
			_game_over()
			return
	
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
			
		enemy_path.progress = player_path.progress - distance*Constants.TILE_PX_PER_M/2
		#if enemy_state == CharacterState.RUNNING:
		#	enemy_path.progress = enemy_path.progress + enemy_velocity.y

		
func _next_level():
	var current_level: Array = Constants.LEVELS[level]
	if section < current_level.size()-1:
		section = section + 1
	else:
		if level < Constants.MAX_LEVELS-1:
			level = level + 1
			section = 0
			_reset_timer()
		else:
			# Last level pass, no level left ... win
			return false
			
	assert(level < Constants.LEVELS.size())
	assert(section < Constants.LEVELS[level].size())
	assert(level < Constants.LEVELS_TIME_SEC.size())
	return true

func _reset_timer():
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
	if game_state == GameState.MAP:
		var game_nr = Constants.LEVELS[level][section]
		# overlay scene on map
		current_obstical_scene = load("res://scenes/mini-games/game%d.tscn" % game_nr).instantiate()
		current_obstical_scene.puzzle_solved.connect(_puzzle_solved)
		content_container.add_child(current_obstical_scene)
		game_state = GameState.OBSTACLE
		player_state = CharacterState.STOPPED
		current_obstical = door

func _game_over():
	game_timer.paused = true
	game_state = GameState.GAME_OVER
	enemy_pos_m = player_pos_m
	distance = 0
	player_state = CharacterState.STOPPED
	enemy_state = CharacterState.STOPPED
	level_timer.stop()
	player_velocity = Vector2.ZERO
	enemy_velocity = Vector2.ZERO
	if current_obstical_scene:
		content_container.remove_child(current_obstical_scene)
	current_obstical_scene = null
	get_tree().current_scene.queue_free()
	var game_over_scene = preload("res://scenes/game_over.tscn").instantiate()
	get_tree().root.add_child(game_over_scene)
	get_tree().current_scene = game_over_scene
	
func _win_game():
	game_timer.paused = true
	game_state = GameState.WIN
	player_state = CharacterState.STOPPED
	enemy_state = CharacterState.STOPPED
	level_timer.paused = true
	player_velocity = Vector2.ZERO
	enemy_velocity = Vector2.ZERO
	if current_obstical_scene:
		content_container.remove_child(current_obstical_scene)
	current_obstical_scene = null
	var win_scene = preload("res://scenes/win.tscn").instantiate()
	win_scene.time = game_time
	get_tree().current_scene.queue_free()
	get_tree().root.add_child(win_scene)
	get_tree().current_scene = win_scene
	
func _puzzle_solved():
	if game_state == GameState.OBSTACLE:
		content_container.remove_child(current_obstical_scene)
		current_obstical_scene = null
		var door_collision: CollisionShape2D = current_obstical.get_node("CollisionShape2D")
		door_collision.disabled = true
		current_obstical = null
		if _next_level():
			player_state = CharacterState.RUNNING
			game_state = GameState.MAP
			player_velocity = Constants.START_PLAYER_VELOCITY
		else:
			_win_game()
	
func _on_timer_timeout():
	enemy_boosted = true
	enemy_velocity_boost = 1.0
	

func _on_door_entered(door, body):
	if body.name == "Player":
		_obstical_reached(door)

func _on_door_exited(door, body):
	pass
	#if body.name == "Player":
	#	player_velocity.y = Constants.PLAYER_MAX_VELOCITY.y
	
func _get_direction_at_progress(path: Path2D, progress_ratio: float) -> Vector2:
	var curve = path.curve
	var path_length = curve.get_baked_length()
	var distance = progress_ratio * path_length

	var current_position = curve.sample_baked(distance)
	var next_position = curve.sample_baked(distance + 0.1)

	var direction = (current_position - next_position).normalized()
	return direction


func _on_game_timer_timeout() -> void:
	game_time += 1
