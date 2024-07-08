class_name EnergyComponent
extends Node

@export var max_energy: int
var _energy: int
var energy: int:
	get:
		return _energy
	set(value):
		_energy = value

func on_ready() -> void:
	energy = max_energy
