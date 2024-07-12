class_name PatrolRoute
extends Node

@export var _patrol_points: Array[PatrolPoint]

func _ready() -> void:
	if(_patrol_points.size() == 0):
		print("PatrolRoute: no patrol points were found")
		_patrol_points.append(PatrolPoint.new())

func get_next_point_from_route(current_point: PatrolPoint) -> PatrolPoint:
	if(current_point == null):
		print("PatrolRoute: current patrol point is null")
		return null

	var index = _patrol_points.find(current_point)

	if index == -1:
		print("PatrolRoute: current patrol point is not part of patrol route")
		return null

	var next_index = (index + 1) % _patrol_points.size()
	return _patrol_points[next_index]

func get_first_patrol_point_from_route() -> PatrolPoint:
	return _patrol_points[0]

func get_random_patrol_point() -> PatrolPoint:
	var random_index = randi() % _patrol_points.size()
	return _patrol_points[random_index]

func get_closest_patrol_point_from_point(point: Node3D) -> PatrolPoint:
	var closest_point = _patrol_points[0]
	var closest_distance = point.global_transform.origin.distance_to(closest_point.global_transform.origin)

	for patrol_point in _patrol_points:
		var distance = point.global_transform.origin.distance_to(patrol_point.global_transform.origin)
		if distance < closest_distance:
			closest_point = patrol_point
			closest_distance = distance

	return closest_point
