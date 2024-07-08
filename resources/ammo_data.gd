class_name SupplyData
extends PickupData

#Supplies are PickUp objects which are numerous and used in conjunction with other objects such as weapons
enum SupplyType
{
	Energy,
	Health,
	LightAmmo,
	HeavyAmmo,
	Missiles,
}

@export var _supply_type: SupplyType = SupplyType.Energy
var supply_type: SupplyType:
	get:
		return _supply_type

@export var _supply_amount: float = 100
var supply_ammount: float:
	get:
		return _supply_amount
