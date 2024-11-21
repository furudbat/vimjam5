extends Node2D

signal vine_cut  # Signal to notify that the whole vine is cut

var is_cut = false  # Flag to indicate whether the vine is cut

func _ready():
	# Connect all segment's segment_cut signals to the method for handling cuts
	for segment in get_children():
		if segment.has_signal("segment_cut"):
			segment.segment_cut.connect(_on_segment_cut)

func _on_segment_cut(cut_segment):
	if is_cut:
		return

	# Mark the vine as cut
	is_cut = true
	#print("Vine is being cut:", self)
	vine_cut.emit(self)

	# Remove joints associated with the cut segment
	var joint_removed = false
	for joint in get_children():
		if joint is PinJoint2D:
			var connected_a = joint.get_node(joint.node_a) == cut_segment
			var connected_b = joint.get_node(joint.node_b) == cut_segment

			if connected_a or connected_b:
				#print("Removing joint connected to:", joint.get_node(joint.node_a), "and", joint.get_node(joint.node_b))
				remove_child(joint)
				joint.queue_free()
				joint_removed = true
				break

	# Mark all segments of this specific vine as cut
	for segment in get_children():
		if segment is RigidBody2D and segment.has_method("set_cut_state"):
			#print("Updating segment texture:", segment.name)
			segment.set_cut_state(true)  # Call this on each segment in this vine
			var collision_shape = segment.get_node("CollisionShape2D") as CollisionShape2D
			#if collision_shape:
			#	collision_shape.disabled = true

	# Handle static body connections if no joint was removed
	if not joint_removed:
		#print("No joint removed. Checking static body connections.")
		for joint in get_children():
			if joint is PinJoint2D:
				var static_body_a = joint.node_a == "../StaticBody2D"
				var static_body_b = joint.node_b == "../StaticBody2D"

				if static_body_a or static_body_b:
					remove_child(joint)
					joint.queue_free()
					break
