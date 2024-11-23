extends MiniGame

const ROTATE_PER_WHEEL_PRESS: int = 10
const WIN_TOLERANZE_DEGREE: float = 0.0
const HOLD_STILL_FOR_SLICE_SOLVED_TIME: float = 0.5
const INITIAL_VOLUME_DB: int = 0
const TOTAL_DURATION = 0.6  
const FADE_DURATION = 0.4  
const FADE_STEPS = 10
const PLAY_DURATION = TOTAL_DURATION - FADE_DURATION 

@export var fixed_slice_index: int = 0

var _selected_slice_nr: int = 0
var _slices = []
var _slice_solved_timers = {}
var _slices_solved = {}

var _slice_part_1_player: AudioStreamPlayer = null
var _slice_part_2_player: AudioStreamPlayer = null
var _is_fading_out: bool = false
var _fade_time: float = 0.0
var _fade_step: int = 0

@onready var complete_slice := %CompleteSilce
@onready var move_slice := %MoveSlice

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super()
	self.check_win_condition = _check_win_condition
	self.on_won.connect(_on_won)
	
	var slices = get_tree().get_nodes_in_group("Slices")
	for i in range(slices.size()):
		var slice = slices[i]
		var area = slice.get_node("Area2D")
		area.input_event.connect(func(viewport, event, shape_idx): _on_slice_input_event(slice, i, viewport, event, shape_idx))
		area.mouse_exited.connect(func(): _on_slice_mouse_exited(slice))
		_slices.append(slice)
		_slice_solved_timers[i] = 0
		_slices_solved[i] = false

func _check_win_condition() -> bool:
	var slices = get_tree().get_nodes_in_group("Slices")
	var win = true
	for i in range(slices.size()):
		if i != 0:
			win = win and _slices_solved[i]
	return win


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	super(delta)
	if is_started():
		var slices = get_tree().get_nodes_in_group("Slices")
		# update slices
		for i in range(slices.size()):
			var slice = slices[i]
			var highlight = slice.get_node("Highlight")
			var overlay = slice.get_node("Overlay")
			highlight.visible = _selected_slice_nr > 1 and not _slices_solved[i] and _selected_slice_nr == i+1
			overlay.visible = _slices_solved[i]
		
		# check wining
		if not has_won():
			# check win
			for i in range(slices.size()):
				var slice = slices[i]
				var slice_solved = slice.rotation_degrees >= -WIN_TOLERANZE_DEGREE and slice.rotation_degrees <= WIN_TOLERANZE_DEGREE
				if _slice_solved_timers[i] < HOLD_STILL_FOR_SLICE_SOLVED_TIME:
					if slice_solved:
						if _slice_solved_timers.has(i):
							_slice_solved_timers[i] += delta
						else:
							_slice_solved_timers[i] = delta
					else:
						_slice_solved_timers[i] = 0
				if i != 0 and not _slices_solved[i] and _slice_solved_timers[i] >= HOLD_STILL_FOR_SLICE_SOLVED_TIME:
					_play_click_clack()
					_slices_solved[i] = true
				else:
					if i == fixed_slice_index:
						_slices_solved[i] = true
	if _is_fading_out:
		_fade_time += delta
		# 1. wait for full PLAY_DURATION
		# 2. fade out the rest of the sounnd
		if (_fade_step == 0  and _fade_time >= PLAY_DURATION) or (_fade_step > 0 and _fade_time >= FADE_DURATION / FADE_STEPS):
			# Gradually reduce the volume
			move_slice.volume_db = lerp(int(INITIAL_VOLUME_DB), -60, _fade_step / float(FADE_STEPS))
			_fade_time = 0
			_fade_step = _fade_step + 1
			if _fade_step >= FADE_STEPS:
				_is_fading_out = false
				move_slice.stop()
				move_slice.volume_db = INITIAL_VOLUME_DB

func _on_won():
	_selected_slice_nr = 0

func _physics_process(delta: float) -> void:
	pass

func _input(event: InputEvent) -> void:
	if _started and event is InputEventMouseButton:
		var slices = get_tree().get_nodes_in_group("Slices")
		if event.is_action_pressed("mouse_wheel_up"):
			if _selected_slice_nr > 1 and _selected_slice_nr-1 < slices.size():
				var selected_slice = slices[_selected_slice_nr-1]
				if not _slices_solved[_selected_slice_nr-1]:
					selected_slice.rotation_degrees = (int(selected_slice.rotation_degrees) + ROTATE_PER_WHEEL_PRESS) % 360
					_play_move_slice()
		elif event.is_action_pressed("mouse_wheel_down"):
			if _selected_slice_nr > 1 and _selected_slice_nr-1 < slices.size():
				var selected_slice = slices[_selected_slice_nr-1]
				if not _slices_solved[_selected_slice_nr-1]:
					selected_slice.rotation_degrees = (int(selected_slice.rotation_degrees) - ROTATE_PER_WHEEL_PRESS) % 360
					_play_move_slice()
				

func _on_slice_input_event(slice: Node, slice_index: int, viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if _started and event is InputEventMouseMotion:
		if not has_won():
			_selected_slice_nr = slice_index+1
		else:
			_selected_slice_nr = 0

func _on_slice_mouse_exited(slice: Node):
	_selected_slice_nr = 0
	
func _play_click_clack():
	const SLICE_COMPLETE_DEPLAY_SEC = 0.2

	if _slice_part_1_player:
		_slice_part_1_player.stop()
	if _slice_part_2_player:
		_slice_part_2_player.stop()

	complete_slice.pitch_scale = 0.5
	_slice_part_1_player = SoundManager.play_sound_from_player(complete_slice)
	get_tree().create_timer(SLICE_COMPLETE_DEPLAY_SEC).timeout.connect(func(): 
		if _slice_part_1_player:
			_slice_part_1_player.stop()
			_slice_part_1_player = null
		complete_slice.pitch_scale = 1.0 
		_slice_part_2_player = SoundManager.play_ui_sound_from_player(complete_slice)
		_slice_part_2_player.finished.connect(func(): _slice_part_2_player = null)
	)
	
func _play_move_slice():
	var play_move_slice_randomize_and_start_fade = func():
		move_slice.volume_db = INITIAL_VOLUME_DB 
		move_slice.play()
		move_slice.pitch_scale = 0.55 + (randi() % 3) * 0.05
		_is_fading_out = true
		_fade_time = 0.0

	if not move_slice.is_playing():
		play_move_slice_randomize_and_start_fade.call()
	elif _is_fading_out:
		move_slice.stop()
		play_move_slice_randomize_and_start_fade.call()
