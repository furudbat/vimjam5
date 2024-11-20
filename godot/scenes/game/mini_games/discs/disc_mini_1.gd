extends Node2D

signal puzzle_solved()

const ROTATE_PER_WHEEL_PRESS: int = 10
const WIN_TOLERANZE_DEGREE: float = 0.0
const HOLD_STILL_FOR_SLICE_SOLVED_TIME: float = 0.5

var started: bool = false
var win_cooldown: int = 0
var win: int = false

var _selected_slice_nr = 0
var _slices = []
var _slice_solved_timers = {}
var _slices_solved = {}

@onready var title := %Title
@onready var mini_game := %MiniGame

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
		if not win:
			# check win
			var slices = get_tree().get_nodes_in_group("Slices")
			for i in range(slices.size()):
				var slice = slices[i]
				var slice_solved = slice.rotation_degrees >= -WIN_TOLERANZE_DEGREE and slice.rotation_degrees <= WIN_TOLERANZE_DEGREE
				if _slice_solved_timers[i] < 0.5:
					if slice_solved:
						if _slice_solved_timers.has(i):
							_slice_solved_timers[i] += delta
						else:
							_slice_solved_timers[i] = delta
					else:
						_slice_solved_timers[i] = 0
				_slices_solved[i] = _slice_solved_timers[i] >= HOLD_STILL_FOR_SLICE_SOLVED_TIME
			win = true
			for i in range(slices.size()):
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
	var slices = get_tree().get_nodes_in_group("Slices")
	# update slices
	for i in range(slices.size()):
		var slice = slices[i]
		var highlight = slice.get_node("Highlight")
		highlight.visible = not _slices_solved[i] and _selected_slice_nr == i+1

func _input(event: InputEvent) -> void:
	if started and event is InputEventMouseButton:
		var slices = get_tree().get_nodes_in_group("Slices")
		if event.is_action_pressed("mouse_wheel_up"):
			if _selected_slice_nr > 0 and _selected_slice_nr-1 < slices.size():
				var selected_slice = slices[_selected_slice_nr-1]
				if not _slices_solved[_selected_slice_nr-1]:
					selected_slice.rotation_degrees = (int(selected_slice.rotation_degrees) + ROTATE_PER_WHEEL_PRESS) % 360
				#print(selected_slice.rotation_degrees, solved)
		elif event.is_action_pressed("mouse_wheel_down"):
			if _selected_slice_nr > 0 and _selected_slice_nr-1 < slices.size():
				var selected_slice = slices[_selected_slice_nr-1]
				if not _slices_solved[_selected_slice_nr-1]:
					selected_slice.rotation_degrees = (int(selected_slice.rotation_degrees) - ROTATE_PER_WHEEL_PRESS) % 360
				#print(selected_slice.rotation_degrees, solved)
				
				

func _on_slice_input_event(slice: Node, slice_index: int, viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if started and event is InputEventMouseMotion:
		if not win:
			_selected_slice_nr = slice_index+1
		else:
			_selected_slice_nr = 0

func _on_slice_mouse_exited(slice: Node):
	_selected_slice_nr = 0
