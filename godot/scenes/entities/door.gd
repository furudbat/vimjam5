extends CharacterBody2D

# Scene Nodes
@onready var sprite = %Sprite2D

@export var open = false

const DOOR_CLOSED_REGION: Rect2 = Rect2(0, 128, 32, 32)
const DOOR_OPEN_REGION: Rect2 = Rect2(0, 96, 32, 32)

func _process(delta: float) -> void:
	if open:
		_open_door()
	else:
		_close_door()

func _physics_process(delta: float) -> void:
	move_and_slide()


func _open_door():
	var atlas_texture = sprite.texture as AtlasTexture
	atlas_texture.region = DOOR_OPEN_REGION

func _close_door():
	var atlas_texture = sprite.texture as AtlasTexture
	atlas_texture.region = DOOR_CLOSED_REGION
