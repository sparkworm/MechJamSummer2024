class_name HealthComponent
extends Node

## emitted when health is 0 or below
signal killed

## emitted when target is hit
signal hit(source: Node3D, current_health: int)

## the maximum amount of health possible, also the starting health
@export var max_health: int
## the actual amount of health
var health: int

@export var _invincibility_time: float = 0
var _invincibility_timer: float= 0

func _ready() -> void:
	# set the actual health to the max_health
	refresh()

## subtracts a specified number from health, and if health reaches 0, killed is
## emitted
func damage(source: Node3D, amnt: int) -> void:
	if(_invincibility_timer > Time.get_unix_time_from_system()):
		return
	else:
		_invincibility_timer = Time.get_unix_time_from_system() + _invincibility_time
	health -= amnt
	hit.emit(source, health)
	if health <= 0:
		killed.emit()

## adds a specified amount of health, but not exceeding max_health
func heal(source: Node3D, amnt: int) -> void:
	health = min(max_health, health+amnt)
	hit.emit(source, health)

func refresh():
	heal(null, max_health)
