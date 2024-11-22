extends VBoxContainer

@onready var master_volume_button := %MasterVolumeIcon
@onready var master_volume_slider := %MasterVolumeSlider
@onready var music_volume_button := %MusicVolumeIcon
@onready var music_volume_slider := %MusicVolumeSlider
@onready var sound_volume_button := %SoundVolumeIcon
@onready var sound_volume_slider := %SoundVolumeSlider
@onready var sound_sample := %SoundSamplePlayer

var sound_active = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	master_volume_button.on_click.connect(_master_volume_button_on_click)
	music_volume_button.on_click.connect(_music_volume_button_on_click)
	sound_volume_button.on_click.connect(_sound_volume_button_on_click)
	
func _process(delta: float) -> void:
	master_volume_slider.editable = UserSettings.get_value(master_volume_button.active_property)
	music_volume_slider.editable = UserSettings.get_value(music_volume_button.active_property)
	sound_volume_slider.editable = UserSettings.get_value(sound_volume_button.active_property)
	sound_active = UserSettings.get_value(sound_volume_button.active_property)
	
func _master_volume_button_on_click(active):
	if not active:
		# @FIXME: update only slider value (for view, not UserSettings)
		#master_volume_slider.value = 0
		pass
	else:
		master_volume_slider.value = UserSettings.get_value(master_volume_slider.property)
		
func _music_volume_button_on_click(active):
	if not active:
		# @FIXME: update only slider value (for view, not UserSettings)
		#music_volume_slider.value = 0
		pass
	else:
		music_volume_slider.value = UserSettings.get_value(music_volume_slider.property)
		
func _sound_volume_button_on_click(active):
	sound_active = active
	if not active:
		# @FIXME: update only slider value (for view, not UserSettings)
		#sound_volume_slider.value = 0
		pass
	else:
		sound_volume_slider.value = UserSettings.get_value(sound_volume_slider.property)


func _on_sound_volume_slider_volume_changed(val: Variant) -> void:
	if sound_active:
		SoundManager.play_sound($Sample.stream)
