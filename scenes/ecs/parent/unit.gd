#Abstract class for objects with a primary collider that can be interacted with
class_name Unit
extends Node3D

@onready var _primary_collider: CollisionShape3D = $PrimaryCollider

#Virtual
func _ready() -> void:
	pass

#Virtual
func _process(delta: float) -> void:
	pass
