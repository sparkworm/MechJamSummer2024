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

@export_subgroup("Attacking Attributes")
@export var _detection_cone_degrees_attacking: float = 35

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

var detection_cone_degrees: Dictionary

var _chase_targets_mask: int = 0
var _target_obstructions_mask: int = 0

var _agent_nav_state: NavState = NavState.Patrolling
var _current_target: Body = null
var _chase_time_remaining: float = 0
var _sweep_time_remaining: float = 0
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
var _walking_1_animation: String = "Walking_1"
var _walking_2_animation: String = "Walking_2"
var _running_1_animation: String = "Running_1"
var _running_2_animation: String = "Running_2"

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
	_movements_FSM = _animation_tree.get("parameters/Movements_FSM/playback")
	_disables_FSM = _animation_tree.get("parameters/Disables_FSM/playback")

	detection_cone_degrees = {
		NavState.Patrolling: _detection_cone_degrees_patrolling,
		NavState.Chasing: _detection_cone_degrees_chasing,
		NavState.Attacking: _detection_cone_degrees_attacking,
		NavState.Sweeping: _detection_cone_degrees_sweeping,
	}

	_chase_targets_mask = LayerUtility.get_bitmask_from_bits(_chase_targets)
	_target_obstructions_mask = LayerUtility.get_bitmask_from_bits(_target_obstructions)
	_detection_area.collision_mask = _chase_targets_mask
	_nav_agent.velocity_computed.connect(Callable(_on_velocity_computed))
	_nav_agent.target_desired_distance = 1
	_health_component.connect("hit", _is_hit)
	_nav_state_to_patrolling()


func _is_hit(source: Node3D) -> void:
	if(_agent_nav_state != NavState.Attacking && source is Body):
		_nav_state_to_chasing(source as Body)
	pass

func _die() -> void:
	pass

func _set_movement_target(movement_target: Vector3) -> void:
	_nav_agent.set_target_position(movement_target)

func _physics_process(delta: float) -> void:
	#Will change this to time-stamp comparisons later
	_chase_time_remaining -= delta
	_sweep_time_remaining -= delta

	if _agent_nav_state == NavState.Attacking:
		_attack_target()

	else:
		for node3D: CollisionObject3D in _detection_area.get_overlapping_bodies():
			if (node3D is CollisionObject3D && _on_overlapping_body(node3D)):
				break

		if _agent_nav_state == NavState.Patrolling:
			pass

		elif _agent_nav_state == NavState.Chasing:
			_chase_target()

		else: #_agent_nav_state == NavState.Sweeping:
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
	if(_current_target == null):
		_nav_state_to_patrolling()

	var target_position = _current_target.global_position
	if(global_position.distance_to(target_position) < _weapon_1_range):
		print(global_position.distance_to(target_position))
		var combined_mask: int = LayerUtility.get_bitmask_from_bits([_chase_targets_mask,_target_obstructions_mask])
		var collision_shape: CollisionShape3D = _current_target.primary_collider
		if(_is_collider_in_vision_cone(collision_shape, detection_cone_degrees[NavState.Attacking])
			&& _is_body_in_line_of_sight(_current_target, combined_mask)):
			_nav_state_to_attacking(_current_target)
			return

	#probably add a delay to this later
	_set_movement_target(target_position)
	if(_chase_time_remaining < 0):
		_nav_state_to_sweeping(target_position)
	pass

func _attack_target() -> void:
	if(_current_target == null):
		_nav_state_to_patrolling()

	if(!_has_started_attack):
	#_attack_component.use_primary_attack(self, _weapon_1_fire_point)
		_animation_tree[_attack_1_animation] = AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE
		_current_attack_animation_time = 1 + Time.get_unix_time_from_system()
		_has_started_attack = true
	elif(Time.get_unix_time_from_system() > _current_attack_animation_time):
		_nav_state_to_chasing(_current_target)


func _sweep_area() -> void:
	if(_nav_agent.is_navigation_finished()):
		for i: int in range(RANDOM_SAMPLES):
			var random_point: Vector3 = GameUtility.get_random_point_in_radius(_sweep_radius)
			_set_movement_target(_last_detection_point + random_point)
			if(_nav_agent.is_target_reachable()):
				break

	if(_sweep_time_remaining < 0):
		_nav_state_to_patrolling()

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
	pass

func _nav_state_to_patrolling() -> void:
	_on_before_state_change()
	_animation_tree[_animation_transition] = _movements_transition
	#_movements_FSM.travel("Idle")
	_movement_speed = _patrolling_movement_speed
	_rotation_speed = _patrolling_rotation_speed
	var radius: float = _detection_radius_patrolling
	_detection_area.scale = Vector3(radius, radius, radius)
	_agent_nav_state = NavState.Patrolling

func _nav_state_to_chasing(collision_body: Body) -> void:
	_on_before_state_change()
	_animation_tree[_animation_transition] = _movements_transition
	_movements_FSM.travel(_running_1_animation)
	_movement_speed = _chasing_movement_speed
	_rotation_speed = _chasing_rotation_speed
	_current_target = collision_body
	_chase_time_remaining = _chase_duration
	var radius: float = _detection_radius_chasing
	_detection_area.scale = Vector3(radius, radius, radius)
	_agent_nav_state = NavState.Chasing

func _nav_state_to_attacking(collision_body: Body) -> void:
	_on_before_state_change()
	_animation_tree[_animation_transition] = _attacks_transition
	_movements_FSM.travel(_running_1_animation)
	_nav_agent.target_position = global_position
	_current_target = collision_body
	_agent_nav_state = NavState.Attacking
	_has_started_attack = false

func _nav_state_to_sweeping(last_detection_point: Vector3) -> void:
	_on_before_state_change()
	_animation_tree[_animation_transition] = _movements_transition
	_movements_FSM.travel(_running_2_animation)
	_movement_speed = _sweeping_movement_speed
	_rotation_speed = _sweeping_rotation_speed
	_last_detection_point = last_detection_point
	_sweep_time_remaining = _sweep_duration
	var radius: float = _detection_radius_sweeping
	_detection_area.scale = Vector3(radius, radius, radius)
	_agent_nav_state = NavState.Sweeping


func use_primary_attack() -> void:
	var attack_projectile: Projectile = _weapon_1_projectile.instantiate() as Projectile
	get_tree().root.get_child(0).add_child(attack_projectile)
	var fire_point_pos: Vector3 = _weapon_1_fire_point.global_position
	var dir: Vector3 = (_current_target.primary_collider.global_position - fire_point_pos).normalized()
	dir.y = 0
	attack_projectile.init_with_world_direction(self, fire_point_pos, dir)
