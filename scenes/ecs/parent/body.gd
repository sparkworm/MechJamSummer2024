#Abstract class for objects with CharacterBody components
class_name Body
extends Unit

@export_subgroup("Body Properties")
@export var _movement_speed: float = 5.0
@export var _rotation_speed: float = 2

@onready var _character_body: CharacterBody3D = $"."
var _velocity: Vector3 = Vector3.ZERO
var _movement_delta: float


#Virtual
func _ready() -> void:
	pass

#Virtual
func _physics_process(_delta: float) -> void:
	pass

#Virtual
func _is_hit(source: Node3D) -> void:
	pass

#Virtual
func _die() -> void:
	pass
