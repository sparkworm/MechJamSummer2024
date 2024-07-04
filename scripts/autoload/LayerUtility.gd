#LayerUtility
#Autoload
extends Node

#TODO: Figure out what layers we're using
enum Layer {
	None = 0,
	Terrain = 1 << 0,
	Player = 1 << 1,
	Enemy = 1 << 2,
	Switch = 1 << 3,
}

var bit_to_layer_name = {
	Layer.None: "None",
	Layer.Terrain: "Terrain",
	Layer.Player: "Player",
	Layer.Enemy: "Enemy",
	Layer.Switch: "Switch",
}

var layer_name_to_bit = {}

func _ready() -> void:
	for key: Layer in bit_to_layer_name:
		var value: String = bit_to_layer_name[key]
		layer_name_to_bit[value] = key

	#debug
	"""
	print("LayerUtility")

	print("\nget_layer_name_from_bit")
	print("Layer 0 is: ", get_layer_name_from_bit(0))
	print("Layer 1 is: ", get_layer_name_from_bit(1 << 0))
	print("Layer 2 is: ", get_layer_name_from_bit(1 << 1))
	print("Layer 3 is: ", get_layer_name_from_bit(1 << 2))
	print("Layer 4 is: ", get_layer_name_from_bit(1 << 3))

	print("\nget_bit_from_layer_name")
	print("None is: ", get_bit_from_layer_name("None"))
	print("Terrain is: ", get_bit_from_layer_name("Terrain"))
	print("Player is: ", get_bit_from_layer_name("Player"))
	print("Player is: ", get_bit_from_layer_name("Enemy"))
	print("Switch is: ", get_bit_from_layer_name("Switch"))

	print("\nget_bitmask_from_layer_names")
	print("Player + Terrain is: ", get_bitmask_from_layer_names(["Player", "Terrain"]))
	print("Switch + Enemy is: ", get_bitmask_from_layer_names(["Switch", "Enemy"]))

	var bits1 = get_bitmask_from_layer_names(["Player", "Terrain"])
	var bits2 = get_bitmask_from_layer_names(["Player", "Switch"])
	var bits3 = get_bit_from_layer_name("Switch")
	var bits4 = get_bit_from_layer_name("Player")

	print("\nbitmask comparison")
	print("Player + Terrain == Player + Terrain: ", check_all_bits_from_bitmask(bits1, bits1))
	print("Player + Switch == Player + Terrain: ", check_all_bits_from_bitmask(bits1, bits2))

	print("Player + Terrain has a Player bit: ", check_any_bits_from_bitmask(bits1, bits4))
	print("Player + Terrain has a Switch bit: ", check_any_bits_from_bitmask(bits1, bits3))
	print("Player + Terrain has a Player bit from Player + Switch: ", check_any_bits_from_bitmask(bits1, bits2))
	"""

#Returns the layer from a single set bit
func get_layer_name_from_bit(bit: int) -> String:
	if bit_to_layer_name.has(bit):
		return bit_to_layer_name[bit]
	else:
		return "None"

#Returns the bit from a layer
func get_bit_from_layer_name(layer_name: String) -> int:
	if layer_name_to_bit.has(layer_name):
		return layer_name_to_bit[layer_name]
	else:
		return 0

func get_bitmask_from_layer_names(layer_names_to_combine: Array) -> int:
	var combined_bitmask: int = 0
	for layer_name: String in layer_names_to_combine:
		if layer_name_to_bit.has(layer_name):
			combined_bitmask |= layer_name_to_bit.get(layer_name)
	return combined_bitmask

#If all bits are set return true, else return false
func check_all_bits_from_bitmask(bits_to_compare: int, bitmask_to_check: int) -> bool:
	return (bits_to_compare & bitmask_to_check) == bitmask_to_check

#If any bits are set return true, else return false
func check_any_bits_from_bitmask(bits_to_compare: int, bitmask_to_check: int) -> bool:
	return (bits_to_compare & bitmask_to_check) != 0
