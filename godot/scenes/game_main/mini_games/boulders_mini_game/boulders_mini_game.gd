extends Node2D

@onready var title := %Title
@onready var mini_game := %MiniGame
@onready var boulder_sound := %BoulderSound1
@onready var win_sound := %WinSoundPlayer

signal puzzle_solved()

var started = false

var stone_counter = 0
var stones = []
var win_cooldown: float = 0
var mouse_entered = false
var win = false
var stone_removing = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	title.visible = true
	mini_game.visible = false
	
	for stone in get_tree().get_nodes_in_group("Stones"):
		stone.get_node("Area2D").connect("input_event", func(viewport, event, shape_idx): _on_stone_input_event(stone, viewport, event, shape_idx))
		stones.append(stone)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if not started:
		if Input.is_action_just_released("primary_action"):
			started = true
			title.visible = false
			mini_game.visible = true
			return
	else:
		if not win and stone_counter >= stones.size():
			win = true
			#win_sound.play()
		if win:
			win_cooldown = win_cooldown + delta
		if win_cooldown >= 0.6:
			puzzle_solved.emit()
			started = false
			return
			
func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if not event.pressed or event.canceled:
			stone_removing = false
			print("reset")

func _on_stone_input_event(self_stone: Node, viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if started and event is InputEventMouseButton and event.is_action_pressed("primary_action"):
		var mouse_pos = get_global_mouse_position()
		var clicked_stones = [self_stone]

		# Check all stones for visibility and if the mouse is inside their collision polygon
		for stone in stones:
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
		print(clicked_stones)

		# Destroy the topmost stone
		if not stone_removing and clicked_stones.size() > 0:
			var topmost_stone = clicked_stones[0]
			print("top: ", topmost_stone)
			topmost_stone.get_node("Area2D/CollisionPolygon2D").disabled = true
			topmost_stone.visible = false
			stone_counter += 1

			# Play sound
			if boulder_sound:
				boulder_sound.pitch_scale = randf_range(0.91, 1.44)
				boulder_sound.play()
			stone_removing = true

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

			
			
			#var is_on_top = true
			# check for stones in front ???
			#if other_areas.size() > 0:
			#	is_on_top = true
			#	for area in other_areas:
			#		var other_stone = area.get_parent()
			#		if area.is_visible_in_tree():
			#			print(stone.z_index, other_stone.z_index)
			#			is_on_top = is_on_top and stone.z_index > other_stone.z_index || (stone.z_index == other_stone.z_index and stone_area.is_greater_than(area))
			#else:
			#	is_on_top = true
			#if is_on_top:
			#	stone_counter = stone_counter + 1
			#	stone.get_node("Area2D/CollisionPolygon2D").disabled = true
			#	stone.visible = false
			#	if boulder_sound:
			#		boulder_sound.pitch_scale = randf_range(0.91, 1.44)
			#		boulder_sound.play()
