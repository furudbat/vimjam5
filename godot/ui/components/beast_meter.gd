extends Control

@onready var player_icon: TextureRect = %PlayerIcon
@onready var enemy_icon: TextureRect = %EnemyIcon
@onready var panel: Panel = %Panel

@export var distance: int = 0

const MARGIN_Y = 8
const ICON_SIZE = 32
const PANEL_SIZE_Y = 224

const TOP_POS_Y: int = MARGIN_Y
const CENTER_POS_Y: int = PANEL_SIZE_Y/2 - MARGIN_Y*2
const END_POS_Y: int = PANEL_SIZE_Y - MARGIN_Y - ICON_SIZE
const MAX_RANGE_Y: int = PANEL_SIZE_Y - ICON_SIZE

const CENTER_DISTANCE_M: float = 500
const MAX_DISTANCE_M: float = 1000
const M_PX_SCALE: float = abs(MAX_DISTANCE_M / MAX_RANGE_Y)


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	assert(M_PX_SCALE > 0)

	player_icon.position.y = CENTER_POS_Y
	enemy_icon.position.y = CENTER_POS_Y


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if distance < CENTER_DISTANCE_M:
		player_icon.position.y = CENTER_POS_Y
		enemy_icon.position.y = CENTER_POS_Y + distance/M_PX_SCALE
	elif distance >= CENTER_DISTANCE_M:
		player_icon.position.y = CENTER_POS_Y - (distance-CENTER_DISTANCE_M)/M_PX_SCALE
		enemy_icon.position.y = END_POS_Y
		
	player_icon.position.y = clamp(player_icon.position.y, TOP_POS_Y, END_POS_Y)
	enemy_icon.position.y = clamp(enemy_icon.position.y, TOP_POS_Y, END_POS_Y)
