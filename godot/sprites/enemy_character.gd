extends CharacterBody2D

# Scene Nodes
@onready var animation_player = %AnimationPlayer
@onready var animation_tree = %AnimationTree

@export var direction: Vector2 = Vector2(1, 0)
@export var is_moving = false

@export var enemy_velocity: Vector2 = Vector2.ZERO

func _ready() -> void:
	animation_tree.active = true
	
func _process(delta: float) -> void:
	animation_tree["parameters/conditions/is_moving"] = is_moving
	animation_tree["parameters/Walk/blend_position"] = direction
	velocity = enemy_velocity

func _physics_process(delta: float) -> void:
	move_and_slide()
