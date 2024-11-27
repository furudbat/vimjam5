extends Node2D

const SKIP_AT_TIME = 0.9
const MAX_PANELS = 6
const START_AT_TIME = 0.9

var _skip_time_pressed = 0
var _panel = 1
var _start_coolown = 0

@onready var skip_progress := %SkipProgressBar

@onready var panel_1: Node2D = %Panel1
@onready var panel_2: Node2D = %Panel2
@onready var panel_3: Node2D = %Panel3
@onready var panel_4: Node2D = %Panel4
@onready var panel_5_6: Node2D = %Panel56

@onready var fire_sound := %FireSoundPlayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	skip_progress.max_value = SKIP_AT_TIME
	
func _on_transition_finished(params):
	panel_1.visible = true
	panel_1.get_node("AnimationPlayer").play("panel_1")

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
			if _panel == 2:
				#panel_1.visible = false
				panel_1.get_node("AnimationPlayer").seek(panel_1.get_node("AnimationPlayer").get_animation("panel_1").length, true)
				panel_1.get_node("AnimationPlayer").stop(true)
				panel_2.visible = true
				panel_2.get_node("AnimationPlayer").play("panel_2")
				SoundManager.play_ambient_sound_from_player(fire_sound, 0.2)
			if _panel == 3:
				#panel_2.visible = false
				panel_2.get_node("AnimationPlayer").seek(panel_2.get_node("AnimationPlayer").get_animation("panel_2").length, true)
				panel_2.get_node("AnimationPlayer").stop(true)
				panel_3.visible = true
				panel_3.get_node("AnimationPlayer").play("panel_3")
			if _panel == 4:
				#panel_3.visible = false
				panel_3.get_node("AnimationPlayer").seek(panel_3.get_node("AnimationPlayer").get_animation("panel_3").length, true)
				panel_3.get_node("AnimationPlayer").pause()
				panel_4.visible = true
				panel_4.get_node("AnimationPlayer").play("panel_4")
			if _panel == 5:
				SoundManager.stop_all_ambient_sounds(0.5)
				panel_1.visible = false
				panel_2.visible = false
				panel_3.visible = false
				panel_4.visible = false
				panel_4.get_node("AnimationPlayer").seek(panel_4.get_node("AnimationPlayer").get_animation("panel_4").length, true)
				panel_4.get_node("AnimationPlayer").pause()
				panel_5_6.visible = true
				panel_5_6.get_node("AnimationPlayer").play("panel_5")
			if _panel == 6:
				#panel_4.visible = false
				#panel_4.get_node("AnimationPlayer").seek(panel_4.get_node("AnimationPlayer").get_animation("panel_4").length)
				#panel_4.get_node("AnimationPlayer").pause()
				#panel_5_6.visible = true
				panel_5_6.get_node("AnimationPlayer").play("panel_6")
				
		
	if _panel > MAX_PANELS:
		_start_coolown += delta
	if _start_coolown >= START_AT_TIME or _skip_time_pressed >= SKIP_AT_TIME:
		SoundManager.stop_all_ambient_sounds()
		Transition.change_scene(GlobalScenes.Scenes.MainGame, 0.15)

func _physics_process(delta: float) -> void:
	pass
