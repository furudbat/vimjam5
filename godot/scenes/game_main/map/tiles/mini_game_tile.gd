extends CharacterBody2D
class_name MiniGameTile

signal player_entered_obsticale(node: CharacterBody2D, body: Node2D, mini_game: String)

const PLAYER_BODY_NAME = "Player"
const OPEN_REGION: Rect2 = Rect2(0, 96, 32, 32)

@export var solved_region: Rect2 = Rect2(0, 96, 32, 32)	# tile region when mini game is solved
@export var obstacle_region: Rect2 = Rect2(0, 96, 32, 32)	# tile region for obstacle

# Scene Nodes
@onready var sprite := %Sprite2D

@export var open: bool = false
@export var mini_game: String = ""

func _ready() -> void:
	assert(mini_game != "", "set the game of the mini game, see MiniGames")
	assert(MiniGames.MiniGames.has(mini_game), "MiniGame not found: %s" % mini_game)
	if obstacle_region == solved_region:
		push_warning("obstacle tile is the same as the solved tile (region)")
	if open:
		_open_obstacle()
	else:
		_close_obstacle()

func _process(delta: float) -> void:
	if open:
		_open_obstacle()
	else:
		_close_obstacle()

func _physics_process(delta: float) -> void:
	move_and_slide()

func _open_obstacle():
	var atlas_texture = sprite.texture as AtlasTexture
	atlas_texture.region = solved_region

func _close_obstacle():
	var atlas_texture = sprite.texture as AtlasTexture
	atlas_texture.region = obstacle_region


func _on_obstacle_body_entered(body: Node2D) -> void:
	if (body.name == PLAYER_BODY_NAME):
		player_entered_obsticale.emit(self, body, mini_game)
