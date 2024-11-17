extends Node2D

signal cut_segment(segment_index)

var vine_segments = []
var vine_pin_joints = []
var cut = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	vine_segments = _get_local_nodes_in_group("VineSegments")
	vine_pin_joints = _get_local_nodes_in_group("VinePinJoints")
	
	for i in range(vine_segments.size()):
		var segment = vine_segments[i]
		segment.connect("mouse_shape_entered", func(shape_idx): _on_segment_mouse_entered(segment, i, shape_idx))
		
func _get_local_nodes_in_group(group_name: String) -> Array:
	var local_nodes = []
	for child in get_children():
		if child.is_in_group(group_name):
			local_nodes.append(child)
	return local_nodes

func _input(event):
	pass

func _cut_segment(segment_index: int):
	var ret = false
	# Remove the corresponding pin joint
	if segment_index+1 < vine_pin_joints.size():
		var joint_to_cut = vine_pin_joints[segment_index+1]
		if is_instance_valid(joint_to_cut):
			joint_to_cut.queue_free()
			vine_pin_joints.remove_at(segment_index)
			ret = true

	# Optionally remove the segment itself
	if segment_index < vine_segments.size():
		var segment_to_remove = vine_segments[segment_index]
		if is_instance_valid(segment_to_remove):
			#segment_to_remove.queue_free()
			vine_segments.remove_at(segment_index)
			ret = true
				
	if ret:
		cut_segment.emit(segment_index)
	
	return ret

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_segment_mouse_entered(segment, index, shape_idx) -> void:
	if not cut:
		print(segment, index)
		if Input.is_action_pressed("primary_action") or Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
			if(_cut_segment(index)):
				cut = true
