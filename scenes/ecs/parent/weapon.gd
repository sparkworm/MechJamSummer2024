## Weapon is a parent class to contain most of the functionality for 
## RangedWeapon and MeleeWeapon.
class_name Weapon
extends Node3D

## The timer responsible for the cooldown between attacks.
@onready var cooldown_timer = $CooldownTimer
## The audio player that will play the fire sound.
@onready var fire_sfx = $FireSFX

## Signal emitted when the weapon is used.
signal fired
## Signal emitted when the weapon cooldown has ended.
signal cooldown_ended

## function to handle weapon attacking
## [br] Do note that "fire" can mean "swing" for melee weapons.
func fire() -> void:
	if can_weapon_fire():
		fired.emit()
		cooldown_timer.start()
		fire_sfx.play()
		_use_weapon()

## Function to handle SPECIFIC weapon attacks.
## [br] This function is called by fire() and can vary in functionality based 
## on whether the weapon is melee or ranged.
## [br] This function should be overwritten by child classes.
func _use_weapon() -> void:
	pass

## returns whether the weapon can fire or not.
func can_weapon_fire() -> bool:
	return cooldown_timer.is_stopped()

## emits the cooldown_ended signal when the cooldown timer runs out.
func _on_cooldown_timer_timeout():
	cooldown_ended.emit()
