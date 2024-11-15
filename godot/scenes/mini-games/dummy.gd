extends Node2D

@onready var title = %Title
@onready var mini_game = %MiniGame

signal puzzle_solved()

var started = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	title.visible = true
	mini_game.visible = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if not started:
		if Input.is_action_just_released("primary_action"):
			started = true
			title.visible = false
			mini_game.visible = true
			return
	else:
		# @TODO: mini game logic
		if Input.is_action_pressed("primary_action"):
			puzzle_solved.emit()
			started = false
			return
