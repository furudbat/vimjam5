extends CharacterBody2D

signal player_entered_obsticale(node: CharacterBody2D, body: Node2D, mini_game: String)

const VINES_REGION: Rect2 = Rect2(64, 160, 32, 32)
const OPEN_REGION: Rect2 = Rect2(0, 96, 32, 32)

# Scene Nodes
@onready var sprite := %Sprite2D

@export var open: bool = false
@export var mini_game: String = "vines"

func _process(delta: float) -> void:
	if open:
		_open_obstacle()
	else:
		_close_obstacle()

func _physics_process(delta: float) -> void:
	move_and_slide()

func _open_obstacle():
	var atlas_texture = sprite.texture as AtlasTexture
	atlas_texture.region = OPEN_REGION

func _close_obstacle():
	var atlas_texture = sprite.texture as AtlasTexture
	atlas_texture.region = VINES_REGION


func _on_obstacle_body_entered(body: Node2D) -> void:
	if (body.name == "Player"):
		player_entered_obsticale.emit(self, body, mini_game)
