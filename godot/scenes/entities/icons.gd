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
@export var active_property = ""

signal on_click(state)

# Called when the node enters the scene tree for the first time.
func _ready():
	active = UserSettings.get_value(active_property)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	match icon:
		Icon.MASTER:
			sprite.frame = 16 if active else 17
		Icon.SOUND:
			sprite.frame = 24 if active else 25
		Icon.MUSIC:
			sprite.frame = 8 if active else 9
	
	# Check click event
	if Input.is_action_just_pressed("primary_action"):
		var mouse_pos = get_global_mouse_position()
		if sprite.visible and sprite.get_rect().has_point(sprite.to_local(mouse_pos)):
			active = !active
			UserSettings.set_value(active_property, active)
			on_click.emit(active)
