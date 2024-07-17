class_name EnergyData
extends PickupData

func get_pickup_type() -> PickupType:
	return PickupType.Ammo

@export var _energy_amount: float = 100
var energy_amount: float:
	get:
		return _energy_amount
