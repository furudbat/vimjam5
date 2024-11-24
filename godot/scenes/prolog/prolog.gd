extends Node2D

const SKIP_AT_TIME = 0.9
const MAX_PANELS = 6
const START_AT_TIME = 0.9

var _skip_time_pressed = 0
var _panel = 1
var _start_coolown = 0

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

@onready var main_game_scene = preload("res://scenes/game/game.tscn")


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
		TitleBgm.stop()
		get_tree().change_scene_to_packed(main_game_scene)

func _physics_process(delta: float) -> void:
	pass


func _on_slide_show_frame_changed() -> void:
	# @NOTE: very hard codes sound play in scnes ... in future use animation tree and audio nodes
	if slide_show_animation.animation == "panel1":
		if slide_show_animation.frame == 1:
			bush_sound.play()
	elif slide_show_animation.animation == "panel2":
		if slide_show_animation.frame == 0:
			fire_sound.play()
	elif slide_show_animation.animation == "panel3":
		if slide_show_animation.frame == 2:
			click_sound.play()
	elif slide_show_animation.animation == "panel4":
		if slide_show_animation.frame == 1:
			cave_sound.play()
		if slide_show_animation.frame == 2:
			fall_sound.play()
		if slide_show_animation.frame >= 3:
			fall_sound.volume_db -= 1.05
		if slide_show_animation.frame >= 3:
			slide_show_animation.speed_scale += 1.2
	elif slide_show_animation.animation == "panel5":
		if slide_show_animation.frame == 0:
			slide_show_animation.speed_scale = 1.0
			fire_sound.stop()
		if slide_show_animation.frame == 2:
			land_sound.play()
		if slide_show_animation.frame == 4:
			beast_sound.play()
	elif slide_show_animation.animation == "panel6":
		if slide_show_animation.frame >= 0 and slide_show_animation.frame < 3:
			beast_sound.volume_db += 0.57
		if slide_show_animation.frame >= 2 and slide_show_animation.frame <= 4:
			run_sound.pitch_scale = randf_range(1.25, 1.45)
			run_sound.play()
