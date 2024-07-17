## class for all characters in-game, which could be a player or enemy
## mech/other vehicle
class_name Character
extends Body

## the name of the character in question
@export var character_name: String

@export var character_controller: CharacterController

## An array of all the arms that the character has.
## [br] An arm is simply a Node3D that is the parent of a weapon, which allows
## for easy animation and containment of the weapon.
## [br] Technically an arm could have multiple weapons, the key is that the
## arms are controlled as units (for instance, lmb could activate the left arm
## which could contain any type of weapons)
@export var arms: Array[Node3D]

func _ready() -> void:
	# connect the character controller's move signal to the function that
	# handles movement input
	character_controller.move.connect(Callable(self, "_handle_movement_input"))

func _handle_movement_input(raw_direction: Vector2) -> void:
	pass
