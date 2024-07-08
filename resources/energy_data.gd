class_name EnergyData
extends PickupData

func get_pickup_type() -> PickupType:
	return PickupType.Energy

@export var _energy_amount: int = 100
var energy_amount: int:
	get:
		return _energy_amount
