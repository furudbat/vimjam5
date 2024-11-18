extends RigidBody2D

@onready var sprite := %SprVine

# Signal to notify the parent vine when this segment is cut
signal segment_cut

#const ACTIVE = Rect2(32, 0, 32, 64)
#const NORMAL = Rect2(0, 0, 32, 64)

@export var cut = false

# Function to cut this segment
func cut_segment():
	# Emit a signal to notify the parent vine
	emit_signal("segment_cut", self)
	# Disable this segment so it no longer interacts with the game
	#self.custom_integrator = true  # Stop physics integration
	#self.angular_velocity = 0.0  # Stop rotation
	self.set_physics_process(false)  # Stop further physics updates
	cut = true
	
# Method to set the cut state and update texture
#func set_cut_state(is_cut: bool):
	#cut = is_cut  # Update the cut state
	#if cut:
	#	sprite.texture.region = NORMAL  # Switch to cut texture
	#else:
		#sprite.texture.region = ACTIVE  # Default texture	
