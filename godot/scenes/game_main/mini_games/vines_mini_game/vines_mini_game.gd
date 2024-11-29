extends MiniGame

const MAX_CUT_LENGTH = 80
const MINIMUM_CUT_LENGTH = 15

var _vines = []
var _vines_cut_counter: int = 0
var _cutting: bool = false
var _cut_line_points: Array[Vector2] = []
var _init_vines: bool = false

var _line_start: Vector2 = Vector2(-MAX_CUT_LENGTH, -MAX_CUT_LENGTH - 5)
var _line_end: Vector2 = Vector2(-MAX_CUT_LENGTH, -MAX_CUT_LENGTH - 5)
var _is_line_drawing: bool = false
var _total_vines: int = 0  # Total number of vines
var _cut_vines = []   # List of vines that are cut

#@onready var line_node := %CutLine
@onready var cut_sound := %VineCutSound1
@onready var win_sound := %WinSoundPlayer
@onready var rustle_sound := %VineRustleSound
# @DEPRECATED: use cut_drawer
@onready var line_drawer := %LineDrawer
#@onready var cut_drawer := %CutLine

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super()
	self.check_win_condition = func(): return _cut_vines.size() >= _total_vines

	line_drawer.minimum_cut_length = MINIMUM_CUT_LENGTH

	for vine in get_tree().get_nodes_in_group("Vines"):
		if vine.name.begins_with("Vine_"):
			_total_vines += 1
			if vine.vine_cut:
				vine.vine_cut.connect(_on_vine_cut)

func _cut_segment(vine, vine_index, segment_index):
	_vines_cut_counter = _vines_cut_counter + 1
	
func _input(event):
	if _started and not has_won():
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
				
				if _line_end.distance_squared_to(_line_start) >= MINIMUM_CUT_LENGTH * MINIMUM_CUT_LENGTH:
					if cut_sound:
						cut_sound.pitch_scale = randf_range(0.78, 1.14)
						SoundManager.play_ui_sound_from_player(cut_sound)
						
				_line_start = Vector2(-MAX_CUT_LENGTH - 5, -MAX_CUT_LENGTH - 5)
				_line_end = Vector2(-MAX_CUT_LENGTH - 5, -MAX_CUT_LENGTH - 5)
				# only play sound at minimum cut length


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

		# Check if there were any hits and process them
		for res in results:
			var hit_node = res["collider"]
			if hit_node and hit_node.has_method("cut_segment"):
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
	if vine not in _cut_vines:
		_cut_vines.append(vine)
		vine.set_process(false)
		rustle_sound.pitch_scale = 0.55 + (randi() % 3) * 0.05
		SoundManager.play_ui_sound_from_player(rustle_sound)
