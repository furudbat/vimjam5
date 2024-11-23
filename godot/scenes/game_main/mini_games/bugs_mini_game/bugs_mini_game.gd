extends MiniGame

@export var bug_smushed_win = 6
@export var bug_velocity_min = 50
@export var bug_velocity_max = 60
@export var bug_respawn_time = 0.3

var _bug_smushed_counter = 0

@onready var bug_sound := %BugSound1
@onready var all_bug_sound := %BugSound2
@onready var win_sound := %WinSoundPlayer

@onready var mob_spawn_path := %MobPath
@onready var mob_spawn_location := %MobSpawnLocation
@onready var mob_timer := %MobTimer

@onready var mob_scene = preload("./entities/bug/bug.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super()
	self.check_win_condition = func(): return _bug_smushed_counter >= bug_smushed_win
	on_started.connect(_on_started)
	on_won.connect(_on_won)

func _on_started() -> void:
	mob_timer.start(bug_respawn_time)

func _on_won() -> void:
	# delay smush all bugs
	await get_tree().create_timer(self.win_cooldown_sec/2).timeout
	all_bug_sound.pitch_scale = randf_range(0.83, 1.34)
	SoundManager.play_sound_from_player(all_bug_sound)

	var bugs = get_tree().get_nodes_in_group("Bugs")
	for bug in bugs:
		if bug.has_method("smush_bug"):
			bug.smush_bug()


func _on_mob_timer_timeout() -> void:
	if not has_won():
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
	
		# Spawn the mob by adding it to the Main scene.
		add_child(mob)
		mob.add_to_group("Bugs")
	
func _bug_smushed() -> void:
	if not has_won():
		_bug_smushed_counter = _bug_smushed_counter + 1
		bug_sound.pitch_scale = randf_range(0.83, 1.34)
		SoundManager.play_sound_from_player(bug_sound)
