extends Node2D

signal cut_segment(segment_index)
signal update_cut_line(cut_line_points)

var vine_segments = []
var vine_pin_joints = []
var is_cut = false
var cutting: bool = false
var cut_line_points: Array[Vector2] = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	vine_segments = _get_local_nodes_in_group("VineSegments")
	vine_pin_joints = _get_local_nodes_in_group("VinePinJoints")
	
func _get_local_nodes_in_group(group_name: String) -> Array:
	var local_nodes = []
	for child in get_children():
		if child.is_in_group(group_name):
			local_nodes.append(child)
	return local_nodes

func _input(event):
	if not is_cut:
		if event is InputEventMouseMotion:
			var mouse_pos = event.position
			if visible:
				if Input.is_action_pressed("primary_action"):
					_start_cut(event.position)
				elif Input.is_action_just_released("primary_action"):
					_end_cut()
				if cutting:
					_update_cut(event.position)

func _start_cut(start_position: Vector2):
	cutting = true
	cut_line_points.clear()
	cut_line_points.append(start_position)
	_update_line()

func _update_cut(new_position: Vector2):
	cut_line_points.append(new_position)
	_update_line()
	_check_cut_collisions()

func _end_cut():
	cutting = false
	cut_line_points.clear()
	_update_line()

func _update_line():
	update_cut_line.emit(cut_line_points)
	
func _check_cut_collisions():
	# Convert the cut line into segments
	for i in range(cut_line_points.size()):
		var p1 = cut_line_points[i]
		if _check_for_cut(p1):
			is_cut = true
			return

func _check_for_cut(point):
	if not is_cut:
		for i in range(vine_segments.size()):
			var segment = vine_segments[i]
			
			# Create the PhysicsPointQueryParameters2D object
			var query_parameters = PhysicsPointQueryParameters2D.new()
			query_parameters.position = point
			query_parameters.collide_with_bodies = true
			query_parameters.collide_with_areas = false
			# query_parameters.collision_mask = 1 
			
			var results = get_world_2d().direct_space_state.intersect_point(query_parameters, 8)

			for result in results:
				if result and result["collider"]:
					return _cut_segment(i)
				
	return false

func _cut_segment(segment_index: int):
	# Remove the corresponding pin joint
	if segment_index < vine_pin_joints.size():
		var joint_to_cut = vine_pin_joints[segment_index]
		if is_instance_valid(joint_to_cut):
			joint_to_cut.queue_free()
			vine_pin_joints.remove_at(segment_index)
			cut_segment.emit(segment_index)
			return true

	# Optionally remove the segment itself
	if segment_index < vine_segments.size():
		var segment_to_remove = vine_segments[segment_index]
		if is_instance_valid(segment_to_remove):
			segment_to_remove.queue_free()
			vine_segments.remove_at(segment_index)
				
	
	return false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
