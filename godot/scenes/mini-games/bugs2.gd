extends Node

@onready var title = %Title
@onready var mini_game = %MiniGame

@onready var mob_spawn_path = %MobPath
@onready var mob_spawn_location = %MobSpawnLocation
@onready var mob_timer = %MobTimer
@onready var mob_scene = preload("res://scenes/entities/bug.tscn")

signal puzzle_solved()

const BUG_SMUSHED_WIN = 8
const BUG_VELOCITY_MIN = 120
const BUG_VELOCITY_MAX = 240
const BUG_RESPAWN_TIME = 0.1

var bug_smushed_counter = 0
var started = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	title.visible = true
	mini_game.visible = false
	mob_timer.stop()

func _process(delta: float) -> void:
	if not started:
		if Input.is_action_just_released("primary_action"):
			started = true
			title.visible = false
			mini_game.visible = true
			mob_timer.start(BUG_RESPAWN_TIME)
			return
	else:
		if bug_smushed_counter >= BUG_SMUSHED_WIN:
			puzzle_solved.emit()
			started = false
			return

func _on_mob_timer_timeout() -> void:
	# Create a new instance of the Mob scene.
	var mob = mob_scene.instantiate()
	mob.bug_smushed.connect(_bug_smushed)
	
	# Choose a random location on Path2D.
	mob_spawn_location.progress_ratio = randf()
	# Set the mob's direction perpendicular to the path direction.
	var direction = mob_spawn_location.rotation + PI / 2
	
	# Set the mob's position to a random location.
	mob.position = mob_spawn_location.position
	
	# Add some randomness to the direction.
	direction += randf_range(-PI / 4, PI / 4)
	mob.rotation = direction
	
	# Choose the velocity for the mob.
	var velocity = Vector2(randi_range(BUG_VELOCITY_MIN, BUG_VELOCITY_MAX), 0)
	mob.linear_velocity = velocity.rotated(direction)
	
	# Spawn the mob by adding it to the Main scene.
	add_child(mob)
	
func _bug_smushed() -> void:
	bug_smushed_counter = bug_smushed_counter + 1
