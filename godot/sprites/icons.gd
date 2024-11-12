extends Node2D

# Scene Nodes
@onready var sprite = %Sprite2D

enum Icon {
	MASTER,
	SOUND,
	MUSIC,
}
@export var icon = Icon.MASTER
@export var active = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	match icon:
		Icon.MASTER:
			sprite.frame = 0 if active else 1
		Icon.SOUND:
			sprite.frame = 2 if active else 3
		Icon.MUSIC:
			sprite.frame = 4 if active else 5


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	match icon:
		Icon.MASTER:
			sprite.frame = 0 if active else 1
		Icon.SOUND:
			sprite.frame = 2 if active else 3
		Icon.MUSIC:
			sprite.frame = 4 if active else 5
		
