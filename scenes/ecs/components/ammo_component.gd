class_name AmmoComponent
extends Node

var _current_light_ammo: float = 0;
var _current_heavy_ammo: float = 0;
var _current_missiles: float = 0;

var ammo_type_map: Dictionary = {
	AmmoData.AmmoType.LightAmmo: "_current_light_ammo",
	AmmoData.AmmoType.HeavyAmmo: "_current_heavy_ammo",
	AmmoData.AmmoType.Missiles: "_current_missiles",
}

func add_ammo(ammo: AmmoData) -> void:
	ammo_type_map[ammo.ammo_type] += ammo.ammo_amount
