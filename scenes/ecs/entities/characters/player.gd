extends Body
class_name PlayerCharacter

@onready var _fire_point: Node3D = $FirePoint
@onready var _attack_component: AttackComponent = $Components/AttackComponent
var _attack_cooldown_timer: float = 1

func _physics_process(delta: float) -> void:
	_attack_cooldown_timer -= delta

	var input_dir: Vector2 = Input.get_vector("Left", "Right", "Up", "Down")
	var isometric_dir: Vector3 = Vector3(input_dir.x + input_dir.y, 0, input_dir.y - input_dir.x).normalized()

	if isometric_dir.length() > 0:
		_velocity.x = isometric_dir.x * _movement_speed
		_velocity.z = isometric_dir.z * _movement_speed

	else:
		_velocity.x = move_toward(_velocity.x, 0, _movement_speed)
		_velocity.z = move_toward(_velocity.z, 0, _movement_speed)

	_character_body.velocity = _velocity

	_character_body.move_and_slide()

	var mouse_pos_3d: Vector3 = MouseUtility.get_mouse_pos_3d()
	_smooth_look_at(mouse_pos_3d)
	RotationUtility.smooth_look_at(self, mouse_pos_3d, _rotation_speed)
	#var mouse_dir: Vector3 = Vector3.FORWARD
	#if mouse_pos_3d:
		#mouse_pos_3d.y = global_position.y
		#mouse_dir = (mouse_pos_3d - global_position).normalized()

	if Input.is_action_pressed("Fire"):
		_attack_component.use_primary_attack(self, _fire_point)

func _smooth_look_at(target_position: Vector3) -> void:
	var direction: Vector3 = (target_position - global_transform.origin).normalized()
	direction.y = 0

	var current_rotation: Quaternion = global_transform.basis.get_rotation_quaternion()
	var target_rotation: Quaternion = Quaternion(Vector3.FORWARD, direction).normalized()

	var delta_time: float = GameManager.get_current_delta_time()
	var new_rotation: Quaternion = current_rotation.slerp(target_rotation, _rotation_speed * delta_time)
	global_transform.basis = Basis(new_rotation)
