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
	Attacking,
	Sweeping,
}

@export_subgroup("Enemy Animation")
@export var _animation_tree: AnimationTree = null
@export var _animation_player: AnimationPlayer = null

@export_subgroup("Enemy Weapons") #This should be replaced by Weapon class scripts later
@onready var _attack_component: AttackComponent = $Components/AttackComponent
@export var _weapon_1_fire_point: Marker3D = null
@export var _weapon_1_range: float = 10
@export var _weapon_cooldown_time: float = 3
@export var _weapon_1_projectile: PackedScene = null

@export_subgroup("Detection Layers")
@export var _chase_targets: Array[LayerUtility.Layer] #Targets the enemy will chase
@export var _target_obstructions: Array[LayerUtility.Layer] #Targets that block the enemy's vision

@export_subgroup("Patrolling Attributes")
@export var _patrol_route: PatrolRoute = null
@export var _current_patrol_point: PatrolPoint = null
@export var _random_patrol_points: bool = false
@export var _patrolling_movement_speed: float = 2
@export var _patrolling_rotation_speed: float = 3
@export var _patrolling_idle_duration: float = 1
@export var _patrolling_radius_detection: float = 12
@export var _patrolling_cone_degrees_detection: float = 160
@export var _patrolling_area_variance: Vector3 = Vector3(1, 0, 1)


@export_subgroup("Chasing Attributes")
@export var _chasing_movement_speed: float = 5
@export var _chasing_rotation_speed: float = 10
@export var _chase_radius_detection: float = 20
@export var _chasing_detection_cone_degrees: float = 280
@export var _chase_duration: float = 2

@export_subgroup("Attacking Attributes")
@export var _attacking_detection_cone_degrees: float = 35

@export_subgroup("Sweeping Attributes")
@export var _sweeping_movement_speed: float = 3
@export var _sweeping_rotation_speed: float = 5
@export var _sweeping_detection_radius: float = 16
@export var _sweeping_detection_cone_degrees: float = 200
@export var _sweeping_state_duration: float = 20
@export var _sweeping_idle_duration: float = 1
@export var _sweeping_area_variance: Vector3 = Vector3(10, 0, 10)

@onready var _nav_agent: NavigationAgent3D = $NavigationAgent3D
@onready var _vision_point: Node3D = $VisionPoint
@onready var _detection_area: Area3D = $DetectionArea
@onready var _health_component: HealthComponent = $Components/HealthComponent

var detection_cone_degrees: Dictionary

var _chase_targets_mask: int = 0
var _target_obstructions_mask: int = 0

var _agent_nav_state: NavState = NavState.Patrolling
var _current_target: Body = null
var _state_time_remaining: float = 0
var _idle_time_remaining: float = 0
var _last_detection_point: Vector3 = Vector3.ZERO

var _current_attack_animation_time: float = 0
var _has_started_attack = false;

#Animation garbage
var _animation_transition:String = "parameters/Transition/transition_request"
var _movements_transition:String = "Movements"
var _attacks_transition:String = "Attacks"
var _disables_transition:String = "Disables"

#Movements Animations
var _movements_FSM: AnimationNodeStateMachinePlayback
var _walking_animation: String = "Walking"
var _chasing_animation: String = "Chasing"
var _sweeping_animation: String = "Sweeping"
var _idle_animation: String = "Idle"

#Disables Animations
var _disables_FSM: AnimationNodeStateMachinePlayback
var _death_1_animation: String = "Death_1"
var _death_2_animation: String = "Death_2"

#Attacks Animations
var _attack_1_animation: String = "parameters/Attack_1/request"
var _attack_1_time_scale: String = "parameters/Attack_1_TimeScale/scale"
var _attack_2_animation: String = "parameters/Attack_2/request"
var _attack_2_time_scale: String = "parameters/Attack_2_TimeScale/scale"

func _ready() -> void:
	set_physics_process(false)
	call_deferred("_deffered_ready")

func _deffered_ready():
	await get_tree().physics_frame
	set_physics_process(true)
	_movements_FSM = _animation_tree.get("parameters/Movements_FSM/playback")
	_disables_FSM = _animation_tree.get("parameters/Disables_FSM/playback")

	detection_cone_degrees = {
		NavState.Patrolling: _patrolling_cone_degrees_detection,
		NavState.Chasing: _chasing_detection_cone_degrees,
		NavState.Attacking: _attacking_detection_cone_degrees,
		NavState.Sweeping: _sweeping_detection_cone_degrees,
	}

	_chase_targets_mask = LayerUtility.get_bitmask_from_bits(_chase_targets)
	_target_obstructions_mask = LayerUtility.get_bitmask_from_bits(_target_obstructions)
	_detection_area.collision_mask = _chase_targets_mask
	_nav_agent.velocity_computed.connect(Callable(_on_velocity_computed))
	_nav_agent.target_desired_distance = 1
	_health_component.connect("hit", _is_hit)
	_init_patrol_route()

func _init_patrol_route() -> void:
	if(_patrol_route == null):
		_patrol_route = GameManager.current_level_scene.get_random_level_patrol_route()

	if(_current_patrol_point == null):
		if(_random_patrol_points):
			_current_patrol_point = _patrol_route.get_random_patrol_point()
		else:
			_current_patrol_point = _patrol_route.get_closest_patrol_point_from_point(self)

	if(!_try_set_nav_point_in_area(_current_patrol_point.global_position, _patrolling_area_variance)):
		_set_movement_target(_current_patrol_point.global_position)
	_nav_state_to_patrolling()

func _is_hit(source: Node3D) -> void:
	if(_agent_nav_state != NavState.Attacking && source is Body):
		_nav_state_to_chasing(source as Body)
	pass

func _die() -> void:
	pass

func _set_movement_target(movement_target: Vector3) -> void:
	_nav_agent.set_target_position(movement_target)

#func get

func _physics_process(delta: float) -> void:
	_state_time_remaining -= delta

	if _agent_nav_state == NavState.Attacking:
		_attack_target()

	else:
		for node3D: CollisionObject3D in _detection_area.get_overlapping_bodies():
			if (node3D is CollisionObject3D && _on_overlapping_body(node3D)):
				break

		_animation_tree[_animation_transition] = _movements_transition

		if _agent_nav_state == NavState.Patrolling:
			_patrol_area()

		elif _agent_nav_state == NavState.Chasing:
			_chase_target()

		else: #_agent_nav_state == NavState.Sweeping:
			_sweep_area()

		if !_nav_agent.is_navigation_finished():
			_move_agent()

		else:
			_movements_FSM.travel(_idle_animation)


func _move_agent() -> void:
	_movement_delta = _movement_speed * GameUtility.get_current_delta_time()
	var next_path_position: Vector3 = _nav_agent.get_next_path_position()
	var new_velocity: Vector3 = global_position.direction_to(next_path_position) * _movement_speed
	if _nav_agent.avoidance_enabled:
		_nav_agent.set_velocity(new_velocity)
	else:
		_on_velocity_computed(new_velocity)

func _patrol_area() -> void:
	if(_nav_agent.is_navigation_finished()):
		_idle_time_remaining -= GameUtility.get_current_delta_time()
		if(_idle_time_remaining < 0):
			_get_next_patrol_point()

	else:
		if(_movements_FSM.get_current_node() != _walking_animation):
			_movements_FSM.travel(_walking_animation)

func _get_next_patrol_point() -> void:
	if(_random_patrol_points):
		_current_patrol_point = _patrol_route.get_next_point_from_route(_current_patrol_point)
	else:
		_current_patrol_point = _patrol_route.get_random_patrol_point()

	if(!_try_set_nav_point_in_area(_current_patrol_point.global_position, _patrolling_area_variance)):
		_set_movement_target(_current_patrol_point.global_position)
		_idle_time_remaining = _patrolling_idle_duration


func _chase_target() -> void:
	if(_current_target == null):
		_nav_state_to_patrolling()

	var target_position = _current_target.global_position
	if(global_position.distance_to(target_position) < _weapon_1_range):
		var combined_mask: int = LayerUtility.get_bitmask_from_bits([_chase_targets_mask,_target_obstructions_mask])
		var collision_shape: CollisionShape3D = _current_target.primary_collider
		if(_is_collider_in_vision_cone(collision_shape, detection_cone_degrees[NavState.Attacking])
			&& _is_body_in_line_of_sight(_current_target, combined_mask)):
			_nav_state_to_attacking(_current_target)
			return

	_movements_FSM.travel(_chasing_animation)
	#probably add a delay to this later
	_set_movement_target(target_position)
	if(_state_time_remaining < 0):
		_nav_state_to_sweeping(target_position)
	pass

func _attack_target() -> void:
	if(_current_target == null):
		_nav_state_to_patrolling()

	_animation_tree[_animation_transition] = _attacks_transition
	if(!_has_started_attack):
		_animation_tree[_attack_1_animation] = AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE
		_current_attack_animation_time = 1 + Time.get_unix_time_from_system()
		_has_started_attack = true
	elif(Time.get_unix_time_from_system() > _current_attack_animation_time):
		_nav_state_to_chasing(_current_target)


func _sweep_area() -> void:
	if(_nav_agent.is_navigation_finished()):
		_idle_time_remaining -= GameUtility.get_current_delta_time()
		if(_idle_time_remaining < 0
		&& _try_set_nav_point_in_area(_last_detection_point, _sweeping_area_variance)):
			_idle_time_remaining = _sweeping_idle_duration

	_movements_FSM.travel(_sweeping_animation)
	if(_state_time_remaining < 0):
		_nav_state_to_patrolling()

func _try_set_nav_point_in_area(point: Vector3, area_variance: Vector3) -> bool:
	var current_pos: Vector3 = global_position
	for i: int in range(RANDOM_SAMPLES):
		var variance: Vector3 = GameUtility.get_random_point_in_radius(area_variance)
		_set_movement_target(point + variance)
		if(_nav_agent.is_target_reachable()):
			return true
	_set_movement_target(current_pos)
	return false


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
	if(!_is_collider_in_vision_cone(collision_shape, detection_cone_degrees[_agent_nav_state])):
		return false

	var combined_mask: int = LayerUtility.get_bitmask_from_bits([_chase_targets_mask,_target_obstructions_mask])
	if(_is_body_in_line_of_sight(body, combined_mask)):
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

func _is_body_in_line_of_sight(collision_body: Body, mask: int) -> bool:
	var collider: CollisionShape3D = collision_body.primary_collider
	var result: Dictionary = TransformUtility.point_to_transform_raycast(_vision_point.global_position, collider, mask)
	if result.size() > 0 && result.collider == collision_body:
		return true
	else:
		return false

func _is_collider_in_vision_cone(collider: CollisionShape3D, degrees: float) -> bool:
	var forward_direction: Vector3 = -_vision_point.global_transform.basis.z

	var to_target: Vector3 = (collider.global_position - _vision_point.global_position).normalized()
	var angle: float = rad_to_deg(forward_direction.angle_to(to_target))

	return angle <= (degrees / 2)


func _on_before_state_change() -> void:
	_state_time_remaining = 0
	pass

func _nav_state_to_patrolling() -> void:
	_on_before_state_change()
	_idle_time_remaining = _patrolling_idle_duration
	_movement_speed = _patrolling_movement_speed
	_rotation_speed = _patrolling_rotation_speed
	var radius: float = _patrolling_radius_detection
	_detection_area.scale = Vector3(radius, radius, radius)
	_agent_nav_state = NavState.Patrolling

func _nav_state_to_chasing(collision_body: Body) -> void:
	_on_before_state_change()
	_movement_speed = _chasing_movement_speed
	_rotation_speed = _chasing_rotation_speed
	_current_target = collision_body
	_state_time_remaining = _chase_duration
	var radius: float = _chase_radius_detection
	_detection_area.scale = Vector3(radius, radius, radius)
	_agent_nav_state = NavState.Chasing

func _nav_state_to_attacking(collision_body: Body) -> void:
	_on_before_state_change()
	_animation_tree[_animation_transition] = _attacks_transition
	_nav_agent.target_position = global_position
	_current_target = collision_body
	_agent_nav_state = NavState.Attacking
	_has_started_attack = false

func _nav_state_to_sweeping(last_detection_point: Vector3) -> void:
	_on_before_state_change()
	_idle_time_remaining = _sweeping_idle_duration
	_movement_speed = _sweeping_movement_speed
	_rotation_speed = _sweeping_rotation_speed
	_last_detection_point = last_detection_point
	_state_time_remaining = _sweeping_state_duration
	var radius: float = _sweeping_detection_radius
	_detection_area.scale = Vector3(radius, radius, radius)
	_agent_nav_state = NavState.Sweeping


func use_primary_attack() -> void:
	var attack_projectile: Projectile = _weapon_1_projectile.instantiate() as Projectile
	get_tree().root.get_child(0).add_child(attack_projectile)
	var fire_point_pos: Vector3 = _weapon_1_fire_point.global_position
	var dir: Vector3 = (_current_target.primary_collider.global_position - fire_point_pos).normalized()
	dir.y = 0
	attack_projectile.init_with_world_direction(self, fire_point_pos, dir)
