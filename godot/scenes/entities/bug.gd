extends RigidBody2D

@onready var sprite = %AnimatedSprite2D

signal bug_smushed()

var is_smushed: bool = false  # Track whether the bug is smushed

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var mob_types = sprite.sprite_frames.get_animation_names()
	 # Filter out the "smushed" animation
	var filtered_mob_types = []
	for name in mob_types:
		if name != "smushed":
			filtered_mob_types.append(name)
	
	# Play a random non-smushed animation
	if filtered_mob_types.size() > 0:
		sprite.play(filtered_mob_types[randi() % filtered_mob_types.size()])

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()

func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.is_action_pressed("primary_action"):
		if is_smushed:
			return  # Prevent multiple clicks during smushed state
			
		bug_smushed.emit()
			
		# Play smushed animation and set smushed state
		sprite.play("smushed")  # Ensure the smushed animation is named "smushed"
		is_smushed = true
		# Connect animation_finished to queue_free after the smushed animation finishes
		sprite.connect("animation_finished", _on_animation_finished)
		sleeping = true  # Stops physics updates for the body

func _on_animation_finished() -> void:
	queue_free()
