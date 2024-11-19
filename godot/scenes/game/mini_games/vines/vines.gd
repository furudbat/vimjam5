extends Node2D

@onready var title := %Title
@onready var mini_game := %MiniGame
#@onready var line_node := %CutLine
@onready var cut_sound := %VineCutSound1
@onready var win_sound := %WinSoundPlayer
@onready var line_drawer := %LineDrawer

signal puzzle_solved()

# Points for drawing the line
var line_start: Vector2
var line_end: Vector2
var is_drawing = false
var total_vines = 0  # Total number of vines
var cut_vines = []   # List of vines that are cut

var started = false
var vines = []
var vines_cut_counter = 0
var cutting = false
var cut_line_points: Array[Vector2] = []
var win_cooldown = 0
var init_vines = false
var win = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	title.visible = true
	mini_game.visible = false

	for child in mini_game.get_children():
		if child.name.begins_with("Vine_"):
			total_vines += 1
			if child.has_signal("vine_cut"):
				child.connect("vine_cut", Callable(self, "_on_vine_cut"))

func _cut_segment(vine, vine_index, segment_index):
	vines_cut_counter = vines_cut_counter + 1
	if OS.is_debug_build():
		print(vine, vine_index, segment_index)
	
func _input(event):
	if started:
		if event is InputEventMouseButton:
			if event.button_index == MOUSE_BUTTON_LEFT:
				if event.pressed:
					line_drawer.line_start = event.position
					line_drawer.line_end = event.position
					line_drawer.is_drawing = true
					line_drawer.queue_redraw()
				else:
					line_drawer.line_end = event.position
					line_drawer.is_drawing = false
					line_drawer.queue_redraw()
					_check_collision(line_drawer.line_start, line_drawer.line_end)
		elif event is InputEventMouseMotion and line_drawer.is_drawing:
			line_drawer.line_end = event.position
			line_drawer.queue_redraw()
			if cut_sound:
				cut_sound.pitch_scale = randf_range(0.78, 1.14)
				cut_sound.play()

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
		if win:
			win_cooldown = win_cooldown + delta
		if win_cooldown >= 1.2:
			puzzle_solved.emit()
			started = false
			return
			
# Draw the line
#func _draw():
	#if is_drawing:
		#draw_line(line_start, line_end, ColorPalette.ACCENT, 2)

# Check for collisions along the drawn line
func _check_collision(start_point: Vector2, end_point: Vector2):
	var space_state = get_world_2d().direct_space_state

	# Create and configure the ray query parameters
	var query = PhysicsRayQueryParameters2D.new()
	query.from = start_point
	query.to = end_point

	# Perform a raycast to detect collisions
	var result = space_state.intersect_ray(query)

	if result.size() > 0:  # Check if there is a collision
		var hit_node = result["collider"]
		if hit_node and hit_node.has_method("cut_segment"):
			hit_node.cut_segment()

func _on_vine_cut(vine):
	if vine not in cut_vines:
		cut_vines.append(vine)
		vine.set_process(false)

	# Check if all vines are cut
	if not win and cut_vines.size() >= total_vines:
		win = true
		#win_sound.play()
