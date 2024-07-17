#Abstract class for objects with CharacterBody components
class_name Body
extends CharacterBody3D

@export_subgroup("Body Properties")
@export var _movement_speed: float = 5.0
@export var _rotation_speed: float = 2

@onready var _primary_collider: CollisionShape3D = $PrimaryCollider
var _velocity: Vector3 = Vector3.ZERO
var _movement_delta: float

var primary_collider: CollisionShape3D:
	get:
		return _primary_collider

#Virtual
func _ready() -> void:
	pass

#Virtual
func _physics_process(_delta: float) -> void:
	pass

#Virtual
func _is_hit(source: Node3D, current_health: int):
	pass

#Virtual
func _die() -> void:
	pass
