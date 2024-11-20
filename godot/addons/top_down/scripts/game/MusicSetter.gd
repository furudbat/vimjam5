class_name MusicSetter
extends Node

## Will call Music singleton to start music in it's dictionary
@export var music_name:String

func _ready()->void:
	MusicManager.start(music_name)
