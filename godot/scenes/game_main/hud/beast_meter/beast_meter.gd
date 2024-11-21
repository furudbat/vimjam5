extends Control

@onready var player_icon := %PlayerIcon
@onready var enemy_icon := %EnemyIcon
@onready var panel := %Panel

@export var distance: int = 0
@export var player_pos_m: int = 0
@export var enemy_pos_m: int = 0

enum EnemyIconState {
	NORMAL,
	ANGRY,
}
@export var enemy_state = EnemyIconState.NORMAL
enum PlayerIconState {
	RUNNING,
	STOPPED,
}
@export var player_state = PlayerIconState.RUNNING

const MARGIN_Y = 8
const ICON_SIZE = 32
const PANEL_SIZE_Y = 216

const TOP_POS_Y: int = MARGIN_Y
const CENTER_POS_Y := PANEL_SIZE_Y/2 - MARGIN_Y*2
const END_POS_Y: int = PANEL_SIZE_Y - MARGIN_Y - ICON_SIZE
const MAX_RANGE_Y: int = PANEL_SIZE_Y - ICON_SIZE

const M_PX_SCALE: float = abs(Constants.MAX_DISTANCE_M / MAX_RANGE_Y)


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	assert(M_PX_SCALE > 0)

	player_icon.position.y = CENTER_POS_Y
	enemy_icon.position.y = END_POS_Y

func start_distance(dis: int):
	distance = dis
	player_icon.position.y = END_POS_Y - distance/M_PX_SCALE
	enemy_icon.position.y = END_POS_Y

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	player_icon.position.y = END_POS_Y - player_pos_m/M_PX_SCALE
	enemy_icon.position.y = END_POS_Y - enemy_pos_m/M_PX_SCALE
		
	player_icon.position.y = clamp(player_icon.position.y, TOP_POS_Y, END_POS_Y)
	
	if player_icon.position.y <= TOP_POS_Y:
		enemy_icon.position.y = TOP_POS_Y + distance/M_PX_SCALE
	
	enemy_icon.position.y = clamp(enemy_icon.position.y, TOP_POS_Y, END_POS_Y)
	
	enemy_icon.state = enemy_state
