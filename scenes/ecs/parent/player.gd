extends Body
class_name PlayerCharacter

enum PlayerState
{
	Active,
	Dashing,
	Busy,
}

#Currently used just for pickups but could be used for other features
@onready var _detection_area: Area3D = $DetectionArea

@onready var _attack_component: AttackComponent = $Components/AttackComponent
@onready var _health_component: HealthComponent = $Components/HealthComponent
@onready var _energy_component: EnergyComponent = $Components/EnergyComponent
@onready var _ammo_component: AmmoComponent = $Components/AmmoComponent

@export var _fire_point: Node3D = null
@export var _fire_cursor: MeshInstance3D = null
@export var _animation_player: AnimationPlayer = null
@export var _animation_tree: AnimationTree = null
@export var _blend_speed: float = 5
@export var _detection_area_radius: float = 10
@export var _obtain_radius: float = 1

@export_group("Dash")
@export var _dash_speed: float = 5
@export var _dash_duration: float = 1

var _player_state: PlayerState = PlayerState.Active
var _mouse_pos_this_frame: Vector3
var _current_blend_position: Vector2 = Vector2()

var _current_dash_time: float = 0

@export var _primary_attack_scene: PackedScene
var _primary_attack_current_cooldown: float = 0

var _animation_transition:String = "parameters/Transition/transition_request"

#Idle Animation State
var _idle_transition:String = "Idle"
var _idle_attack_animation: String = "parameters/Idle_Attack/request"

#Movement Animation State
var _movement_transition: String = "Movement"
var _movement_blend_position: String = "parameters/Run_Animation/blend_position"
var _run_attack_animation: String = "parameters/Run_Attack/request"

func _ready() -> void:
	_detection_area.scale = Vector3(_detection_area_radius, _detection_area_radius, _detection_area_radius)
	var detect_layers: int = LayerUtility.get_bit_from_layer_name("Accessible")
	_detection_area.collision_mask = detect_layers

func _physics_process(delta: float) -> void:
	_mouse_pos_this_frame = MouseUtility.get_mouse_pos_3d()
	_fire_cursor.global_position = _mouse_pos_this_frame

	if(_player_state == PlayerState.Active):
		_handle_movement_input()
		_update_blend_position(delta)
		_handle_look_rotation_input()

		if Input.is_action_pressed("Dash"):
			_prepare_dash()
		elif Input.is_action_pressed("Primary"):
			use_primary_attack()
		elif Input.is_action_pressed("Secondary"):
			pass
		elif Input.is_action_pressed("Interact"):
			pass

	elif(_player_state == PlayerState.Dashing):
		_handle_dashing()

	for node3D: Node3D in _detection_area.get_overlapping_bodies():
		if(node3D is CollisionObject3D):
			_on_overlapping_body(node3D)

func _on_overlapping_body(node3D: Node3D) -> void:

	if(node3D is Pickup):
		_handle_pickup(node3D as Pickup)

func _handle_movement_input() -> void:
	var input_dir: Vector2 = Input.get_vector("Left", "Right", "Up", "Down")
	var isometric_dir: Vector3 = Vector3(input_dir.x + input_dir.y, 0, input_dir.y - input_dir.x).normalized()

	if isometric_dir.length() > 0:
		_velocity.x = isometric_dir.x * _movement_speed
		_velocity.z = isometric_dir.z * _movement_speed

	else:
		_velocity.x = move_toward(_velocity.x, 0, _movement_speed)
		_velocity.z = move_toward(_velocity.z, 0, _movement_speed)

	var forward = -global_transform.basis.z.normalized()
	var right = global_transform.basis.x.normalized()

	var new_forward: float = isometric_dir.dot(forward)
	var new_right: float = isometric_dir.dot(right)

	_animation_tree[_animation_transition] = _movement_transition
	_set_target_blend_position(Vector2(new_right, new_forward))

	velocity = _velocity

	move_and_slide()


func _set_target_blend_position(target: Vector2) -> void:
	_current_blend_position = target

func _update_blend_position(delta: float) -> void:
	var current_pos: Vector2 = _animation_tree.get(_movement_blend_position)
	var new_pos: Vector2 = current_pos.lerp(_current_blend_position, _blend_speed * delta)
	_animation_tree.set(_movement_blend_position, new_pos)

func _handle_look_rotation_input() -> void:
	TransformUtility.smooth_look_at(self, _mouse_pos_this_frame, _rotation_speed)

func use_primary_attack() -> void:
	if _primary_attack_current_cooldown > Time.get_unix_time_from_system():
		return

	_animation_tree[_idle_attack_animation] = AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE
	_animation_tree[_run_attack_animation] = AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE
	var attack_projectile: Projectile = _primary_attack_scene.instantiate() as Projectile
	get_tree().root.get_child(0).add_child(attack_projectile)
	var dir: Vector3 = (_mouse_pos_this_frame - primary_collider.global_position).normalized()
	dir.y = 0
	attack_projectile.init_with_world_direction(self, _fire_point.global_position, dir)
	_primary_attack_current_cooldown = attack_projectile.cooldown_time + Time.get_unix_time_from_system()

func _handle_pickup(pickup: Pickup) -> void:
	pickup.assign_attract_target(primary_collider)
	if(primary_collider.global_transform.origin.distance_to(pickup.global_position) < _obtain_radius):
		var pickup_data: PickupData = pickup.obtain_pickup_data_and_expire()
		if(pickup_data is HealthData):
			var health_data: HealthData = pickup_data as HealthData
			_health_component.heal(health_data.health_amount)
		elif(pickup_data is EnergyData):
			var energy_data: EnergyData = pickup_data as EnergyData
			_energy_component.energy = energy_data.energy_amount
		elif(pickup_data is AmmoData):
			var ammo_data: AmmoData = pickup_data as AmmoData
			_ammo_component.add_ammo(ammo_data)

func _prepare_dash():
	look_at(_mouse_pos_this_frame)
	_player_state == PlayerState.Dashing
	_current_dash_time = _dash_duration
	#_animation_tree[_dash_animation] = AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE
	velocity = -global_transform.basis.z.normalized() * _dash_speed
	move_and_slide()

func _handle_dashing():
	_current_dash_time -= GameUtility.get_current_delta_time()

	if(_current_dash_time < 0):
		_player_state = PlayerState.Active
		velocity = Vector3(0,0,0)
