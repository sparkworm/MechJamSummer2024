class_name HealthComponent
extends Node

## emitted when health is 0 or below
signal killed

## emitted when target is hit
signal hit(source: Node3D)

## the maximum amount of health possible, also the starting health
@export var max_health: int
## the actual amount of health
var health: int

func on_ready() -> void:
	# set the actual health to the max_health
	health = max_health

## subtracts a specified number from health, and if health reaches 0, killed is
## emitted
func damage(source: Node3D, amnt: int) -> void:
	health -= amnt
	hit.emit(source)
	if health <= 0:
		killed.emit()

## adds a specified amount of health, but not exceeding max_health
func heal(amnt: int) -> void:
	health = min(max_health, health+amnt)
