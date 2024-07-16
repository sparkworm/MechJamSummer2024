class_name PickupDropComponent
extends Node

@export var _random_drop_offset: Vector3 = Vector3.ZERO

@export_group("Random Drop Chance Table")
@export var _random_pickup_drop_table: Array[PackedScene]
@export var _drop_chance: float = 0.10

@export_group("Guaranteed Pickup Drops")
@export var _guaranteed_pickup_drops: Array[PackedScene]


func get_pickup_drops() -> Array[Pickup]:
	var drops: Array[Pickup]
	return drops

func disperse_pickup_drops_at_point(point: Vector3) -> void:
	var drops = _get_all_item_drop_data() as Array[PackedScene]

	if(drops.is_empty()):
		return

	var level = GameManager.current_level_scene as Level
	for drop: PackedScene in drops:
		#var pickup_object = PrefabManager.pickup_object as Pickup
		var pickup_object: Pickup = drop.instantiate() as Pickup
		level.add_child(pickup_object)
		var random_offset: Vector3 = GameUtility.get_random_point_in_radius(_random_drop_offset)
		pickup_object.global_position = point +  random_offset

func _get_all_item_drop_data() -> Array[PackedScene]:
	var drops: Array[PackedScene]
	if(!_guaranteed_pickup_drops.is_empty()):
		drops.append_array(_guaranteed_pickup_drops)
	var rand_drop: PackedScene = _get_random_drop() as PackedScene
	if(rand_drop != null):
		drops.append(rand_drop)
	return drops

func _get_random_drop() -> PackedScene:
	if(_random_pickup_drop_table.is_empty()):
		return null

	var random_value = randf()
	if random_value < _drop_chance:
		var random_index = randi() % _random_pickup_drop_table.size()
		return _random_pickup_drop_table[random_index]

	return null
