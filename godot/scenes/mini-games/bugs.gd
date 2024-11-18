extends Node

@onready var title := %Title
@onready var mini_game := %MiniGame
@onready var bug_sound := %BugSound1
@onready var win_sound := %WinSoundPlayer

@onready var mob_spawn_path := %MobPath
@onready var mob_spawn_location := %MobSpawnLocation
@onready var mob_timer := %MobTimer
@onready var mob_scene = preload("res://scenes/entities/bug.tscn")

signal puzzle_solved()

@export var bug_smushed_win = 6
@export var bug_velocity_min = 60
@export var bug_velocity_max = 120
@export var bug_respawn_time = 0.2

var bug_smushed_counter = 0
var started = false
var win_cooldown = 0
@export var win = false

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
			mob_timer.start(bug_respawn_time)
			return
	else:
		if not win and bug_smushed_counter >= bug_smushed_win:
			win = true
			#win_sound.play()
		if win:
			win_cooldown = win_cooldown + delta
		if win_cooldown >= 1.1:
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
	var velocity = Vector2(randi_range(bug_velocity_min, bug_velocity_max), 0)
	mob.linear_velocity = velocity.rotated(direction)
	
	if not win:
		# Spawn the mob by adding it to the Main scene.
		add_child(mob)
	
func _bug_smushed() -> void:
	if not win:
		bug_smushed_counter = bug_smushed_counter + 1
		if bug_sound:
			bug_sound.pitch_scale = randf_range(0.83, 1.34)
			bug_sound.play()
