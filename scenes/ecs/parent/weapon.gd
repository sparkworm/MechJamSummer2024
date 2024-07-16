## Weapon is a parent class to contain most of the functionality for
## RangedWeapon and MeleeWeapon.
class_name Weapon
extends Node3D

@export var _owner: Node3D = null
@export var _weapon_ability: PackedScene = null
@export var _cooldown_time: float = 10
@export var _num_abilities: int = 1
@export var _spread_angle: float = 100

@export_group("VFX")
@export var _ability_fire_vfx: GPUParticles3D = null
@export var _ability_casings_vfx: GPUParticles3D = null

@export_group("SFX")
@export var _ability_fire_sfx: AudioStreamPlayer3D = null

@export_group("Animaton")
@export var _animation_root_node: AnimationRootNode
var animation_root: AnimationRootNode:
	get: return _animation_root_node

@export var _attack_animation = "2H_Ranged_Fire"
var attack_animation: AnimationRootNode:
	get: return _attack_animation

@export var  _idle_animation = "2H_Ranged_Idle"
var idle_animation: AnimationRootNode:
	get: return _idle_animation

@onready var _fire_point: Marker3D = $FirePoint

var _cooldown_timestamp: float = 0
var _vfx_toggle_time: float = 0

func init_weapon(owner: Node3D):
	_owner = owner

#Crappy bandaid because these systems suck
func _process(delta: float):
	_vfx_toggle_time -= delta
	if(_vfx_toggle_time > 0):
		if(_ability_casings_vfx != null):
			_ability_casings_vfx.emitting = true

		if(_ability_fire_vfx != null):
			_ability_fire_vfx.emitting = true

	else:
		if(_ability_casings_vfx != null):
			_ability_casings_vfx.emitting = false

		if(_ability_fire_vfx != null):
			_ability_fire_vfx.emitting = false


## function to handle weapon attacking
## [br] Do note that "fire" can mean "swing" for melee weapons.
func fire(direction: Vector3) -> bool:
	if Time.get_unix_time_from_system() < _cooldown_timestamp:
		return false

	set_cooldown(_cooldown_time)

	# play the fire sound effect
	_ability_fire_sfx.play()

	direction.y = 0

	
	if _num_abilities <= 1:
		var weapon_ability: Ability = _weapon_ability.instantiate() as Ability
		GameManager.current_level_scene.add_child(weapon_ability)
		weapon_ability.init_with_world_direction(_owner, _fire_point.global_position, direction)

	else:
		var angle_step: float = _spread_angle / (_num_abilities - 1)
		var start_angle: float = -_spread_angle / 2.0

		for i in range(_num_abilities):
			var weapon_ability: Ability = _weapon_ability.instantiate() as Ability
			GameManager.current_level_scene.add_child(weapon_ability)
			weapon_ability.global_transform = global_transform
			var rotation_angle: float = start_angle + i * angle_step
			print(rotation_angle)
			var new_dir = direction.rotated(Vector3.UP, rotation_angle).normalized()
			weapon_ability.init_with_world_direction(_owner, _fire_point.global_position, new_dir)

	_vfx_toggle_time = 0.2
	return true

func set_cooldown(cd: float):
	_cooldown_timestamp = Time.get_unix_time_from_system() + cd
