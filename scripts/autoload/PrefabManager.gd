#PrefabManager
#Autoload
extends Node

@export var _pickup_prefab: PackedScene = null
var pickup_object: Pickup:
	get:
		return _instantiate(_pickup_prefab) as Pickup

func _instantiate(scene: PackedScene) -> Node:
	var new_object: Node = scene.instantiate()
	return new_object
