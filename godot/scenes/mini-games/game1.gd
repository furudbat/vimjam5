extends Node2D

@onready var title = %Title
@onready var mini_game = %MiniGame

signal solve_puzzle()

var started = false

const MAX_STONES = 8
var stone_counter = MAX_STONES
var stones = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	title.visible = true
	mini_game.visible = false
	
	for stone in get_tree().get_nodes_in_group("Stones"):
		stone.get_node("Area2D").connect("input_event", func(viewport, event, shape_idx): _on_stone_input_event(stone, viewport, event, shape_idx))
		stones.append(stone)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_released("primary_action"):
		if not started:
			started = true
			title.visible = false
			mini_game.visible = true
			return
			
	if started:
		# @TODO: mini game logic
		if stone_counter <= 0:
			solve_puzzle.emit()
			started = false
			return
			

func _on_stone_input_event(stone: Node, viewport: Node, event: InputEvent, shape_idx: int) -> void:
	print(stone, event)
	if started and event is InputEventMouseButton and event.is_action_just_pressed("primary_action"):
		if stone.visible:
			stone_counter = stone_counter - 1
			viewport.get_node("CollisionPolygon2D").disabled = true
			stone.visible = false

func _on_stone_area_2d_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	print(viewport, event)
	if started and event is InputEventMouseButton and event.is_action_just_pressed("primary_action"):
		var parent = viewport.get_parent()
		if parent.visible:
			stone_counter -= 1
			var collision_polygon = viewport.get_node("CollisionPolygon2D")
			if collision_polygon:
				collision_polygon.disabled = true
			parent.visible = false
