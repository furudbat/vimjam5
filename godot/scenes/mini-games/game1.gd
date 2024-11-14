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
		# Check Stone collisions
		if Input.is_action_just_pressed("primary_action"):
			var mouse_pos = get_global_mouse_position()
			for stone in stones:
				if stone.visible and stone.get_rect().has_point(stone.to_local(mouse_pos)):
					stone_counter = stone_counter - 1
					stone.get_node("Area2D/CollisionShape2D").disabled = true
					stone.visible = false
					break
			
		# @TODO: mini game logic
		if stone_counter <= 0:
			solve_puzzle.emit()
			started = false
			return
			
