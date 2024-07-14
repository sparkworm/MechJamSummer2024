extends CanvasLayer
class_name FrameBuffer

@export var _target_viewport: Viewport
@export var _texture_rect_scene: PackedScene
@export var _buffer_frames: int = 10
@export var _buffer_frame_per_frames: int = 2
@export var _start_opacity = 0.3;
@export var _opacity_fade_per_second = 0.8
@export var _linger_duration = 0.3

var _texture_rects: Array[TextureRect]
var overlay_texture: Texture2D

var _buffer_frame_counter = 0;
var _buffer_frame_iterator: int = 0
var _frame_timer: float = 0
var _clear_timer: float = 0
var _passed_frames: int = 0
var _frame_buffer_current_duration: float = 0

func _ready():

	for i in range(_buffer_frames):
		var new_texture_rect: TextureRect = _texture_rect_scene.instantiate() as TextureRect
		add_child(new_texture_rect)
		_texture_rects.append(new_texture_rect)

	for textureRect in _texture_rects:
		textureRect.modulate = Color(1, 1, 1, _start_opacity)

func _process(delta):
	_frame_buffer_current_duration -= delta

	if(_frame_buffer_current_duration > 0):
		_execute_frames(delta)

	for rect_texture in _texture_rects:
		rect_texture.modulate.a -= _opacity_fade_per_second * delta


func _execute_frames(delta):
	_passed_frames += 1

	if(_passed_frames < _buffer_frame_per_frames):
		return
	else: _passed_frames = 0

	var image_texture: ImageTexture = ImageTexture.new()
	var viewport_texture = _target_viewport.get_texture() as ViewportTexture
	image_texture = image_texture.create_from_image(viewport_texture.get_image())
	_texture_rects[_buffer_frame_iterator].texture = image_texture
	_texture_rects[_buffer_frame_iterator].modulate = Color(1, 1, 1, _start_opacity)

	_buffer_frame_iterator += 1
	if(_buffer_frame_iterator + 1 >= _texture_rects.size()):
		_buffer_frame_iterator = 0

func activate_player_frame_buffer(duration: float):
	_frame_buffer_current_duration = duration + _linger_duration

