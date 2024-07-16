class_name AttackComponent
extends Node

#TODO: Attack implementations (Projectile/Attack, Speed, Ammo, ect)
#Perhaps we should abstract this into melee attacks and projectile attack type classes

@export var _primary_attack_scene: PackedScene
var _primary_attack_current_cooldown: float = 0
'''
@export var controller: CharacterController

@export var character: Character

func _ready() -> void:
	print(controller)
	controller.activate_arm.connect(Callable(self, "activate_arm"))
	controller.deactivate_arm.connect(Callable(self, "deactivate_arm"))

## The function to use a specific arm.  This will cause any and all weapons
## held by said arm to fire.
func activate_arm(arm_idx: int) -> void:
	# iterate through every child of the arm
	for weapon: Weapon in character.arms[arm_idx].get_children():
		weapon.fire_pressed()

func deactivate_arm(arm_idx: int) -> void:
	# iterate through every child of the arm, turning it off
	for weapon: Weapon in character.arms[arm_idx].get_children():
		weapon.fire_released()
'''

