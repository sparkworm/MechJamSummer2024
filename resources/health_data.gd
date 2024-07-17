class_name HealthData
extends PickupData

func get_pickup_type() -> PickupType:
	return PickupType.Health

@export var _health_amount: int = 1
var health_amount: int:
	get:
		return _health_amount
