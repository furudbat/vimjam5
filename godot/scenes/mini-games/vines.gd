extends Node2D

@onready var title = %Title
@onready var mini_game = %MiniGame

const CUT_DISTANCE = 8

signal puzzle_solved()

var started = false
var vines = []
var vines_cut = {}
var vines_cut_counter = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	title.visible = true
	mini_game.visible = false
	
	var v = 0
	for vine in get_tree().get_nodes_in_group("Vines"):
		var vine_segments = vine.get_tree().get_nodes_in_group("VineSegments")
		var vine_pin_joints = vine.get_tree().get_nodes_in_group("VinePinJoints")
		vines.append({ "vine_segments": vine_segments,  "vine_pin_joints": vine_pin_joints})
		vines_cut[v] = false
		v = v + 1
	

func _input(event):
	if event is InputEventMouseMotion:
		var mouse_pos = event.position
		if Input.is_action_pressed("primary_action"):
			_check_for_cut(mouse_pos)

func _check_for_cut(mouse_pos: Vector2):
	for i in range(vines.size()):
		var vine = vines[i]
		for j in range(vine.vine_segments.size()):
			var segment = vine.vine_segments[j]

			# If the mouse is close to the segment, cut it
			if segment.global_position.distance_to(mouse_pos) <= CUT_DISTANCE:
				if cut_segment(vine, i, j):
					vines_cut_counter = vines_cut_counter + 1
				break

func cut_segment(vine, vine_index, segment_index: int):
	if not vines_cut[vine_index]:
		# Remove the corresponding pin joint
		if segment_index < vine.vine_pin_joints.size():
			var joint_to_cut = vine.vine_pin_joints[segment_index]
			if is_instance_valid(joint_to_cut):
				joint_to_cut.queue_free()
				vine.vine_pin_joints.remove_at(segment_index)
				vines_cut[vine_index] = true

		# Optionally remove the segment itself
		if segment_index < vine.vine_segments.size():
			var segment_to_remove = vine.vine_segments[segment_index]
			if is_instance_valid(segment_to_remove):
				segment_to_remove.queue_free()
				vine.vine_segments.remove_at(segment_index)
				
		return true
		
	return false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if not started:
		if Input.is_action_just_released("primary_action"):
				started = true
				title.visible = false
				mini_game.visible = true
				return
	else:
		if vines_cut_counter >= vines.size():
			puzzle_solved.emit()
			started = false
			return
			
