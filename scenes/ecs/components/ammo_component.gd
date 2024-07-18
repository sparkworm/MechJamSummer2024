class_name AmmoComponent
extends Node

@export var _ammo_UI: PlayerAmmoUI = null

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
		if(_ammo_UI != null):
			_ammo_UI.change_heavy_ammo(_heavy_ammo)

@export var _max_missiles: int = 50
var _missiles: int = 0;
var missiles: int:
	get:
		return _missiles
	set(value):
		_missiles = value
		if(_missiles > _max_missiles):
			_missiles = _max_missiles

@export var _max_energy: float = 100
var _energy: float = 0;
var energy: float:
	get:
		return _energy
	set(value):
		_energy = value
		if(_energy > _max_energy):
			_energy = _max_energy
		if(_ammo_UI != null):
			_ammo_UI.change_energy(_energy)

func _ready() -> void:
	energy = _max_energy
	heavy_ammo = _max_heavy_ammo

var ammo_type_map: Dictionary = {
	AmmoData.AmmoType.HeavyAmmo: "heavy_ammo",
	AmmoData.AmmoType.Missiles: "missiles",
	AmmoData.AmmoType.Energy: "energy",
}

func add_ammo(ammo: AmmoData) -> void:
	var property_name: String = ammo_type_map[ammo.ammo_type]
	self[property_name] += ammo.ammo_amount
	#print("Ammo type: ", property_name)
	#print("Ammo amount: ", self[property_name])

func refresh():
	energy = _max_energy
	heavy_ammo = _max_heavy_ammo
