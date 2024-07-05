extends CharacterBody3D
class_name PlayerCharacter

@export var _movement_speed: float = 5
@export var _attack_cooldown: float = 1
@export var _fire_point: Node3D
@export var _attack_projectile: PackedScene

var _attack_cooldown_timer: float = 1
var _velocity: Vector3 = Vector3.ZERO

func _ready() -> void:
	pass

func _physics_process(delta: float) -> void:
	_attack_cooldown_timer -= delta

	var input_dir: Vector2 = Input.get_vector("Left", "Right", "Up", "Down")
	var isometric_dir: Vector3 = Vector3(input_dir.x + input_dir.y, 0, input_dir.y - input_dir.x).normalized()

	if isometric_dir.length() > 0:
		_velocity.x = isometric_dir.x * _movement_speed
		_velocity.z = isometric_dir.z * _movement_speed

		# Calculate the target rotation
		var target_rotation: Quaternion = Quaternion(Vector3.UP, atan2(isometric_dir.x, isometric_dir.z))

		# Smoothly interpolate the current rotation towards the target rotation
		var current_rotation: Quaternion = global_transform.basis.get_rotation_quaternion()
		var new_rotation: Quaternion = current_rotation.slerp(target_rotation, delta * 10)

		# Apply the new rotation
		global_transform.basis = Basis(new_rotation)

	else:
		_velocity.x = move_toward(_velocity.x, 0, _movement_speed)
		_velocity.z = move_toward(_velocity.z, 0, _movement_speed)

	velocity = _velocity

	move_and_slide()

	if Input.is_action_pressed("Fire") && _attack_cooldown_timer <= 0:
		_attack_cooldown_timer = _attack_cooldown;
		var attack_particle: Projectile = _attack_projectile.instantiate() as Projectile
		get_tree().root.get_child(0).add_child(attack_particle)

		var dir: Vector3 = _fire_point.global_transform.basis.z

		attack_particle.init_with_world_direction(_fire_point.global_position, dir)

func take_damage(_damage: float) -> void:
	pass

func _die() -> void:
	pass
