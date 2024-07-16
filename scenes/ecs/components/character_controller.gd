## This is the class that is responsible for creating a central hub for input
## [br] Input can be from a player (hardware) or from an enemy (pathfinding)
class_name CharacterController
extends Node

## This signal is used to provide the direction that the character should be
## moving from a top down view
signal move (direction: Vector2)
## This signal is used to provide the point at which the character should be
## looking at
signal look_at (direction: Vector3)
## This signal is used fire the weapons on a specific arm.  The arm is
## specified by arm_idx
signal activate_arm (arm_idx: int)
## This signal indicates when the button to fire a weapon has been released
signal deactivate_arm (arm_idx: int)

#signal jump

## This signal is used to take a special action.  The specific action is
## specified by action_num
signal special_action (action_num: int)

