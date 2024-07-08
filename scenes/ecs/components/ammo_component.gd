class_name AmmoComponent
extends Node

@export var _max_light_ammo: int = 500
var _light_ammo: int = 0;
var light_ammo: int:
	get:
		return _light_ammo
	set(value):
		_light_ammo = value
		if(_light_ammo > _max_light_ammo):
			_light_ammo = _max_light_ammo

@export var _max_heavy_ammo: int = 250
var _heavy_ammo: int = 0;
var heavy_ammo: int:
	get:
		return _heavy_ammo
	set(value):
		_heavy_ammo = value
		if(_heavy_ammo > _max_heavy_ammo):
			_heavy_ammo = _max_heavy_ammo

@export var _max_missiles: int = 50
var _missiles: int = 0;
var missiles: int:
	get:
		return _missiles
	set(value):
		_missiles = value
		if(_missiles > _max_missiles):
			_missiles = _max_missiles

func _ready() -> void:
	#Maybe instantiate some default ammo values
	pass

var ammo_type_map: Dictionary = {
	AmmoData.AmmoType.LightAmmo: "light_ammo",
	AmmoData.AmmoType.HeavyAmmo: "heavy_ammo",
	AmmoData.AmmoType.Missiles: "missiles",
}

func add_ammo(ammo: AmmoData) -> void:
	var property_name: String = ammo_type_map[ammo.ammo_type]
	self[property_name] += ammo.ammo_amount
	print("Ammo type: ", property_name)
	print("Ammo amount: ", self[property_name])
