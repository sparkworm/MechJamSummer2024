## Weapon is a parent class to contain most of the functionality for
## RangedWeapon and MeleeWeapon.
class_name Weapon
extends Node3D

@export var _owner: Node3D = null
@export var _weapon_ability: PackedScene = null
@export var _fire_point: Marker3D = null
@export var _cooldown_time: float = 10
@export var _num_abilities: int = 1

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

var _cooldown_timestamp: float = 0

func init_weapon(owner: Node3D):
	_owner = owner

## function to handle weapon attacking
## [br] Do note that "fire" can mean "swing" for melee weapons.
func fire(direction: Vector3) -> bool:
	if Time.get_unix_time_from_system() < _cooldown_timestamp:
		return false

	_cooldown_timestamp = _cooldown_time + Time.get_unix_time_from_system()
	var weapon_ability: Ability = _weapon_ability.instantiate() as Ability
	GameManager.current_level_scene.add_child(weapon_ability)
	direction.y = 0
	weapon_ability.init_with_world_direction(_owner, _fire_point.global_position, direction)
	return true
