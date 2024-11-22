extends Node2D

@onready var title := %Title
@onready var mini_game := %MiniGame
#@onready var line_node := %CutLine
@onready var cut_sound := %VineCutSound1
@onready var win_sound := %WinSoundPlayer
@onready var rustle_sound := %VineRustleSound
# @DEPRECATED: use cut_drawer
@onready var line_drawer := %LineDrawer
#@onready var cut_drawer := %CutLine

signal puzzle_solved()

const MAX_CUT_LENGTH = 80
const MINIMUM_CUT_LENGTH = 15

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

var _line_start: Vector2 = Vector2(-MAX_CUT_LENGTH, -MAX_CUT_LENGTH - 5)
var _line_end: Vector2 = Vector2(-MAX_CUT_LENGTH, -MAX_CUT_LENGTH - 5)
var _is_line_drawing: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	title.visible = true
	mini_game.visible = false
	line_drawer.minimum_cut_length = MINIMUM_CUT_LENGTH

	for vine in get_tree().get_nodes_in_group("Vines"):
		if vine.name.begins_with("Vine_"):
			total_vines += 1
			if vine.vine_cut:
				vine.vine_cut.connect(_on_vine_cut)

func _cut_segment(vine, vine_index, segment_index):
	vines_cut_counter = vines_cut_counter + 1
	if OS.is_debug_build():
		print(vine, vine_index, segment_index)
	
func _input(event):
	if started and not win:
		var end_cut = false
		if event is InputEventMouseButton:
			if event.button_index == MOUSE_BUTTON_LEFT:
				if event.pressed:
					if not _is_line_drawing:
						_line_start = event.position
						_line_end = event.position
						_is_line_drawing = true
						line_drawer.line_start = _line_start
						line_drawer.line_end = _line_end
						line_drawer.is_drawing = true
						line_drawer.queue_redraw()
						#cut_drawer.add_point(event.position)
				else:
					end_cut = false
					if _is_line_drawing:
						end_cut = true
						if event.position.distance_squared_to(_line_start) <= MAX_CUT_LENGTH*MAX_CUT_LENGTH:
							#cut_drawer.add_point(event.position)
							_line_end = event.position
					_is_line_drawing = false
					line_drawer.line_end = _line_end
					line_drawer.queue_redraw()
		elif event is InputEventMouseMotion:
			if _is_line_drawing:
				if event.position.distance_squared_to(_line_start) <= MAX_CUT_LENGTH*MAX_CUT_LENGTH:
					#cut_drawer.add_point(event.position)
					_line_end = event.position
				else:
					var direction = (event.position - _line_start).normalized()
					_line_end = _line_start + direction * MAX_CUT_LENGTH
					end_cut = true
				line_drawer.line_end = _line_end
				line_drawer.queue_redraw()
					
		if end_cut:
			#cut_drawer.add_point(_line_start)
			#cut_drawer.add_point(_line_end)
			_check_collision(_line_start, _line_end)
			if not _is_line_drawing:
				_is_line_drawing = false
				line_drawer.line_end = _line_end
				line_drawer.is_drawing = false
				line_drawer.queue_redraw()
				#cut_drawer.clear_points()
				_line_start = Vector2(-MAX_CUT_LENGTH - 5, -MAX_CUT_LENGTH - 5)
				_line_end = Vector2(-MAX_CUT_LENGTH - 5, -MAX_CUT_LENGTH - 5)
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
	if start_point.distance_to(end_point) < MINIMUM_CUT_LENGTH:
		return false
		
	var ret = false
	var n_segments = get_tree().get_nodes_in_group("Segments").size()
	for n in range(n_segments):
		var space_state = get_world_2d().direct_space_state
		# Create a PhysicsRayQueryParameters2D and set its from and to properties
		var query_1 = PhysicsRayQueryParameters2D.new()
		query_1.from = start_point
		query_1.to = end_point
		query_1.hit_from_inside = true
		
		var query_2 = PhysicsRayQueryParameters2D.new()
		query_2.from = end_point
		query_2.to = start_point
		query_2.hit_from_inside = true

		# Perform the raycast for both directions
		var results = []
		var result_1 = space_state.intersect_ray(query_1)
		var result_2 = space_state.intersect_ray(query_2)

		# Collect the results from both raycasts
		if result_1:
			results.append(result_1)
		if result_2:
			results.append(result_2)

		# Print the results (for debugging purposes)
		#print("Found ", results.size(), " collisions.")

		# Check if there were any hits and process them
		for res in results:
			var hit_node = res["collider"]
			if hit_node and hit_node.has_method("cut_segment"):
				#print("Hit: ", hit_node.name)
				# Only cut if we haven't started drawing the line yet
				if not _is_line_drawing:
					hit_node.cut_segment()
					var collision_shape = hit_node.get_node("CollisionShape2D") as CollisionShape2D
					if collision_shape:
						collision_shape.disabled = true
					ret = true
		
		if results.size() == 0:
			break
			
	return ret


func _on_vine_cut(vine):
	if vine not in cut_vines:
		cut_vines.append(vine)
		vine.set_process(false)
		rustle_sound.pitch_scale = 0.55 + (randi() % 3) * 0.05
		rustle_sound.play()

	# Check if all vines are cut
	if not win and cut_vines.size() >= total_vines:
		win = true
		#win_sound.play()
