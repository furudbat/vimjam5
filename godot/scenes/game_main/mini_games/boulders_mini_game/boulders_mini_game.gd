extends MiniGame

var _stone_counter = 0
var _stones = []
var _stone_removing = false

@onready var boulder_sound := %BoulderSound1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super()
	self.check_win_condition = func(): return _stone_counter >= _stones.size()
	
	for stone in get_tree().get_nodes_in_group("Stones"):
		stone.get_node("Area2D").connect("input_event", func(viewport, event, shape_idx): _on_stone_input_event(stone, viewport, event, shape_idx))
		_stones.append(stone)
			
func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if not event.pressed or event.canceled:
			_stone_removing = false

func _on_stone_input_event(self_stone: Node, viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if _started and event is InputEventMouseButton and event.is_action_pressed("primary_action"):
		var mouse_pos = get_global_mouse_position()
		var clicked_stones = [self_stone]

		# Check all stones for visibility and if the mouse is inside their collision polygon
		for stone in _stones:
			if stone.visible:
				var area = stone.get_node("Area2D")
				var collision_polygon = area.get_node("CollisionPolygon2D") as CollisionPolygon2D
				if collision_polygon:
					var local_mouse_pos = area.to_local(mouse_pos)
					if is_point_in_polygon(local_mouse_pos, collision_polygon.polygon):
						clicked_stones.append(stone)

		# Sort by z-index (highest z-index first)
		clicked_stones.sort_custom(func(a, b):
			return a.z_index > b.z_index
		)

		# Destroy the topmost stone
		if not _stone_removing and clicked_stones.size() > 0:
			var topmost_stone = clicked_stones[0]
			topmost_stone.get_node("Area2D/CollisionPolygon2D").disabled = true
			topmost_stone.visible = false
			_stone_counter += 1

			# Play sound
			if boulder_sound:
				boulder_sound.pitch_scale = randf_range(0.91, 1.44)
				boulder_sound.play()
			_stone_removing = true

# Function to check if a point is inside a polygon
func is_point_in_polygon(point: Vector2, polygon: PackedVector2Array) -> bool:
	var inside = false
	var j = polygon.size() - 1
	for i in range(polygon.size()):
		var vi = polygon[i]
		var vj = polygon[j]
		if ((vi.y > point.y) != (vj.y > point.y)) and (point.x < (vj.x - vi.x) * (point.y - vi.y) / (vj.y - vi.y) + vi.x):
			inside = not inside
		j = i
	return inside
