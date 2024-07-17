class_name PlayerAmmoUI
extends Control

var _max_energy: float =  100
@export var energy: ProgressBar = null

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func change_energy(amount: float):
	energy.value = amount
