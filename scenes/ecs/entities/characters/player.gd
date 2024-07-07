extends CharacterBody3D
class_name PlayerCharacter

@export var _movement_speed: float = 5
@export var _rotation_speed: float = 20

@onready var _fire_point: Node3D = $FirePoint
@onready var _attack_component: AttackComponent = $Components/AttackComponent

var _delta_time: float = 0
var _attack_cooldown_timer: float = 1
var _velocity: Vector3 = Vector3.ZERO

func _ready() -> void:
	pass

func _physics_process(delta: float) -> void:
	_delta_time = delta
	_attack_cooldown_timer -= delta

	var input_dir: Vector2 = Input.get_vector("Left", "Right", "Up", "Down")
	var isometric_dir: Vector3 = Vector3(input_dir.x + input_dir.y, 0, input_dir.y - input_dir.x).normalized()

	if isometric_dir.length() > 0:
		_velocity.x = isometric_dir.x * _movement_speed
		_velocity.z = isometric_dir.z * _movement_speed

		# Calculate the target rotation
		#var target_rotation: Quaternion = Quaternion(Vector3.UP, atan2(-isometric_dir.x, -isometric_dir.z))

		# Smoothly interpolate the current rotation towards the target rotation
		#var current_rotation: Quaternion = global_transform.basis.get_rotation_quaternion()
		#var new_rotation: Quaternion = current_rotation.slerp(target_rotation, delta * 10)

		# Apply the new rotation
		#global_transform.basis = Basis(new_rotation)

	else:
		_velocity.x = move_toward(_velocity.x, 0, _movement_speed)
		_velocity.z = move_toward(_velocity.z, 0, _movement_speed)

	velocity = _velocity

	move_and_slide()

	var mouse_pos_3d: Vector3 = _get_mouse_pos_3d()
	_smooth_look_at(mouse_pos_3d)

	#var mouse_dir: Vector3 = Vector3.FORWARD
	#if mouse_pos_3d:
		#mouse_pos_3d.y = global_position.y
		#mouse_dir = (mouse_pos_3d - global_position).normalized()


	if Input.is_action_pressed("Fire"):
		_attack_component.use_primary_attack(self, _fire_point)

func _get_mouse_pos_3d(ray_length:float = 1000) -> Vector3:
	var mouse_pos: Vector2 = get_viewport().get_mouse_position()
	var from: Vector3 = get_viewport().get_camera_3d().project_ray_origin(mouse_pos)
	var to: Vector3 = from + get_viewport().get_camera_3d().project_ray_normal(mouse_pos) * ray_length
	return Plane(Vector3.UP, 0).intersects_ray(from, to)

func _smooth_look_at(target_position: Vector3) -> void:
		var direction: Vector3 = (target_position - global_transform.origin).normalized()
		direction.y = 0

		var current_rotation: Quaternion = global_transform.basis.get_rotation_quaternion()
		var target_rotation: Quaternion = Quaternion(Vector3.FORWARD, direction).normalized()
		var new_rotation: Quaternion = current_rotation.slerp(target_rotation, _rotation_speed * _delta_time)
		global_transform.basis = Basis(new_rotation)
