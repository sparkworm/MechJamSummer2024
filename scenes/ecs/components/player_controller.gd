class_name PlayerController
extends CharacterController

@export_group("Keys")
@export var move_up: String = "Up"
@export var move_down: String = "Down"
@export var move_left: String = "Left"
@export var move_right: String = "Right"
@export var fire: String = "Fire"
@export_group("")

func _ready() -> void:
	print("hi")

func _process(_delta: float) -> void:
	move.emit(_calculate_movement_direction())

	if Input.is_action_just_pressed("Fire"):
		activate_arm.emit(0)
	if Input.is_action_just_released("Fire"):
		deactivate_arm.emit(0)

## [br] Calculates the movement direction for the player using player input
func _calculate_movement_direction() -> Vector2:
	var x: float = Input.get_axis(move_left, move_right)
	var z: float = Input.get_axis(move_up, move_down)
	return Vector2(x,z).normalized()
