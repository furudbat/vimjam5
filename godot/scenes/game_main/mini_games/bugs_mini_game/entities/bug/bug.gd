extends RigidBody2D

signal bug_smushed()

@export var win = false

var _is_smushed: bool = false  # Track whether the bug is smushed

@onready var sprite := %AnimatedSprite2D

func smush_bug():
	if _is_smushed:
		# Prevent multiple clicks during smushed state
		return false
		
	# Play smushed animation and set smushesd state 
	sprite.play("smushed")  # Ensure the smushed animation is named "smushed"
	# Connect animation_finished to queue_free after the smushed animation finishes
	sprite.animation_finished.connect(_on_animation_finished)
	_is_smushed = true
	sleeping = true  # Stops physics updates for the body
	self.remove_from_group("Bugs")

	return true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var mob_types = sprite.sprite_frames.get_animation_names()
	 # Filter out the "smushed" animation
	var filtered_mob_types = []
	for mob_type in mob_types:
		if mob_type != "smushed":
			filtered_mob_types.append(mob_type)
	
	# Play a random non-smushed animation
	if filtered_mob_types.size() > 0:
		sprite.play(filtered_mob_types[randi() % filtered_mob_types.size()])

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	self.remove_from_group("Bugs")
	queue_free()

func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.is_action_pressed("primary_action"):
		if not win:
			if smush_bug():
				bug_smushed.emit()

func _on_animation_finished() -> void:
	self.remove_from_group("Bugs")
	queue_free()
