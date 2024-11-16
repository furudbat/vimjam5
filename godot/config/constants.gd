
# distance setting (beast meter) 
const MAX_DISTANCE_M: float = 200
## player/beast start distance at the game start
const START_DISTANCE = 50
const DISTANCE_LOW = 10

# timer UI
const CLOCK_LOW_TIME_SEC: float = 10.0

# Meter
const START_ENEMY_VELOCITY_BOOST: float = 1.0
const START_ENEMY_ACCELERATION_FACTOR: float = 0.6
const START_PLAYER_ACCELERATION_FACTOR: float = 0.5

const START_PLAYER_VELOCITY: Vector2 = Vector2(0, 0.75)
const NEXT_LEVEL_START_PLAYER_VELOCITY: Vector2 = Vector2(0, 1)
const START_ENEMY_VELOCITY: Vector2 = Vector2(0, 1)

const ENEMY_VELOCITY_WHEN_PLAYER_STOPPED: Vector2 = Vector2(0, 2.5)
const ENEMY_MAX_VELOCITY: Vector2 = Vector2(0, 1.2)

const PLAYER_ACCELERATION_FACTOR: float = 0.5
const PLAYER_MAX_VELOCITY: Vector2 = Vector2(0, 1.8)

# Map
const TILE_PX_PER_M: int = 16
const MAP_MOVEMENT_SPEED_UP: float = 0.40

# Levels
const MAX_GAMES = 1
# @FIXME: randomize levels
#func _random_game():
	#if MAX_GAMES == 0:
		#return 0
	#if MAX_GAMES == 1:
		#return 1
		#
	#var random = RandomNumberGenerator.new()
	#random.randomize()
	#return random.randi_range(1, MAX_GAMES)
#var LEVELS = [
	#[ 1, _random_game(), _random_game() ],
	#[ _random_game(), _random_game(), 1 ],
	#[ _random_game(), _random_game(), _random_game() ],
#]

const LEVELS_TIME_SEC = [
	40,
	60,
	20,
]
const MAX_SECTIONS = 3
const MAX_LEVELS = 3
