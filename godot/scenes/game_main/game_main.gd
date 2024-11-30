extends Node2D

enum CharacterState {
	RUNNING,
	STOPPED,
}
enum GameState {
	MAP,
	OBSTACLE,
	GAME_OVER,
	WIN,
}

var _level: int = 0
var _section: int = 0
var _game_time: int = 0
var _obsticales_counter: int = 0

# distance
var _distance: int = Constants.START_DISTANCE
var _player_pos_m: Vector2 = Vector2(0, _distance)
var _enemy_pos_m: Vector2 = Vector2(0, 0)

# movement/velocity
var _player_velocity: Vector2 = Constants.START_PLAYER_VELOCITY
var _player_acceleration_factor: float = Constants.START_PLAYER_ACCELERATION_FACTOR

var _enemy_velocity: Vector2 = Constants.START_ENEMY_VELOCITY
var _enemy_velocity_boost: float = Constants.START_ENEMY_VELOCITY_BOOST
var _enemy_acceleration_factor: float = Constants.START_ENEMY_ACCELERATION_FACTOR
var _enemy_boosted: bool = false

# obstical
var _current_obstical_scene: Node = null
var _current_obstical_tile: Node = null

# game stats
var _player_state := CharacterState.STOPPED
var _enemy_state := CharacterState.STOPPED
var _game_state := GameState.MAP
var _game_over_fadeout: float = 0

# Scene Nodes
@onready var beast_meter := %BeastMeter
@onready var distance_label := %Distance
@onready var level_timer := %LevelTimer
@onready var game_timer := %GameTimer
@onready var timer_ui := %TimerUI
@onready var content_container := %ContentContainer
@onready var map := %Map
@onready var beast_sound_1 := %BeastSoundPlayer1
@onready var beast_sound_2 := %BeastSoundPlayer2
@onready var beast_sound_cooldown_timer := %BeastSoundCooldownTimer

func _ready() -> void:
	level_timer.autostart = false
	level_timer.one_shot = true
	level_timer.stop()
	
	_player_state = CharacterState.RUNNING
	_enemy_state = CharacterState.RUNNING
	_level = 0
	_section = 0
	_reset_timer()
	level_timer.start(Constants.LEVEL_TIMER_SEC)
	beast_sound_cooldown_timer.stop()
	
	SoundManager.play_music_from_player($Bgm, 0.5)
	
func _process(delta: float) -> void:
	if _game_state == GameState.GAME_OVER:
		_game_over_fadeout = _game_over_fadeout + delta
		# TODO: show game over scren AFTER catch ???
		#if game_over_fadeout >= 1.0:
		#get_tree().current_scene.queue_free()
		#var game_over_scene = game_over_scene.instantiate()
		#get_tree().root.add_child(game_over_scene)
		#get_tree().current_scene = game_over_scene
		return
			
	if _enemy_boosted:
		beast_meter.enemy_state = beast_meter.EnemyIconState.ANGRY
	else:
		beast_meter.enemy_state = beast_meter.EnemyIconState.NORMAL
	
	# Update distance
	_distance = max(_player_pos_m.y - _enemy_pos_m.y, 0)
	if _distance <= 0:
		_player_state = CharacterState.STOPPED
		_enemy_state = CharacterState.STOPPED
	
	beast_meter.distance = _distance
	beast_meter.player_pos_m = _player_pos_m.y
	beast_meter.enemy_pos_m = _enemy_pos_m.y
	distance_label.text = "%4dm" % _distance
	
	# Update timer
	if _game_state == GameState.MAP or _game_state == GameState.OBSTACLE:
		timer_ui.time = level_timer.time_left
	
	# Update Map
	map.active = _game_state == GameState.MAP
	map.enemy_is_moving = _enemy_state == CharacterState.RUNNING
	map.enemy_velocity = _enemy_velocity
	map.player_is_moving = _player_state == CharacterState.RUNNING
	map.player_velocity = _player_velocity
	map.distance = _distance

	if _game_state == GameState.MAP or _game_state == GameState.OBSTACLE:
		## Game Over
		if _distance <= 0:
			_game_over()
			return
		if _game_state == GameState.OBSTACLE:
			# play beast alert sound
			if beast_sound_cooldown_timer.is_stopped() and level_timer.time_left > 0.0 and _distance > 0:
				if level_timer.time_left <= Constants.CLOCK_LOW_TIME_SEC:
					beast_sound_1.pitch_scale = randf_range(1.7, 1.8)
					SoundManager.play_sound_from_player(beast_sound_1)
					beast_sound_cooldown_timer.start(10)
				elif _distance <= Constants.DISTANCE_CRITICAL:
					beast_sound_1.pitch_scale = randf_range(1.6, 1.8)
					SoundManager.play_sound_from_player(beast_sound_1)
					beast_sound_cooldown_timer.start(8)
				elif _distance <= Constants.DISTANCE_LOW:
					beast_sound_2.pitch_scale = randf_range(1.7, 1.8)
					SoundManager.play_sound_from_player(beast_sound_2)
					beast_sound_cooldown_timer.start(5)

func _physics_process(delta: float) -> void:
	if _game_state == GameState.MAP or _game_state == GameState.OBSTACLE:
		_player_velocity *= exp(_player_acceleration_factor * delta)
		_enemy_velocity *= exp(_enemy_acceleration_factor * delta)
		_player_velocity.y = min(_player_velocity.y, Constants.PLAYER_MAX_VELOCITY.y)
		_enemy_velocity.y = min(_enemy_velocity.y, Constants.ENEMY_MAX_VELOCITY.y)
		if _enemy_boosted:
			_enemy_velocity_boost *= exp(_enemy_acceleration_factor * delta)
		else:
			if _player_state == CharacterState.STOPPED:
				_enemy_velocity = Constants.ENEMY_VELOCITY_WHEN_PLAYER_STOPPED
		
		if _player_state == CharacterState.RUNNING:
			_player_pos_m = _player_pos_m + (_player_velocity * delta)
		if _enemy_state == CharacterState.RUNNING:
			_enemy_pos_m = _enemy_pos_m + (_enemy_velocity * delta * _enemy_velocity_boost)

func _next_level():
	if _section < Constants.MAX_SECTIONS-1:
		_section += 1
	else:
		if _level < Constants.MAX_LEVELS-1:
			_level += 1
			_section = 0
			_reset_timer()
		else:
			# Last level pass, no level left ... win
			return false
			
	return true

func _reset_timer():
	# setup player/enemy
	_player_acceleration_factor = Constants.PLAYER_ACCELERATION_FACTOR
	_enemy_acceleration_factor = Constants.ENEMY_ACCELERATION_FACTOR
	if not _enemy_boosted:
		#assert(level < Constants.LEVELS_TIME_SEC.size())
		#level_timer.start(Constants.LEVELS_TIME_SEC[level])
		_enemy_velocity_boost = 1.0
		if _level == 0 and _section == 0:
			_player_velocity = Constants.START_PLAYER_VELOCITY
		else:
			_player_velocity = Constants.NEXT_LEVEL_START_PLAYER_VELOCITY
	
func _obstical_reached(tile, _body, mini_game: String):
	if _game_state == GameState.MAP:
		if not tile.open:
			_current_obstical_scene = MiniGames.get_scene(mini_game).instantiate()
			_current_obstical_scene.puzzle_solved.connect(_puzzle_solved)
			content_container.add_child(_current_obstical_scene)
			_game_state = GameState.OBSTACLE
			_current_obstical_tile = tile
			_player_state = CharacterState.STOPPED

func _game_over():
	game_timer.paused = true
	_game_state = GameState.GAME_OVER
	_enemy_pos_m = _player_pos_m
	_distance = 0
	_player_state = CharacterState.STOPPED
	_enemy_state = CharacterState.STOPPED
	level_timer.stop()
	_player_velocity = Vector2.ZERO
	_enemy_velocity = Vector2.ZERO
	if _current_obstical_scene:
		content_container.remove_child(_current_obstical_scene)
	_current_obstical_scene = null
	_current_obstical_tile = null
	# @NOTE: show direct game over
	Transition.change_scene(GlobalScenes.Scenes.GameOver, 0.25)
	
func _win_game():
	game_timer.paused = true
	_game_state = GameState.WIN
	_player_state = CharacterState.STOPPED
	_enemy_state = CharacterState.STOPPED
	level_timer.paused = true
	_player_velocity = Vector2.ZERO
	_enemy_velocity = Vector2.ZERO
	if _current_obstical_scene:
		content_container.remove_child(_current_obstical_scene)
	_current_obstical_scene = null
	_current_obstical_tile = null
	Transition.change_scene(GlobalScenes.Scenes.Win, 0.25, { time = _game_time })
	#var win_scene = GlobalScenes.WinScene.instantiate()
	#win_scene.time = _game_time
	#get_tree().current_scene.queue_free()
	#get_tree().root.add_child(win_scene)
	#get_tree().current_scene = win_scene
	
func _puzzle_solved():
	if _game_state == GameState.OBSTACLE:
		content_container.remove_child(_current_obstical_scene)
		_current_obstical_scene = null
		_current_obstical_tile.open = true
		var door_collision: CollisionShape2D = _current_obstical_tile.get_node("CollisionShape2D")
		door_collision.disabled = true
		_current_obstical_tile.visible = false
		_current_obstical_tile = null
		_next_level()
		_player_state = CharacterState.RUNNING
		_game_state = GameState.MAP
		_player_velocity = Constants.START_PLAYER_VELOCITY
	

func _on_timer_timeout():
	_enemy_boosted = true
	_enemy_velocity_boost = 1.0
	_enemy_acceleration_factor = Constants.BOOST_ENEMY_ACCELERATION_FACTOR
	SoundManager.play_sound_from_player(beast_sound_1)

func _on_game_timer_timeout() -> void:
	_game_time += 1

func _on_map_player_reach_end() -> void:
	_win_game()

func _on_map_get_obsticales_counter(obsticales: int) -> void:
	_obsticales_counter = obsticales

func _input(event: InputEvent) -> void:
	# Debug
	if OS.is_debug_build():
		if event is InputEventKey and not event.pressed:
			if event.keycode == KEY_SPACE:
				_player_state = CharacterState.STOPPED
			if event.keycode == KEY_BACKSPACE:
				_enemy_state = CharacterState.STOPPED
			if event.keycode == KEY_F3:
				_puzzle_solved()
			if event.keycode == KEY_F4:
				_distance = 0
				_game_over()
			if event.keycode == KEY_F5:
				level_timer.stop()
				_on_timer_timeout()
