#Abstract class for objects with a primary collider that can be interacted with
class_name Unit
extends Area3D

@onready var _primary_collider: CollisionShape3D = $PrimaryCollider

var primary_collider: CollisionShape3D:
	get:
		return _primary_collider

#Virtual
func _ready() -> void:
	pass

#Virtual
func _process(delta: float) -> void:
	pass
