class_name AmmoData
extends ItemData

enum AmmoType
{
	Light,
	Heavy,
}

@export var _ammo_type: AmmoType = AmmoType.Light
var ammo_type: AmmoType:
	get:
		return ammo_type

@export var _ammo_amount: float = 100
var ammo_ammount: float:
	get:
		return _ammo_amount
