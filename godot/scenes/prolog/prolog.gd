extends Node2D

const SKIP_AT_TIME = 0.9
const MAX_PANELS = 6
const START_AT_TIME = 0.9

var _skip_time_pressed = 0
var _panel = 1
var _start_coolown = 0

var _fall_sound: AudioStreamPlayer = null
var _beast_sound: AudioStreamPlayer = null

@onready var slide_show_animation := %SlideShow
@onready var skip_progress := %SkipProgressBar

@onready var fire_sound := %FireSoundPlayer
@onready var click_sound := %ClickSoundPlayer
@onready var cave_sound := %CaveSoundPlayer
@onready var fall_sound := %FallSoundPlayer
@onready var beast_sound := %BeastSoundPlayer
@onready var bush_sound := %RustlingSoundPlayer
@onready var land_sound := %LandingSoundPlayer
@onready var run_sound := %RunSoundPlayer

@onready var main_game_scene = preload("res://scenes/game_main/game_main.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	skip_progress.max_value = SKIP_AT_TIME

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_pressed("secondary_action"):
		_skip_time_pressed += delta
	else:
		_skip_time_pressed = 0
		
	skip_progress.value = _skip_time_pressed
	
	if Input.is_action_just_released("primary_action"):
		if _panel <= MAX_PANELS:
			_panel += 1
			if _panel <= MAX_PANELS:
				slide_show_animation.play("panel%d" % _panel)
		
	if _panel > MAX_PANELS:
		_start_coolown += delta
	if _start_coolown >= START_AT_TIME or _skip_time_pressed >= SKIP_AT_TIME:
		get_tree().change_scene_to_packed(main_game_scene)

func _physics_process(delta: float) -> void:
	pass


func _on_slide_show_frame_changed() -> void:
	# @NOTE: very hard codes sound play in scnes ... in future use animation tree and audio nodes
	if slide_show_animation.animation == "panel1":
		if slide_show_animation.frame == 1:
			SoundManager.play_ui_sound_from_player(bush_sound)
	elif slide_show_animation.animation == "panel2":
		if slide_show_animation.frame == 0:
			SoundManager.play_ambient_sound_from_player(fire_sound)
	elif slide_show_animation.animation == "panel3":
		if slide_show_animation.frame == 2:
			SoundManager.play_ui_sound_from_player(click_sound)
	elif slide_show_animation.animation == "panel4":
		if slide_show_animation.frame == 1:
			SoundManager.play_ui_sound_from_player(cave_sound)
		if slide_show_animation.frame == 2:
			_fall_sound = SoundManager.play_ui_sound_from_player(fall_sound)
		if _fall_sound and slide_show_animation.frame >= 3:
			fall_sound.volume_db -= 1.05
		if slide_show_animation.frame >= 3:
			slide_show_animation.speed_scale += 1.2
		if slide_show_animation.frame == 4:
			SoundManager.stop_all_ambient_sounds(0.5)
	elif slide_show_animation.animation == "panel5":
		if slide_show_animation.frame == 0:
			SoundManager.stop_all_ambient_sounds()
			slide_show_animation.speed_scale = 1.0
		if slide_show_animation.frame == 2:
			SoundManager.play_ui_sound_from_player(land_sound)
		if slide_show_animation.frame == 4:
			_beast_sound = SoundManager.play_ui_sound_from_player(beast_sound)
	elif slide_show_animation.animation == "panel6":
		if _beast_sound and slide_show_animation.frame >= 0 and slide_show_animation.frame < 3:
			_beast_sound.volume_db += 0.57
		if slide_show_animation.frame >= 2 and slide_show_animation.frame <= 4:
			run_sound.pitch_scale = randf_range(1.25, 1.45)
			SoundManager.play_ui_sound_from_player(run_sound)
