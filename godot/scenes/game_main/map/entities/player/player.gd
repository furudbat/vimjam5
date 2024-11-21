extends CharacterBody2D

@export var direction: Vector2 = Vector2(1, 0)
@export var is_moving: bool = false

@export var player_velocity: Vector2 = Vector2.ZERO

# Scene Nodes
@onready var animation_player := %AnimationPlayer
@onready var animation_tree := %AnimationTree

func _ready() -> void:
	animation_tree.active = true
	
func _process(delta: float) -> void:
	animation_tree["parameters/conditions/is_moving"] = is_moving
	animation_tree["parameters/Walk/blend_position"] = direction

func _physics_process(delta: float) -> void:
	velocity = player_velocity
	if is_moving:
		move_and_slide()
