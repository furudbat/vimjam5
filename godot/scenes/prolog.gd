extends Node2D

@onready var slide_show_animation := %SlideShow
@onready var skip_progress := %SkipProgressBar

signal exit_intro

const SKIP_AT_TIME = 0.9
var skip_time_pressed = 0

const MAX_PANELS = 6
var panel = 1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	skip_progress.max_value = SKIP_AT_TIME

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_pressed("secondary_action"):
		skip_time_pressed += delta
	else:
		skip_time_pressed = 0
		
	skip_progress.value = skip_time_pressed
	
	if Input.is_action_just_released("primary_action"):
		panel = panel + 1
		if OS.is_debug_build():
			print(panel)
		if panel <= MAX_PANELS:
			slide_show_animation.play("panel%d" % panel)
		
	if panel > MAX_PANELS or skip_time_pressed >= SKIP_AT_TIME:
		get_tree().change_scene_to_file("res://scenes/main_game.tscn")

func _physics_process(delta: float) -> void:
	pass
