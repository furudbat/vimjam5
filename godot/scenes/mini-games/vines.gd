extends Node2D

@onready var title = %Title
@onready var mini_game = %MiniGame
@onready var line_node = %CutLine

signal puzzle_solved()

var started = false
var vines = []
var vines_cut_counter = 0
var cutting = false
var cut_line_points: Array[Vector2] = []
var win_cooldown = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	title.visible = true
	mini_game.visible = false
	
	var vs = get_tree().get_nodes_in_group("Vines")
	for i in range(vs.size()):
		var vine = vs[i]
		vine.cut_segment.connect(func(segment_index): _cut_segment(vine, i, segment_index))
		vines.append(vine)
		vine.visible = false

func _cut_segment(vine, vine_index, segment_index: int):
	vines_cut_counter = vines_cut_counter + 1
	
func _input(event):
	if started:
		if event is InputEventMouseMotion:
			# @NOTE(workaround): ajust mnouse position ... 
			var mouse_pos = event.position - Vector2(426 - 378, 240 - 216)
			# Handle mouse press
			if Input.is_action_pressed("primary_action") or Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):  # BUTTON_LEFT = 1
				if not cutting:  # If cutting hasn't started yet
					_start_cut(mouse_pos)
				else:
					_update_cut(mouse_pos)
		# Handle mouse release (using InputEventMouseButton)
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
			_end_cut()
			_update_line()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if not started:
		if Input.is_action_just_released("primary_action"):
			started = true
			title.visible = false
			mini_game.visible = true
			for vine in vines:
				vine.visible = true
			return
	else:
		if vines_cut_counter >= vines.size():
			win_cooldown = win_cooldown + delta
		if win_cooldown >= 0.9:
			puzzle_solved.emit()
			started = false
			return
			
func _start_cut(start_position: Vector2):
	cutting = true
	cut_line_points.clear()
	cut_line_points.append(start_position)
	_update_line()

func _update_cut(new_position: Vector2):
	cut_line_points.append(new_position)
	_update_line()

func _end_cut():
	cutting = false
	cut_line_points.clear()
	_update_line()

func _update_line():
	line_node.points = cut_line_points
	pass
