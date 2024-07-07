class_name AttackComponent
extends Node

#TODO: Attack implementations (Projectile/Attack, Speed, Ammo, ect)
#Perhaps we should abstract this into melee attacks and projectile attack type classes

@export var _primary_attack_scene: PackedScene
var _primary_attack_current_cooldown: float = 0

func use_primary_attack(source: Node3D, fire_point: Node3D) -> void:
	if _primary_attack_current_cooldown > Time.get_unix_time_from_system():
		return

	var attack_projectile: Projectile = _primary_attack_scene.instantiate() as Projectile
	get_tree().root.get_child(0).add_child(attack_projectile)
	var dir: Vector3 = -fire_point.global_transform.basis.z
	attack_projectile.init_with_world_direction(source, fire_point.global_position, dir)
	_primary_attack_current_cooldown = attack_projectile.cooldown_time + Time.get_unix_time_from_system()
