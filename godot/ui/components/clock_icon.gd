extends Control

# Scene Nodes
@onready var sprite = %Sprite2D
@onready var sprite_timer: Timer = %SpriteTimer

@export var time = 0

var frame = 0
const SWAP_TIME_SEC = 0.55

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	sprite_timer.stop()
	sprite_timer.timeout.connect(_on_sprite_timer_timeout)
	sprite_timer.one_shot = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if time <= 0:
		sprite_timer.stop()
		frame = 1
	elif time <= Constants.CLOCK_LOW_TIME_SEC:
		if sprite_timer.is_stopped():
			sprite_timer.start(SWAP_TIME_SEC)
			frame = 1
	else:
		sprite_timer.stop()
		frame = 0

	sprite.frame = frame

func _on_sprite_timer_timeout():
	if time <= Constants.CLOCK_LOW_TIME_SEC:
		if frame == 0:
			frame = 1
		elif frame == 1:
			frame = 0
