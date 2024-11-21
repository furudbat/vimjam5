extends Node2D

signal puzzle_solved()

const ROTATE_PER_WHEEL_PRESS: int = 10
const WIN_TOLERANZE_DEGREE: float = 0.0
const HOLD_STILL_FOR_SLICE_SOLVED_TIME: float = 0.5

var started: bool = false
var win_cooldown: float = 0
var win: int = false

var _selected_slice_nr = 0
var _slices = []
var _slice_solved_timers = {}
var _slices_solved = {}
var is_fading = false
var initial_volume_db = 2

@onready var title := %Title
@onready var mini_game := %MiniGame
@onready var complete_slice := %CompleteSilce
@onready var move_slice := %MoveSlice

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	title.visible = true
	mini_game.visible = false
	
	var slices = get_tree().get_nodes_in_group("Slices")
	for i in range(slices.size()):
		var slice = slices[i]
		var area = slice.get_node("Area2D")
		area.connect("input_event", func(viewport, event, shape_idx): _on_slice_input_event(slice, i, viewport, event, shape_idx))
		area.connect("mouse_exited", func(): _on_slice_mouse_exited(slice))
		_slices.append(slice)
		_slice_solved_timers[i] = 0
		_slices_solved[i] = false 


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if not started:
		if Input.is_action_just_released("primary_action"):
			started = true
			title.visible = false
			mini_game.visible = true
			return
	else:
		var slices = get_tree().get_nodes_in_group("Slices")
		# update slices
		for i in range(slices.size()):
			var slice = slices[i]
			var highlight = slice.get_node("Highlight")
			var overlay = slice.get_node("Overlay")
			highlight.visible = _selected_slice_nr > 1 and not _slices_solved[i] and _selected_slice_nr == i+1
			overlay.visible = _slices_solved[i]
		
		# check wining
		if not win:
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
					play_click_clack()
					#print("_slices_solved", i)
					_slices_solved[i] = true
				else:
					if i == 0:
						_slices_solved[i] = true
			win = true
			for i in range(slices.size()):
				if i != 0:
					win = win and _slices_solved[i]
			if win:
				#win_sound.play()
				pass
		if win:
			win_cooldown = win_cooldown + delta
			_selected_slice_nr = 0
		if win_cooldown >= 0.6:
			puzzle_solved.emit()
			started = false
			return

func _physics_process(delta: float) -> void:
	pass

func _input(event: InputEvent) -> void:
	if started and event is InputEventMouseButton:
		var slices = get_tree().get_nodes_in_group("Slices")
		if event.is_action_pressed("mouse_wheel_up"):
			if _selected_slice_nr > 1 and _selected_slice_nr-1 < slices.size():
				var selected_slice = slices[_selected_slice_nr-1]
				if not _slices_solved[_selected_slice_nr-1]:
					selected_slice.rotation_degrees = (int(selected_slice.rotation_degrees) + ROTATE_PER_WHEEL_PRESS) % 360
					play_move_slice()
				#print(selected_slice.rotation_degrees, solved)
		elif event.is_action_pressed("mouse_wheel_down"):
			if _selected_slice_nr > 1 and _selected_slice_nr-1 < slices.size():
				var selected_slice = slices[_selected_slice_nr-1]
				if not _slices_solved[_selected_slice_nr-1]:
					selected_slice.rotation_degrees = (int(selected_slice.rotation_degrees) - ROTATE_PER_WHEEL_PRESS) % 360
					play_move_slice()
				#print(selected_slice.rotation_degrees, solved)
				
				

func _on_slice_input_event(slice: Node, slice_index: int, viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if started and event is InputEventMouseMotion:
		if not win:
			_selected_slice_nr = slice_index+1
		else:
			_selected_slice_nr = 0

func _on_slice_mouse_exited(slice: Node):
	_selected_slice_nr = 0
	
func play_click_clack():
	complete_slice.pitch_scale = 0.5 
	complete_slice.play()
	await get_tree().create_timer(0.2).timeout  # Adjust the time as needed
	complete_slice.stop()
	
	complete_slice.pitch_scale = 1.0 
	complete_slice.play()
	await complete_slice.finished
	
func play_move_slice():
	if move_slice.is_playing() and not is_fading:
		await move_slice.finished
	elif is_fading:
		is_fading = false
		move_slice.stop()  
	move_slice.volume_db = initial_volume_db 
	move_slice.play()
	randomize_and_fade()

func randomize_and_fade():
	move_slice.pitch_scale = 0.55 + (randi() % 3) * 0.05

	var total_duration = 0.6  
	var fade_duration = 0.4  
	var play_duration = total_duration - fade_duration 
	var fade_steps = 10

	await get_tree().create_timer(play_duration).timeout
	is_fading = true
	for step in range(fade_steps):  # Divide fade into steps
		if not is_fading:
			return
		move_slice.volume_db = lerp(initial_volume_db, -60, step / float(fade_steps))  # Gradual fade
		await get_tree().create_timer(fade_duration / float(fade_steps)).timeout

	move_slice.stop()
	move_slice.volume_db = initial_volume_db 
	is_fading = false
