extends TileMapLayer

signal player_reach_end()
signal obstical_reached(node: CharacterBody2D, body: Node2D, mini_game: String)
signal get_obsticales_counter(obsticales: int)

@export var active: bool = false
@export var player_is_moving: bool = false
@export var enemy_is_moving: bool = false
@export var player_velocity: Vector2 = Vector2.ZERO
@export var enemy_velocity: Vector2 = Vector2.ZERO
@export var distance: int = 0

var _inited_scene_tiles: bool = false
var _obsticales: int = 0

# Scene Nodes
@onready var path := %Path2D
@onready var player_path := %PlayerPath
@onready var player := %Player
@onready var enemy_path := %EnemyPath
@onready var enemy := %Enemy
@onready var map_entities := %EntitiesLayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# connect tile signals
	if not _inited_scene_tiles:
		_obsticales = 0
		for tile_child in map_entities.get_children():
			# assume scene tiles are CharacterBody2D
			if tile_child is CharacterBody2D:
				if tile_child.player_entered_obsticale:
					tile_child.player_entered_obsticale.connect(_on_player_entered_obsticale)
					_obsticales += 1
				
		get_obsticales_counter.emit(_obsticales)
		_inited_scene_tiles = true                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              

	var enemy_direction = _get_direction_at_progress(path, enemy_path.progress_ratio)
	enemy.is_moving = enemy_is_moving
	enemy.direction = enemy_direction
	
	var player_direction = _get_direction_at_progress(path, player_path.progress_ratio)
	player.is_moving = player_is_moving
	player.direction = player_direction
	
	# Debug
	if OS.is_debug_build():
		if Input.is_key_pressed(KEY_F6):
			player_path.progress_ratio = 0.9

func _physics_process(delta: float) -> void:
	enemy.enemy_velocity = enemy_velocity
	player.player_velocity = player_velocity
	
	if player_is_moving:
		player_path.progress += player_velocity.y
	
	enemy_path.progress = player_path.progress - distance*Constants.TILE_PX_PER_M
	#if enemy_is_moving:
	#	enemy_path.progress = enemy_path.progress + enemy_velocity.y
	
	# Win
	if active and player_path.progress_ratio >= 1.0:
		player_reach_end.emit()
		return

func _get_direction_at_progress(direction_path: Path2D, progress_ratio: float) -> Vector2:
	var curve = direction_path.curve
	var path_length = curve.get_baked_length()
	var local_distance = progress_ratio * path_length

	var current_position = curve.sample_baked(local_distance)
	var next_position = curve.sample_baked(local_distance + 0.1)

	return (current_position - next_position).normalized()

func _on_player_entered_obsticale(node, body, mini_game: String) -> void:
	print_debug("Obstacle reached: ", node, " by ", body)
	obstical_reached.emit(node, body, mini_game)
