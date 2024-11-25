class_name TransitionManager
extends CanvasLayer

signal transition_finished

@export var texture_rect: TextureRect
@export var default_transition_time: float = 0.5
@export var bool_resource: BoolResource

var _tween: Tween
var _scene_loading: bool = false

func change_scene(scene_path: String, transition_time: float = default_transition_time)->void:
	bool_resource.set_value(true)
	# wait for rendering everything on a screen
	RenderingServer.frame_post_draw.connect(_post_draw.bind(scene_path, transition_time), CONNECT_ONE_SHOT)
	
func _ready()->void:
	visible = false

func _post_draw(scene_path: String, transition_time: float)->void:
	var _game_resolution: Vector2i = get_viewport().content_scale_size
	var _viewport_size: Vector2i = get_viewport().size
	var _multiply: float = _game_resolution.y / float(_viewport_size.y)
	
	# get texture from the screen
	var _image: Image = get_viewport().get_texture().get_image()
	_image.resize(int(ceil(_viewport_size.x * _multiply)), _game_resolution.y, Image.INTERPOLATE_NEAREST)
	var _image_texture: ImageTexture = ImageTexture.create_from_image(_image)
	texture_rect.texture = _image_texture
	
	get_tree().current_scene.visible = false
	visible = true
	_transition_progress(0.0)
	
	# TODO: refactor to start loading as soon as possible, but need solid workaround for race conditions
	ThreadUtility.load_resource(scene_path, func(scene): _scene_loaded(scene, transition_time))

## Set transition in motion
func _scene_loaded(scene: PackedScene, transition_time: float)->void:
	assert(scene != null)
	get_tree().change_scene_to_packed(scene)
	#get_tree().process_frame.connect(_connect_transition_finished_to_scene, CONNECT_ONE_SHOT)
	_scene_loading = true
	
	if _tween != null:
		_tween.kill()
	_tween = create_tween()
	# small delay to remove weird stutter
	_tween.tween_method(_transition_progress, 0.0, 1.0, transition_time).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC).set_delay(0.1)
	_tween.finished.connect(_transition_finished)

func _transition_progress(t:float)->void:
	(texture_rect.material as ShaderMaterial).set_shader_parameter("progress", t)

func _transition_finished()->void:
	visible = false
	bool_resource.set_value(false)
	transition_finished.emit()
	_scene_loading = false
	
func _process(delta: float) -> void:
	if _scene_loading:
		var new_scene = get_tree().current_scene
		if new_scene and new_scene.has_method("_on_transition_finished"):
			if bool_resource.get_value():
				# Connect the signal to the new scene's method
				transition_finished.connect(new_scene._on_transition_finished, CONNECT_ONE_SHOT)
			else:
				# transition already finished
				new_scene._on_transition_finished()
				_scene_loading = false
