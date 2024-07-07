class_name ColliderComponent
extends Node

#Area3D overlapping_bodies() returns the body and not the colliders, but
#for raycasting purposes, we need to return that primary collider and position
@export var _collision_shape: CollisionShape3D

func try_get_collison_shape() -> CollisionShape3D:
	if(_collision_shape != null):
		return _collision_shape
	else:
		return null
