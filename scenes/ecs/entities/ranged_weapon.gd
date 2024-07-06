extends Weapon
class_name RangedWeapon

## The projectile that the weapon will fire
@export var projectile: PackedScene
## The speed at which the projectile travels (the length of the velocity)
@export var projectile_speed: float

# TODO: add a vfx class that will create particles and light, then add it:
#@export var fire_effect: vfx

## A marker, the coordinates of which are where the projectile spawns
@onready var projectile_spawn_location: Marker3D = $ProjectileSpawnLocation

func _use_weapon() -> void:
	spawn_projectile()

## The function responsible for spawning the projectile and assigning it the correct 
## position and velocity.
# WARNING: untested use of Projectile
# NOTE: needs a node in group "projectile_parent" somewhere in the SceneTree
func spawn_projectile() -> void:
	# add the projectile to the designated node up the SceneTree
	var projectile_parent: Node3D = \
			get_tree().get_nodes_in_group("projectile_parent")[0]
	projectile_parent.add_child(projectile.instantiate())
	# make the projectile face the same way as the weapon
	projectile.global_rotation = get_weapon_direction()

## The function responsible for getting the global rotation of the weapon
func get_weapon_direction() -> Vector3:
	# WARNING: untested; may need to be tweaked to get the correct rotation
	return global_rotation
