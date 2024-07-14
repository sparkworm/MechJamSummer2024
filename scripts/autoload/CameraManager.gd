#CameraManager
#Autoload
extends Node

@onready var _pivot: Node3D = $CameraPivot
@onready var _camera: Camera3D = $CameraPivot/GameCamera
@onready var _frame_buffer: FrameBuffer = $CameraPivot/FrameBuffer
@onready var _frame_buffer_pivot: Node3D = $CameraPivot/FrameBufferViewport/FrameBufferPivot
@onready var _frame_buffer_camera: Camera3D = $CameraPivot/FrameBufferViewport/FrameBufferPivot/FrameBufferCamera
var camera: Camera3D:
	get: return _camera

var _player_target: PlayerCharacter = null

@export_group("Camera scroll distances")
@export var _max_camera_look_distance: float = 5
@export var _dead_zone_distance: float = 1

@export_group("Camera scroll senstivity")
@export var _min_camera_speed: float = 1
@export var _max_camera_speed: float = 1.75

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_player_target = PlayerManager.player

func assign_player_target(player: PlayerCharacter) -> void:
	_player_target = player

func activate_frame_buffers(duration: float):
	_frame_buffer.activate_player_frame_buffer(duration)

#Can try different time-steps if movement seems janky
func _process(delta: float) -> void:
	var mouse_pos: Vector3 = MouseUtility.get_mouse_pos_3d()
	var direction_to_cursor: Vector3 = (mouse_pos - _pivot.global_position)

	#slerp is usually the better idea but was having trouble with it
	var target_position: Vector3 = _player_target.global_position + direction_to_cursor.limit_length(_max_camera_look_distance)

	#print("mouse_pos: ", mouse_pos)
	#print("direction_to_cursor: ", direction_to_cursor)
	#print("target_position: ", target_position)
	#print("~~~~~~")

	var target_distance_from_player: float = target_position.distance_to(_player_target.global_position)
	var current_distance_from_player: float = _pivot.global_position.distance_to(target_position)

	if target_distance_from_player > _dead_zone_distance || current_distance_from_player > _dead_zone_distance:
		var distance_from_target: float = min(_player_target.global_position.distance_to(target_position), _max_camera_look_distance)
		if distance_from_target > 0:
			var speed_range: float = _max_camera_speed - _min_camera_speed
			var distance_ratio: float = distance_from_target / _max_camera_look_distance
			var variable_speed: float = speed_range * distance_ratio
			var current_move_speed: float = _min_camera_speed + variable_speed
			_pivot.global_position = _pivot.transform.origin.lerp(target_position, current_move_speed * delta)
			_frame_buffer_pivot.global_position = _pivot.global_position
