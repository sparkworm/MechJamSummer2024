extends PlayerCharacter
class_name PlayerMech

func _ready() -> void:
	super()

func _physics_process(delta: float) -> void:

	_handle_movement_input()
	_handle_look_rotation_input()

	if Input.is_action_pressed("Fire"):
		_attack_component.use_primary_attack(self, _fire_point)

	for node3D: Node3D in _detection_area.get_overlapping_bodies():
		if(node3D is CollisionObject3D):
			_on_overlapping_body(node3D)

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

func _on_overlapping_body(node3D: Node3D) -> void:
	super(node3D)
