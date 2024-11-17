extends Node2D

@onready var title = %Title
@onready var mini_game = %MiniGame
@onready var line_node = %CutLine

signal puzzle_solved()

var started = false
var vines = []
var vines_cut_counter = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	title.visible = true
	mini_game.visible = false
	
	var vs = get_tree().get_nodes_in_group("Vines")
	for i in range(vs.size()):
		var vine = vs[i]
		vine.cut_segment.connect(func(segment_index): _cut_segment(vine, i, segment_index))
		vine.update_cut_line.connect(_update_line)
		vines.append(vine)
		vine.visible = false

func _cut_segment(vine, vine_index, segment_index: int):
	vines_cut_counter = vines_cut_counter + 1

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
			puzzle_solved.emit()
			started = false
			return
			
func _update_line(cut_line_points):
	# TODO: draw cut line
	#line_node.points = cut_line_points
	pass
