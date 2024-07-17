extends Character
class_name PlayerCharacter

#region variables

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
@onready var _ammo_component: AmmoComponent = $Components/AmmoComponent
@onready var _player_health_UI: PlayerHealthUI = $CanvasLayer/PlayerHealthUI
@onready var _player_ammo_UI: PlayerAmmoUI = $CanvasLayer/PlayerAmmoUI

@export var _animation_player: AnimationPlayer = null
@export var _animation_tree: AnimationTree = null
@export var _blend_speed: float = 5
@export var _detection_area_radius: float = 10
@export var _obtain_radius: float = 1
@export var _energy_per_second: float = 4
@export var _energy_pause_time: float = 2

@export_group("Dash")
@export var _dash_speed: float = 5
@export var _dash_duration: float = 1
@export var _dash_blend_speed: float = 100
@export var _dash_deadzone: float = 2
@export var _dash_energy_minimum: float = 5
@export var _dash_energy_drain: float = 4

@export_group("Weapons")
@export var _rifle: Weapon = null
@export var _minigun: Weapon = null
@export var _axe: Weapon = null
@export var _weapon_swap_cooldown: float = 0.2

var _energy_pause_timer: float = 0
var _player_state: PlayerState = PlayerState.Active
var _mouse_pos_this_frame: Vector3
var _current_blend_position: Vector2 = Vector2()

var _current_weapon_swap_cooldown: float = 0
var _current_dash_time: float = 0
var _last_iso_input_dir: Vector2
var _mouse_distance_to_player: float

var _animation_transition:String = "parameters/Transition/transition_request"

#Idle Animation State
var _idle_transition:String = "Idle"
var _idle_attack_animation_request: String = "parameters/Idle_Attack/request"
var _idle_attack_animation: String = "parameters/Idle_Attack_Animation"
var _idle_animation: String = "parameters/Idle_Animation"

#Movement Animation State
var _movement_transition: String = "Movement"
var _movement_blend_position: String = "parameters/Run_Animation/blend_position"
var _run_attack_animation_request: String = "parameters/Run_Attack/request"
var _run_attack_animation: String = "parameters/Run_Attack_Animation"
var _run_idle_animation: String = "parameters/Run_Idle_Animation"

#Dash Animation State
var _dash_transition: String = "Dash"
var _dash_blend_position: String = "parameters/Dash_Animation/blend_position"
var _dash_attack_animation_request: String = "parameters/Dash_Attack/request"
var _dash_attack_animation: String = "parameters/Dash_Attack_Animation"
var _dash_idle_animation: String = "parameters/Dash_Idle_Animation"
#endregion

var _weapons_array: Array[Weapon] = [null, null, null]
var _current_weapon_index = 0

func _ready() -> void:
	_detection_area.scale = Vector3(_detection_area_radius, _detection_area_radius, _detection_area_radius)
	var detect_layers: int = LayerUtility.get_bit_from_layer_name("Accessible")
	_detection_area.collision_mask = detect_layers
	_health_component.connect("hit", _is_hit)
	_health_component.connect("killed", _die)

	_weapons_array[0] = _rifle
	_weapons_array[1] = _minigun
	_weapons_array[2] = _axe

	_rifle.init_weapon(self)
	_minigun.init_weapon(self)
	_axe.init_weapon(self)

	_rifle.visible = true
	_minigun.visible = false
	_axe.visible = false

	_animation_tree.tree_root = _weapons_array[0].animation_root

func _is_hit(source: Node3D, current_health: int):
	_player_health_UI.change_health(current_health)
	#add flash/update UI
	pass

func _die():
	#death
	pass

func _process(delta: float) -> void:
	_mouse_pos_this_frame = MouseUtility.get_mouse_pos_3d()
	_mouse_distance_to_player = _mouse_pos_this_frame.distance_to(global_position)
	_energy_pause_timer -= delta

	if(_player_state != PlayerState.Busy):

		if(Input.is_action_pressed("Cycle Weapon")):
			_cycle_weapon()

		if(_player_state == PlayerState.Active):
			_handle_movement_input()

			if(_check_dash_requirements()):
				_prepare_dash(velocity.normalized())

			else:
				if(velocity == Vector3.ZERO):
					_animation_tree[_animation_transition] = _idle_transition
				else: _animation_tree[_animation_transition] = _movement_transition
				_update_blend_position(_movement_blend_position, _blend_speed)


			_set_target_blend_position(_last_iso_input_dir)

		if(_player_state == PlayerState.Dashing):
			_energy_pause_timer = _energy_pause_time
			if(_handle_dashing()):
				_update_blend_position(_dash_blend_position, _dash_blend_speed)
				_animation_tree[_animation_transition] = _dash_transition
				_ammo_component.energy -= _dash_energy_drain * delta
		elif(_energy_pause_timer < 0):
			_ammo_component.energy += _energy_per_second * delta
		_handle_look_rotation_input()

		if Input.is_action_pressed("Primary"):
			use_primary_attack()
		elif Input.is_action_pressed("Secondary"):
			pass

	velocity.y -= 9.81 * delta
	move_and_slide()

	for node3D: Node3D in _detection_area.get_overlapping_bodies():
		if(node3D is CollisionObject3D):
			_on_overlapping_body(node3D)

func _check_dash_requirements() -> bool:
	if Input.is_action_pressed("Dash"):
		if(_mouse_distance_to_player > _dash_deadzone
		&& _ammo_component.energy > _dash_energy_minimum):
			return true
	return false

func _on_overlapping_body(node3D: Node3D) -> void:

	if(node3D is Pickup):
		_handle_pickup(node3D as Pickup)

#region movement

# TODO: move the functionality of getting input to the controller
func _handle_movement_input(direction := Vector2(0,0)) -> void:
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

	_last_iso_input_dir = Vector2(new_right, new_forward)

	velocity = _velocity

func _handle_look_rotation_input() -> void:
	TransformUtility.smooth_look_at(self, _mouse_pos_this_frame, _rotation_speed)

#endregion

#region blend

func _set_target_blend_position(target: Vector2) -> void:
	_current_blend_position = target

func _update_blend_position(blend_animation: String, blend_speed: float) -> void:
	var current_pos: Vector2 = _animation_tree.get(blend_animation)
	var new_pos: Vector2 = current_pos.lerp(_current_blend_position, _blend_speed
	* GameUtility.get_current_delta_time())
	_animation_tree.set(blend_animation, new_pos)

#endregion

func use_primary_attack() -> void:
	var weapon: Weapon = _weapons_array[_current_weapon_index] as Weapon
	var dir: Vector3 = (_mouse_pos_this_frame - global_position).normalized()

	if !weapon.fire(dir, _ammo_component):
		return

	if(_animation_tree[_animation_transition] == _idle_transition):
		_animation_tree[_idle_attack_animation_request] = AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE

	elif (_animation_tree[_animation_transition] == _movement_transition):
		_animation_tree[_run_attack_animation_request] = AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE

	elif (_animation_tree[_animation_transition] == _dash_transition):
		_animation_tree[_dash_attack_animation_request] = AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE


	#var dir: Vector3 = (_mouse_pos_this_frame - primary_collider.global_position).normalized()
	#dir.y = 0

func _handle_pickup(pickup: Pickup) -> void:
	pickup.assign_attract_target(primary_collider)
	if(primary_collider.global_transform.origin.distance_to(pickup.global_position) < _obtain_radius):
		var pickup_data: PickupData = pickup.obtain_pickup_data_and_expire()
		if(pickup_data is HealthData):
			var health_data: HealthData = pickup_data as HealthData
			_health_component.heal(health_data.health_amount)
			_player_health_UI.change_health(_health_component.health)
		elif(pickup_data is AmmoData):
			var ammo_data: AmmoData = pickup_data as AmmoData
			_ammo_component.add_ammo(ammo_data)
		elif(pickup_data is ArtifactData):
			var level: Level = GameManager.current_level_scene as Level
			level.level_objective_collected = true

func _prepare_dash(direction: Vector3):
	if(direction == Vector3.ZERO):
		direction = -global_transform.basis.z.normalized()
		_last_iso_input_dir = Vector2(0, 1)

	CameraManager.activate_frame_buffers(_dash_duration)
	_player_state = PlayerState.Dashing
	_current_dash_time = _dash_duration
	velocity = direction * _dash_speed

func _handle_dashing() -> bool:
	_current_dash_time -= GameUtility.get_current_delta_time()
	if(_current_dash_time < 0):
		_player_state = PlayerState.Active
		velocity = Vector3(0,0,0)
		return false
	return true

func _cycle_weapon():
	var i: int = _current_weapon_index

	i += 1
	if i >= _weapons_array.size():
		i = 0

	for weapon_index in range(_weapons_array.size() - 1):
		if _weapons_array[i] != null:
			change_weapon(i)
			return

func change_weapon(weapon_index: int):
	if(_current_weapon_swap_cooldown > Time.get_unix_time_from_system()):
		return;

	if(weapon_index + 1 > _weapons_array.size()
	|| _weapons_array[weapon_index] == null
	|| _current_weapon_index == weapon_index):
		return

	var current_transition: String = _animation_tree[_animation_transition]
	var current_weapon: Weapon = _weapons_array[_current_weapon_index]
	var new_weapon: Weapon = _weapons_array[weapon_index]
	_current_weapon_index = weapon_index

	if(current_weapon.animation_root != new_weapon.animation_root):
		_animation_tree.tree_root = new_weapon.animation_root
	_animation_tree[_animation_transition] = current_transition

	current_weapon.visible = false
	new_weapon.visible = true

	new_weapon.set_cooldown(0.1)
	_current_weapon_swap_cooldown = _weapon_swap_cooldown + Time.get_unix_time_from_system()
