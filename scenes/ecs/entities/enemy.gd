extends CharacterBody3D
class_name Whelp

@export var _movement_speed: float = 5.0
@export var _rotation_speed: float = 2
@export var _chase_targets: Array[LayerUtility.Layer]

@onready var _nav_agent: NavigationAgent3D = $NavigationAgent3D
@onready var _detection: Area3D = $Detection

var _chase_targets_mask: int = 0

var delta_time: float
var movement_delta: float

func _ready() -> void:
	_chase_targets_mask = LayerUtility.get_bitmask_from_bits(_chase_targets)
	_nav_agent.velocity_computed.connect(Callable(_on_velocity_computed))

func init(spawnLocation: Vector3) -> void:
	global_position = spawnLocation

func take_damage(_amount: int) -> void:
	pass

func set_movement_target(movement_target: Vector3) -> void:
	_nav_agent.set_target_position(movement_target)

func _physics_process(delta: float) -> void:
	delta_time = delta

	for collider: CollisionObject3D in _detection.get_overlapping_bodies():
		var collisionLayer: int = collider.get_collision_layer()
		if(LayerUtility.check_any_bits_from_bitmask(collisionLayer, _chase_targets_mask)):
			set_movement_target(collider.global_position)
			break

	if _nav_agent.is_navigation_finished():
		return

	movement_delta = _movement_speed * delta
	var next_path_position: Vector3 = _nav_agent.get_next_path_position()
	var new_velocity: Vector3 = global_position.direction_to(next_path_position) * _movement_speed
	if _nav_agent.avoidance_enabled:
		_nav_agent.set_velocity(new_velocity)
	else:
		_on_velocity_computed(new_velocity)

func _on_velocity_computed(safe_velocity: Vector3) -> void:
	var nextPos: Vector3 = global_position + safe_velocity
	smooth_look_at(nextPos)
	velocity = safe_velocity
	move_and_slide()

func smooth_look_at(target_position: Vector3) -> void:
		var direction: Vector3 = (target_position - global_transform.origin).normalized()
		direction.y = 0
		direction = direction.normalized()

		var current_rotation: Quaternion = global_transform.basis.get_rotation_quaternion()
		var target_rotation: Quaternion = Quaternion(-Vector3.FORWARD, direction).normalized()
		var new_rotation: Quaternion = current_rotation.slerp(target_rotation, _rotation_speed * delta_time)
		global_transform.basis = Basis(new_rotation)

func _die() -> void:
	queue_free()
