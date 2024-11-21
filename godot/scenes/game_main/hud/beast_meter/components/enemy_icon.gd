extends Node2D

# Scene Nodes
@onready var sprite := %Sprite2D

enum EnemyIconState {
	NORMAL,
	ANGRY,
}
@export var state = EnemyIconState.NORMAL

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if state == EnemyIconState.NORMAL:
		sprite.frame = 1
	elif state == EnemyIconState.ANGRY:
		sprite.frame = 2
