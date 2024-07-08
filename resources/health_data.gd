class_name HealthData
extends PickupData

func get_pickup_type() -> PickupType:
	return PickupType.Health

@export var _health_amount: float = 100
var health_amount: float:
	get:
		return _health_amount
