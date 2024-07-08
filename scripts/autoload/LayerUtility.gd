#LayerUtility
#Autoload
extends Node

#Layers and Behaviours
enum Layer {
	None = 0, # No layers defined
	Terrain = 1 << 0, #Static navigational zones
	Bounds = 1 << 1, #Static field bounds (OOB)
	Platform = 1 << 2, #Static and dynamic navigational zones
	Wall = 1 << 3, #Blocks characters, Blocks vision, blocks projectiles
	Divider = 1 << 4, #Blocks characters, Does not block vision, does not block projectiles
	Permeable = 1 << 5, #Blocks characters, Blocks vision, does not block projectiles
	Transparent = 1 << 6, #Blocks characters, Does not block vision, blocks projectiles
	Shroud = 1 << 7, #Does not block characters, Blocks vision, does not block projectiles
	Barrier = 1 << 8, #Does not block characters, Does not block vision, blocks projectiles
	Impenetrable = 1 << 9, #Does not block characters, Blocks vision, blocks projectiles
	Accessible = 1 << 10, #Does not block characters, Does not block vision, does not block projectiles
	Prop = 1 << 11, #Doodads and interactables, blocks everything by default. Can be used for dynamic collisional objects
	Player = 1 << 12, #Player character(s)
	Enemy = 1 << 13, #Enemy character(s)
	Neutral = 1 << 14, #Neutral character(s)
	Ability = 1 << 15, #For ability to ability detection
	LineOfSight = 1 << 16, #Useful for discreet raycasting queries
	Hidden = 1 << 17, #Removed from detecting
}

var bit_to_layer_name_dict: Dictionary = {
	Layer.None: "None",
	Layer.Terrain: "Terrain",
	Layer.Bounds: "Bounds",
	Layer.Platform: "Platform",
	Layer.Wall: "Wall",
	Layer.Divider: "Divider",
	Layer.Permeable: "Permeable",
	Layer.Transparent: "Transparent",
	Layer.Shroud: "Shroud",
	Layer.Barrier: "Barrier",
	Layer.Impenetrable: "Impenetrable",
	Layer.Accessible: "Accessible",
	Layer.Prop: "Prop",
	Layer.Player: "Player",
	Layer.Enemy: "Enemy",
	Layer.Neutral: "Neutral",
	Layer.Ability: "Ability",
	Layer.LineOfSight: "LineOfSight",
	Layer.Hidden: "Hidden"
}

var layer_name_to_bit_dict: Dictionary = {}

func _ready() -> void:
	for key: Layer in bit_to_layer_name_dict:
		var value: String = bit_to_layer_name_dict[key]
		layer_name_to_bit_dict[value] = key

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
	if bit_to_layer_name_dict.has(bit):
		return bit_to_layer_name_dict[bit]
	else:
		return "None"

#Returns the bit from a layer
func get_bit_from_layer_name(layer_name: String) -> int:
	if layer_name_to_bit_dict.has(layer_name):
		return layer_name_to_bit_dict[layer_name]
	else:
		return 0

func get_bitmask_from_layer_names(layer_names_to_combine: Array) -> int:
	var combined_bitmask: int = 0
	for layer_name: String in layer_names_to_combine:
		if layer_name_to_bit_dict.has(layer_name):
			combined_bitmask |= layer_name_to_bit_dict.get(layer_name)
	return combined_bitmask

func get_bitmask_from_bits(bits_to_combine: Array) -> int:
	var combined_bitmask: int = 0
	for bit: int in bits_to_combine:
		#if bit_to_layer_name_dict.has(bit):
		combined_bitmask |= bit
	return combined_bitmask

#If all bits are set return true, else return false
func check_all_bits_from_bitmask(bits_to_compare: int, bitmask_to_check: int) -> bool:
	return (bits_to_compare & bitmask_to_check) == bitmask_to_check

#If any bits are set return true, else return false
func check_any_bits_from_bitmask(bits_to_compare: int, bitmask_to_check: int) -> bool:
	return (bits_to_compare & bitmask_to_check) != 0
