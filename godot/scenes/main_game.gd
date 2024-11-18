extends Node2D

# Scene Nodes
@onready var beast_meter := %BeastMeter
@onready var distance_label := %Distance
@onready var level_timer := %LevelTimer
@onready var game_timer := %GameTimer
@onready var timer_ui := %TimerUI
@onready var content_container := %ContentContainer
@onready var map := %Map
@onready var beast_sound := %BeastSoundPlayer

var level = 0
var section = 0
var game_time = 0
var obsticales_counter = 0

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
var current_obstical_tile = null

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

var game_over_fadeout = 0
var game_over_scene = preload("res://scenes/game_over.tscn")


func _ready() -> void:
	level_timer.autostart = false
	level_timer.one_shot = true
	level_timer.stop()
	
	player_state = CharacterState.RUNNING
	enemy_state = CharacterState.RUNNING
	level = 0
	section = 0
	_reset_timer()
	level_timer.start(Constants.TIMER_TIME_SEC)
	
func _process(delta: float) -> void:
	if OS.is_debug_build():
		if Input.is_key_pressed(KEY_ENTER):
			if game_state == GameState.MAP:
				current_obstical_scene = load("res://scenes/mini-games/dummy.tscn").instantiate()
				current_obstical_scene.puzzle_solved.connect(_puzzle_solved)
				content_container.add_child(current_obstical_scene)
				game_state = GameState.OBSTACLE
				return
	if game_state == GameState.GAME_OVER:
		game_over_fadeout = game_over_fadeout + delta
		# TODO: show game over scren AFTER catch ???
		#if game_over_fadeout >= 1.0:
		#get_tree().current_scene.queue_free()
		#var game_over_scene = game_over_scene.instantiate()
		#get_tree().root.add_child(game_over_scene)
		#get_tree().current_scene = game_over_scene
		return
			
	if enemy_boosted:
		beast_meter.enemy_state = beast_meter.EnemyIconState.ANGRY
	else:
		beast_meter.enemy_state = beast_meter.EnemyIconState.NORMAL
	
	# Update distance
	distance = player_pos_m.y - enemy_pos_m.y
	distance = max(distance, 0)
	if distance <= 0:
		player_state = CharacterState.STOPPED
		enemy_state = CharacterState.STOPPED
	
	beast_meter.distance = distance
	beast_meter.player_pos_m = player_pos_m.y
	beast_meter.enemy_pos_m = enemy_pos_m.y
	distance_label.text = "%4dm" % distance
	
	# Update timer
	if game_state == GameState.MAP or game_state == GameState.OBSTACLE:
		timer_ui.time = level_timer.time_left
	
	# Update Map
	map.active = game_state == GameState.MAP
	map.enemy_is_moving = enemy_state == CharacterState.RUNNING
	map.enemy_velocity = enemy_velocity
	map.player_is_moving = player_state == CharacterState.RUNNING
	map.player_velocity = player_velocity
	map.distance = distance

	if game_state == GameState.MAP or game_state == GameState.OBSTACLE:
		## Game Over
		if distance <= 0:
			_game_over()
			return
	
	# Debug
	if OS.is_debug_build():
		if Input.is_key_pressed(KEY_SPACE):
			player_state = CharacterState.STOPPED
		if Input.is_key_pressed(KEY_BACKSPACE):
			enemy_state = CharacterState.STOPPED
		if Input.is_key_pressed(KEY_F3):
			_puzzle_solved()
		if Input.is_key_pressed(KEY_F4):
			distance = 0
			_game_over()
		if Input.is_key_pressed(KEY_F5):
			level_timer.stop()
			_on_timer_timeout()

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

func _next_level():
	if section < Constants.MAX_SECTIONS-1:
		section = section + 1
	else:
		if level < Constants.MAX_LEVELS-1:
			level = level + 1
			section = 0
			_reset_timer()
		else:
			# Last level pass, no level left ... win
			return false
			
	return true

func _reset_timer():
	# setup player/enemy
	player_acceleration_factor = Constants.PLAYER_ACCELERATION_FACTOR
	enemy_acceleration_factor = Constants.ENEMY_ACCELERATION_FACTOR
	if not enemy_boosted:
		#assert(level < Constants.LEVELS_TIME_SEC.size())
		#level_timer.start(Constants.LEVELS_TIME_SEC[level])
		enemy_velocity_boost = 1.0
		if level == 0 and section == 0:
			player_velocity = Constants.START_PLAYER_VELOCITY
		else:
			player_velocity = Constants.NEXT_LEVEL_START_PLAYER_VELOCITY
	
func _obstical_reached(tile, body, mini_game):
	if game_state == GameState.MAP:
		if not tile.open:
			current_obstical_scene = load("res://scenes/mini-games/%s.tscn" % mini_game).instantiate()
			current_obstical_scene.puzzle_solved.connect(_puzzle_solved)
			content_container.add_child(current_obstical_scene)
			game_state = GameState.OBSTACLE
			current_obstical_tile = tile
			player_state = CharacterState.STOPPED

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
	current_obstical_tile = null
	# @NOTE: show direct game over
	get_tree().current_scene.queue_free()
	var game_over_scene = game_over_scene.instantiate()
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
	current_obstical_tile = null
	var win_scene = preload("res://scenes/win.tscn").instantiate()
	win_scene.time = game_time
	get_tree().current_scene.queue_free()
	get_tree().root.add_child(win_scene)
	get_tree().current_scene = win_scene
	
func _puzzle_solved():
	if game_state == GameState.OBSTACLE:
		content_container.remove_child(current_obstical_scene)
		current_obstical_scene = null
		current_obstical_tile.open = true
		var door_collision: CollisionShape2D = current_obstical_tile.get_node("CollisionShape2D")
		door_collision.disabled = true
		current_obstical_tile.visible = false
		if OS.is_debug_build():
			print(current_obstical_tile)
		current_obstical_tile = null
		_next_level()
		player_state = CharacterState.RUNNING
		game_state = GameState.MAP
		player_velocity = Constants.START_PLAYER_VELOCITY
	

func _on_timer_timeout():
	enemy_boosted = true
	enemy_velocity_boost = 1.0
	enemy_acceleration_factor = Constants.BOOST_ENEMY_ACCELERATION_FACTOR
	beast_sound.play()

func _on_game_timer_timeout() -> void:
	game_time += 1

func _on_map_player_reach_end() -> void:
	_win_game()


func _on_map_get_obsticales_counter(obsticales) -> void:
	obsticales_counter = obsticales
	if OS.is_debug_build():
		print(obsticales_counter)
