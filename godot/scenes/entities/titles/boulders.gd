extends CharacterBody2D

# Scene Nodes
@onready var sprite = %Sprite2D

@export var game = 1
@export var open = false
@export var mini_game = "boulders"
signal player_entered_obsticale(node, body, mini_game)

const BOULDER_REGION: Rect2 = Rect2(0, 160, 32, 32)
const OPEN_REGION: Rect2 = Rect2(0, 96, 32, 32)

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
	atlas_texture.region = BOULDER_REGION


func _on_obstacle_body_entered(body: Node2D) -> void:
	if (body.name == "Player"):
		player_entered_obsticale.emit(self, body, mini_game)
