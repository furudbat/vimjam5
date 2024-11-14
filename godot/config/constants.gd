
# distance setting (beast meter) 
const MAX_DISTANCE_M: float = 600
## player/beast start distance at the game start
const START_DISTANCE = MAX_DISTANCE_M/4

# timer UI
const CLOCK_LOW_TIME_SEC: float = 10.0

# Meter
const START_ENEMY_VELOCITY_BOOST: float = 1.0
const START_ENEMY_ACCELERATION_FACTOR: float = 0.75
const START_PLAYER_ACCELERATION_FACTOR: float = 0.5

const START_PLAYER_VELOCITY: Vector2 = Vector2(0, 1)
const NEXT_LEVEL_START_PLAYER_VELOCITY: Vector2 = Vector2(0, 2)
const START_ENEMY_VELOCITY: Vector2 = Vector2(0, 1)

const ENEMY_VELOCITY_WHEN_PLAYER_STOPPED: Vector2 = Vector2(0, 4)
const ENEMY_MAX_VELOCITY: Vector2 = Vector2(0, 3)

const PLAYER_ACCELERATION_FACTOR: float = 0.75
const PLAYER_MAX_VELOCITY: Vector2 = Vector2(0, 6)

# Map
const TILE_PX_PER_M: int = 32
const MAP_MOVEMENT_SPEED_UP: float = 5.2

# Levels
const LEVELS = [
	[ 1, 2, 3 ],
	[ 4, 5, 6 ],
	[ 7, 8, 9 ],
]
const LEVELS_TIME_SEC = [
	60,
	60,
	60
]
const MAX_LEVELS = 3
