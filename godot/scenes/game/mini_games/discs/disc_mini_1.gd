extends Node2D

signal puzzle_solved()

const ROTATE_PER_WHEEL_PRESS: int = 10
const WIN_TOLERANZE_DEGREE: float = 0.0

var started: bool = false
var win_cooldown: int = 0
var win: int = false

var _selected_slice = 0

@onready var title := %Title
@onready var mini_game := %MiniGame

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	title.visible = true
	mini_game.visible = false
	


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
			win = true
			var slices = get_tree().get_nodes_in_group("Slices")
			for slice in slices:
				win = win and slice.rotation_degrees >= -WIN_TOLERANZE_DEGREE and slice.rotation_degrees <= WIN_TOLERANZE_DEGREE
			if win:
				#win_sound.play()
				print("WIN")
		if win:
			win_cooldown = win_cooldown + delta
		if win_cooldown >= 0.6:
			puzzle_solved.emit()
			started = false
			return

func _physics_process(delta: float) -> void:
	# update slices
	var slices = get_tree().get_nodes_in_group("Slices")
	for i in range(slices.size()):
		var slice = slices[i]
		var lighlight = slice.get_node("Highlight")
		lighlight.visible = _selected_slice == i+1

func _input(event: InputEvent) -> void:
	if started and event is InputEventMouseButton:
		var slices = get_tree().get_nodes_in_group("Slices")
		if event.is_action_pressed("mouse_wheel_up"):
			if _selected_slice >= 0 and _selected_slice-1 < slices.size():
				var selected_slice = slices[_selected_slice-1]
				var solved = selected_slice.rotation_degrees >= -WIN_TOLERANZE_DEGREE and selected_slice.rotation_degrees <= WIN_TOLERANZE_DEGREE
				if not solved:
					selected_slice.rotation_degrees = (int(selected_slice.rotation_degrees) + ROTATE_PER_WHEEL_PRESS) % 360
				print(selected_slice.rotation_degrees, solved)
		elif event.is_action_pressed("mouse_wheel_down"):
			if _selected_slice >= 0 and _selected_slice-1 < slices.size():
				var selected_slice = slices[_selected_slice-1]
				var solved = selected_slice.rotation_degrees >= -WIN_TOLERANZE_DEGREE and selected_slice.rotation_degrees <= WIN_TOLERANZE_DEGREE
				if not solved:
					selected_slice.rotation_degrees = (int(selected_slice.rotation_degrees) - ROTATE_PER_WHEEL_PRESS) % 360
				print(selected_slice.rotation_degrees, solved)

func _on_slice_1_mouse_entered() -> void:
	_selected_slice = 1
	print("entered", _selected_slice)


func _on_slice_2_mouse_entered() -> void:
	_selected_slice = 2
	print("entered", _selected_slice)


func _on_slice_3_mouse_entered() -> void:
	_selected_slice = 3
	print("entered", _selected_slice)

func _on_slice_4_mouse_entered() -> void:
	_selected_slice = 4
	print("entered", _selected_slice)

func _on_slice_mouse_exited() -> void:
	_selected_slice = 0
	print("exited", _selected_slice)
