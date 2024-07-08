extends Body
class_name PlayerCharacter

@onready var _fire_point: Node3D = $FirePoint
@onready var _attack_component: AttackComponent = $Components/AttackComponent
@onready var _detection_area: Area3D = $DetectionArea

func _physics_process(delta: float) -> void:

	_handle_movement_input()
	_handle_look_rotation_input()

	if Input.is_action_pressed("Fire"):
		_attack_component.use_primary_attack(self, _fire_point)

	for collision_body: CollisionObject3D in _detection_area.get_overlapping_bodies():
		_on_overlapping_body(collision_body)

func _on_overlapping_body(collision_body) -> void:

	if(collision_body is Pickup):
		var pickup_item: Pickup = collision_body as Pickup
		pickup_item.assign_current_target(self)

func _handle_movement_input() -> void:
	var input_dir: Vector2 = Input.get_vector("Left", "Right", "Up", "Down")
	var isometric_dir: Vector3 = Vector3(input_dir.x + input_dir.y, 0, input_dir.y - input_dir.x).normalized()

	if isometric_dir.length() > 0:
		_velocity.x = isometric_dir.x * _movement_speed
		_velocity.z = isometric_dir.z * _movement_speed

	else:
		_velocity.x = move_toward(_velocity.x, 0, _movement_speed)
		_velocity.z = move_toward(_velocity.z, 0, _movement_speed)

	velocity = _velocity

	move_and_slide()

func _handle_look_rotation_input() -> void:
	var mouse_pos_3d: Vector3 = MouseUtility.get_mouse_pos_3d()
	_smooth_look_at(mouse_pos_3d)
	TransformUtility.smooth_look_at(self, mouse_pos_3d, _rotation_speed)
	#var mouse_dir: Vector3 = Vector3.FORWARD
	#if mouse_pos_3d:
		#mouse_pos_3d.y = global_position.y
		#mouse_dir = (mouse_pos_3d - global_position).normalized()

func _smooth_look_at(target_position: Vector3) -> void:
	var direction: Vector3 = (target_position - global_transform.origin).normalized()
	direction.y = 0

	var current_rotation: Quaternion = global_transform.basis.get_rotation_quaternion()
	var target_rotation: Quaternion = Quaternion(Vector3.FORWARD, direction).normalized()

	var delta_time: float = GameManager.get_current_delta_time()
	var new_rotation: Quaternion = current_rotation.slerp(target_rotation, _rotation_speed * delta_time)
	global_transform.basis = Basis(new_rotation)
