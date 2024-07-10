extends Body
class_name EnemyCharacter

const RANDOM_SAMPLES: float = 10

#TODO: AI Variance
enum EnemyBehaviour
{
	Berserker, #Closes the gap between the chased target
	Sentinal, #Keeps weapon distance from the chased target
	Opportunist, #Retreats after attacking
}

enum NavState
{
	Patrolling,
	Chasing,
	Sweeping,
}


@export_subgroup("Detection Layers")
@export var _chase_targets: Array[LayerUtility.Layer] #Targets the enemy will chase
@export var _target_obstructions: Array[LayerUtility.Layer] #Targets that block the enemy's vision

@export_subgroup("Patrolling Attributes")
@export var _patrolling_movement_speed: float = 2
@export var _patrolling_rotation_speed: float = 3
@export var _detection_radius_patrolling: float = 12
@export var _detection_cone_degrees_patrolling: float = 160

@export_subgroup("Chasing Attributes")
@export var _chasing_movement_speed: float = 5
@export var _chasing_rotation_speed: float = 10
@export var _detection_radius_chasing: float = 20
@export var _detection_cone_degrees_chasing: float = 280
@export var _chase_duration: float = 2

@export_subgroup("Sweeping Attributes")
@export var _sweeping_movement_speed: float = 3
@export var _sweeping_rotation_speed: float = 5
@export var _detection_radius_sweeping: float = 16
@export var _detection_cone_degrees_sweeping: float = 200
@export var _sweep_duration: float = 20
@export var _sweep_radius: Vector3 = Vector3(1, 0, 1)

@onready var _nav_agent: NavigationAgent3D = $NavigationAgent3D
@onready var _vision_point: Node3D = $VisionPoint
@onready var _detection_area: Area3D = $DetectionArea
@onready var _health_component: HealthComponent = $Components/HealthComponent

var _chase_targets_mask: int = 0
var _target_obstructions_mask: int = 0

var _agent_nav_state: NavState = NavState.Patrolling
var _current_chase_target: Body = null
var _current_cone_degree_detection: float = 0
var _chase_time_remaining: float = 0
var _sweep_time_remaining: float = 0
var _last_detection_point: Vector3 = Vector3.ZERO


func _ready() -> void:
	_chase_targets_mask = LayerUtility.get_bitmask_from_bits(_chase_targets)
	_target_obstructions_mask = LayerUtility.get_bitmask_from_bits(_target_obstructions)
	_detection_area.collision_mask = _chase_targets_mask
	_nav_agent.velocity_computed.connect(Callable(_on_velocity_computed))
	_nav_agent.target_desired_distance = 1
	_health_component.connect("hit", _is_hit)
	_nav_state_to_patrolling()


func _is_hit(source: Node3D) -> void:
	if(source is Body):
		_nav_state_to_chasing(source as Body)
	pass

func _die() -> void:
	pass

func _set_movement_target(movement_target: Vector3) -> void:
	_nav_agent.set_target_position(movement_target)

func _physics_process(delta: float) -> void:
	_chase_time_remaining -= delta
	_sweep_time_remaining -= delta

	for node3D: CollisionObject3D in _detection_area.get_overlapping_bodies():
		if (node3D is CollisionObject3D && _on_overlapping_body(node3D)):
			break

	if _agent_nav_state == NavState.Chasing:
		_chase_target()

	elif _agent_nav_state == NavState.Sweeping:
		_sweep_area()

	if !_nav_agent.is_navigation_finished():
		_move_agent()

func _move_agent() -> void:
	_movement_delta = _movement_speed * GameUtility.get_current_delta_time()
	var next_path_position: Vector3 = _nav_agent.get_next_path_position()
	var new_velocity: Vector3 = global_position.direction_to(next_path_position) * _movement_speed
	if _nav_agent.avoidance_enabled:
		_nav_agent.set_velocity(new_velocity)
	else:
		_on_velocity_computed(new_velocity)

func _chase_target() -> void:
	if(_current_chase_target == null):
		_nav_state_to_patrolling()

	var target_position: Vector3 = _current_chase_target.global_position
	#probably add a delay to this later
	_set_movement_target(target_position)
	if(_chase_time_remaining < 0):
		_nav_state_to_sweeping(target_position)
	pass

func _sweep_area() -> void:
	if(_nav_agent.is_navigation_finished()):
		for i: int in range(RANDOM_SAMPLES):
			var random_point: Vector3 = _get_random_point_in_radius(_sweep_radius)
			_set_movement_target(_last_detection_point + random_point)
			if(_nav_agent.is_target_reachable()):
				break

	if(_sweep_time_remaining < 0):
		_nav_state_to_patrolling()

func _get_random_point_in_radius(radius: Vector3 = Vector3.ZERO) -> Vector3:
	return Vector3(
			randf_range(-radius.x, radius.x),
			randf_range(-radius.y, radius.y),
			randf_range(-radius.z, radius.z))

func _on_overlapping_body(collision_body: CollisionObject3D) -> bool:
	var collisionLayer: int = collision_body.get_collision_layer()

	if(!LayerUtility.check_any_bits_from_bitmask(collisionLayer, _chase_targets_mask)):
		return false

	var body: Body
	if(collision_body is Body):
		body = collision_body as Body
	else:
		return false

	var collision_shape: CollisionShape3D = body.primary_collider
	if(!_is_collider_in_vision_cone(collision_shape)):

		return false

	if(_is_body_in_line_of_sight(body, collision_shape)):
		_nav_state_to_chasing(body)
		return true
	else:
		return false

func _on_velocity_computed(safe_velocity: Vector3) -> void:
	var nextPos: Vector3 = global_position + safe_velocity

	if(safe_velocity != Vector3.ZERO):
		TransformUtility.smooth_look_at(self, nextPos, _rotation_speed)

	velocity = safe_velocity
	move_and_slide()

func _is_body_in_line_of_sight(collision_body: Body, collider: CollisionShape3D) -> bool:
	var combined_mask: int = LayerUtility.get_bitmask_from_bits([_chase_targets_mask,_target_obstructions_mask])
	var result: Dictionary = TransformUtility.point_to_transform_raycast(_vision_point.global_position, collider, combined_mask)
	if result.size() > 0 && result.collider == collision_body:
		return true
	else:
		return false

func _is_collider_in_vision_cone(collider: CollisionShape3D) -> bool:
	var forward_direction: Vector3 = -global_transform.basis.z

	var to_target: Vector3 = (collider.global_position - global_position).normalized()
	var angle: float = rad_to_deg(forward_direction.angle_to(to_target))

	return angle <= (_current_cone_degree_detection / 2)


func _on_before_state_change() -> void:
	_current_chase_target = null
	_chase_time_remaining = -1
	_sweep_time_remaining = -1

func _nav_state_to_patrolling() -> void:
	_on_before_state_change()
	_movement_speed = _patrolling_movement_speed
	_rotation_speed = _patrolling_rotation_speed
	var radius: float = _detection_radius_patrolling
	_detection_area.scale = Vector3(radius, radius, radius)
	_current_cone_degree_detection = _detection_cone_degrees_patrolling
	_agent_nav_state = NavState.Patrolling

func _nav_state_to_chasing(collision_body: Body) -> void:
	_on_before_state_change()
	_movement_speed = _chasing_movement_speed
	_rotation_speed = _chasing_rotation_speed
	_current_chase_target = collision_body
	_chase_time_remaining = _chase_duration
	var radius: float = _detection_radius_chasing
	_detection_area.scale = Vector3(radius, radius, radius)
	_current_cone_degree_detection = _detection_cone_degrees_chasing
	_agent_nav_state = NavState.Chasing

func _nav_state_to_sweeping(last_detection_point: Vector3) -> void:
	_on_before_state_change()
	_movement_speed = _sweeping_movement_speed
	_rotation_speed = _sweeping_rotation_speed
	_last_detection_point = last_detection_point
	_sweep_time_remaining = _sweep_duration
	var radius: float = _detection_radius_sweeping
	_detection_area.scale = Vector3(radius, radius, radius)
	_current_cone_degree_detection = _detection_cone_degrees_sweeping
	_agent_nav_state = NavState.Sweeping
