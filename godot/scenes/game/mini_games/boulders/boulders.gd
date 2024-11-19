extends Node2D

@onready var title := %Title
@onready var mini_game := %MiniGame
@onready var boulder_sound := %BoulderSound1
@onready var win_sound := %WinSoundPlayer

signal puzzle_solved()

var started = false

var stone_counter = 0
var stones = []
var win_cooldown = 0
var mouse_entered = false
var win = false

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
			

func _on_stone_input_event(stone: Node, viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if started and event is InputEventMouseButton and event.is_action_pressed("primary_action"):
		if stone.visible:
			var stone_area = stone.get_node("Area2D")
			var other_areas = stone_area.get_overlapping_areas()
			var is_on_top = true
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
			if is_on_top:
				stone_counter = stone_counter + 1
				stone.get_node("Area2D/CollisionPolygon2D").disabled = true
				stone.visible = false
				if boulder_sound:
					boulder_sound.pitch_scale = randf_range(0.91, 1.44)
					boulder_sound.play()
