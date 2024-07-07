extends Body
class_name EnemyCharacter

@export_subgroup("Detection Properties")
@export var _chase_targets: Array[LayerUtility.Layer] #Targets the enemy will chase
@export var _target_obstructions: Array[LayerUtility.Layer] #Targets that block the enemy's vision
@export var _detection_radius: float = 12
@export var _detection_cone_degrees: float = 160

@onready var _nav_agent: NavigationAgent3D = $NavigationAgent3D
@onready var _vision_point: Node3D = $VisionPoint
@onready var _detection_area: Area3D = $DetectionArea
@onready var _health_component: HealthComponent = $Components/HealthComponent

var _chase_targets_mask: int = 0
var _target_obstructions_mask: int = 0

func _ready() -> void:
	_chase_targets_mask = LayerUtility.get_bitmask_from_bits(_chase_targets)
	_target_obstructions_mask = LayerUtility.get_bitmask_from_bits(_target_obstructions)
	_detection_area.scale = Vector3(_detection_radius, _detection_radius, _detection_radius)
	_nav_agent.velocity_computed.connect(Callable(_on_velocity_computed))

	_health_component.connect("hit", _is_hit)

func _is_hit(source: Node3D) -> void:
	_move_to_point(source.global_position)
	pass

func _die() -> void:
	pass

func _set_movement_target(movement_target: Vector3) -> void:
	_nav_agent.set_target_position(movement_target)

func _physics_process(delta: float) -> void:

	for collision_body: CollisionObject3D in _detection_area.get_overlapping_bodies():
		if _on_overlapping_body(collision_body):
			break

	if _nav_agent.is_navigation_finished():
		return

	else:
		_move_agent()

func _move_agent() -> void:
	_movement_delta = _movement_speed * GameManager.get_current_delta_time()
	var next_path_position: Vector3 = _nav_agent.get_next_path_position()
	var new_velocity: Vector3 = global_position.direction_to(next_path_position) * _movement_speed
	if _nav_agent.avoidance_enabled:
		_nav_agent.set_velocity(new_velocity)
	else:
		_on_velocity_computed(new_velocity)

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

	if(_is_collider_in_line_of_sight(collision_body, collision_shape)):
		_move_to_point(collision_body.global_position)
		return true
	else:
		return false

func _on_velocity_computed(safe_velocity: Vector3) -> void:
	var nextPos: Vector3 = global_position + safe_velocity

	if(safe_velocity != Vector3.ZERO):
		RotationUtility.smooth_look_at(self, nextPos, _rotation_speed)

	velocity = safe_velocity
	move_and_slide()

func _is_collider_in_line_of_sight(collision_body: CollisionObject3D, collider: CollisionShape3D) -> bool:
	var space_state: PhysicsDirectSpaceState3D = get_world_3d().direct_space_state
	var direction: Vector3 = (collider.global_position - _vision_point.global_position).normalized()
	var endPoint: Vector3 = collider.global_position + direction * 2
	var ray_query: PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.create(_vision_point.global_position, endPoint)
	ray_query.exclude = [self]
	var combined_mask: int = LayerUtility.get_bitmask_from_bits([_chase_targets_mask,_target_obstructions_mask])
	ray_query.collision_mask = combined_mask
	var result: Dictionary = space_state.intersect_ray(ray_query)
	if result.size() > 0 && result.collider == collision_body:
		return true
	else:
		return false

func _is_collider_in_vision_cone(collider: CollisionShape3D) -> bool:
	var forward_direction: Vector3 = -global_transform.basis.z

	var to_target: Vector3 = (collider.global_position - global_position).normalized()
	var angle: float = rad_to_deg(forward_direction.angle_to(to_target))

	return angle <= (_detection_cone_degrees / 2)

func _move_to_point(point: Vector3) -> void:
	_set_movement_target(point)
