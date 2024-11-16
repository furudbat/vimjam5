extends Node2D

@onready var title = %Title
@onready var mini_game = %MiniGame

const CUT_DISTANCE = 8

signal puzzle_solved()

var started = false
var vine_segments = []
var vine_pin_joints = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	title.visible = true
	mini_game.visible = false
	
	vine_segments = get_tree().get_nodes_in_group("VineSegments")
	vine_pin_joints = get_tree().get_nodes_in_group("VinePinJoints")
	

func _input(event):
	if event is InputEventMouseMotion:
		var mouse_pos = event.position
		_check_for_cut(mouse_pos)

func _check_for_cut(mouse_pos: Vector2):
	for i in range(vine_segments.size()):
		var segment = vine_segments[i]

		# If the mouse is close to the segment, cut it
		if segment.global_position.distance_to(mouse_pos) <= CUT_DISTANCE:
			cut_segment(i)
			break


func cut_segment(index: int):
	# Remove the corresponding pin joint
	if index < vine_pin_joints.size():
		var joint_to_cut = vine_pin_joints[index]
		if is_instance_valid(joint_to_cut):
			joint_to_cut.queue_free()
			vine_pin_joints.remove_at(index)

	# Optionally remove the segment itself
	if index < vine_segments.size():
		var segment_to_remove = vine_segments[index]
		if is_instance_valid(segment_to_remove):
			segment_to_remove.queue_free()
			vine_segments.remove_at(index)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if not started:
		if Input.is_action_just_released("primary_action"):
				started = true
				title.visible = false
				mini_game.visible = true
				return
	else:
		if true:
			puzzle_solved.emit()
			started = false
			return
			
