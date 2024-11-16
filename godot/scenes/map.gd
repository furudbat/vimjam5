extends TileMapLayer

@onready var path = %Path2D
@onready var player_path = %PlayerPath
@onready var player = %Player
@onready var enemy_path = %EnemyPath
@onready var enemy = %Enemy

@export var active = false
@export var player_is_moving = false
@export var enemy_is_moving = false
@export var player_velocity: Vector2 = Vector2.ZERO
@export var enemy_velocity: Vector2 = Vector2.ZERO
@export var distance = 0

signal player_reach_end()
signal obstical_reached(tile, body, mini_game)
signal get_obsticales_counter(obsticales)

var inited_scene_tiles = false
var obsticales = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# connect tile signals
	if not inited_scene_tiles:
		for tile_child in get_children():
			# assume scene tiles are CharacterBody2D
			if tile_child is CharacterBody2D:
				if tile_child.player_entered_obsticale:
					tile_child.connect("player_entered_obsticale", _on_boulder_obstacle_reached)
					obsticales = obsticales + 1
					if OS.is_debug_build():
						print(obsticales, tile_child.name, tile_child)
				
		get_obsticales_counter.emit(obsticales)
		inited_scene_tiles = true                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  

	var enemy_direction = _get_direction_at_progress(path, enemy_path.progress_ratio)
	enemy.is_moving = enemy_is_moving
	enemy.direction = enemy_direction
	enemy.enemy_velocity = enemy_velocity
	
	var player_direction = _get_direction_at_progress(path, player_path.progress_ratio)
	player.is_moving = player_is_moving
	player.direction = player_direction
	player.player_velocity = player_velocity
	
	## Win
	if player_path.progress_ratio >= 1.0:
		player_reach_end.emit()
		return

func _physics_process(delta: float) -> void:
	if player_is_moving:
		player_path.progress = player_path.progress + player_velocity.y
	
	if enemy_is_moving:
		enemy_path.progress = player_path.progress - distance*Constants.TILE_PX_PER_M/2
	#if enemy_is_moving:
	#	enemy_path.progress = enemy_path.progress + enemy_velocity.y

func _get_direction_at_progress(path: Path2D, progress_ratio: float) -> Vector2:
	var curve = path.curve
	var path_length = curve.get_baked_length()
	var distance = progress_ratio * path_length

	var current_position = curve.sample_baked(distance)
	var next_position = curve.sample_baked(distance + 0.1)

	var direction = (current_position - next_position).normalized()
	return direction

func _on_boulder_obstacle_reached(node, body, mini_game) -> void:
	if OS.is_debug_build():
		print("Obstacle reached: ", node, " by ", body)
	obstical_reached.emit(node, body, mini_game)
