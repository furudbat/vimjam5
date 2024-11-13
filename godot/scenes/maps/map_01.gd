extends Node2D

# Scene Nodes
@onready var player_path := %PlayerPath
@onready var player := %Player
@onready var enemy_path := %EnemyPath
@onready var enemy := %Enemy

# Signals
signal obstical_reached()

# public
@export var player_velocity: Vector2 = Constants.START_PLAYER_VELOCITY
@export var enemy_velocity: Vector2 = Constants.START_ENEMY_VELOCITY
@export var distance = 0

# private
var player_stopped = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player_stopped = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	player.is_moving = !player_stopped
	var player_direction_x = player_path.transform.x.normalized()
	var player_direction_y = player_path.transform.y.normalized()
	player.direction = player_direction_y

func _physics_process(delta: float) -> void:
	if not player_stopped:
		player_path.progress += player_velocity.y * delta * Constants.MAP_MOVEMENT_SPEED_UP
	enemy_path.progress = player_path.progress - distance/2*Constants.TILE_PX_PER_M
	
	if player_path.progress_ratio >= 1.0 and not player_stopped:
		obstical_reached.emit()
		player_stopped = true
