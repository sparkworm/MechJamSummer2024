class_name AmmoData
extends PickupData

enum AmmoType
{
	LightAmmo,
	HeavyAmmo,
	Missiles,
}

func get_pickup_type() -> PickupType:
	return PickupType.Ammo

@export var _ammo_type: AmmoType = AmmoType.LightAmmo
var ammo_type: AmmoType:
	get:
		return _ammo_type

@export var _ammo_amount: float = 100
var ammo_amount: float:
	get:
		return _ammo_amount
