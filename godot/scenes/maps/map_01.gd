extends Node2D

@onready var player_path := %PlayerPath
@onready var enemy_path := %EnemyPath

signal obstical_reached()

@export var player_velocity: Vector2 = Constants.START_PLAYER_VELOCITY
@export var enemy_velocity: Vector2 = Constants.START_ENEMY_VELOCITY
@export var distance = 0

var player_stopped = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player_stopped = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if not player_stopped:
		player_path.progress += player_velocity.y * delta * Constants.MAP_MOVEMENT_SPEED_UP
		
	#enemy_path.progress = player_path.progress - distance*Constants.TILE_PX_PER_M
	
	if player_path.progress_ratio >= 1.0 and not player_stopped:
		obstical_reached.emit()
		player_stopped = true
