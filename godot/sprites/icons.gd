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
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	match icon:
		Icon.MASTER:
			sprite.frame = 16 if active else 17
		Icon.SOUND:
			sprite.frame = 24 if active else 25
		Icon.MUSIC:
			sprite.frame = 8 if active else 9
		
