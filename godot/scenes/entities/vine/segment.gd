extends RigidBody2D

@onready var sprite := %SprVine

@export var cut = false

const CUT_VINE: Rect2 = Rect2(0, 0, 32, 64)
const ACTIVE_VINE: Rect2 = Rect2(32, 0, 32, 64)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func _process(delta: float) -> void:
	pass
	# @FIXME: update colors when cut vine
	#if cut:
	#	var atlas_texture = sprite.texture as AtlasTexture
	#	atlas_texture.region = CUT_VINE
	#else:
	#	var atlas_texture = sprite.texture as AtlasTexture
	#	atlas_texture.region = ACTIVE_VINE
