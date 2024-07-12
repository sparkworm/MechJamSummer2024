class_name Level
extends Node3D

#Each game level will incoporate an instance of Level which specifies spawn points and other level specifics

@export var _level_start_point: MeshInstance3D = null
@export var _level_exit_point: StaticBody3D = null
@export var _level_patrol_routes: Array[PatrolRoute]

func get_random_level_patrol_route() -> PatrolRoute:
	if _level_patrol_routes.size() == 0:
		return null
	var random_index = randi() % _level_patrol_routes.size()
	print(_level_patrol_routes[random_index])
	return _level_patrol_routes[random_index]

func get_level_start_position() -> Vector3:
	return _level_start_point.global_position

func _ready() -> void:
	pass
