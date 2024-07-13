#MouseUtility
#Autoload
extends Node

var ray_distance: float = 1e6

func get_mouse_pos_3d() -> Vector3:
	var camera: Camera3D = CameraManager.camera
	var mouse_pos: Vector2 = get_viewport().get_mouse_position()
	var from: Vector3 = camera.project_ray_origin(mouse_pos)
	var to: Vector3 = from + camera.project_ray_normal(mouse_pos) * ray_distance
	var plane: Plane = Plane(Vector3.UP, 0)
	var intersection_point: Vector3 = plane.intersects_ray(from, to)
	intersection_point.y = 0

	if intersection_point:
		return intersection_point
	else:
		return Vector3.ZERO

"""
func get_mouse_pos_3d(ray_length:float = 1000) -> Vector3:
	var mouse_pos: Vector2 = get_viewport().get_mouse_position()
	var camera_3d: Camera3D = CameraManager.camera

	var from = camera_3d.project_ray_origin(mouse_pos)
	var direction = camera_3d.project_ray_normal(mouse_pos)
	var to = from + direction * ray_length

	var query_params = PhysicsRayQueryParameters3D.new()
	query_params.from = from
	query_params.to = to

	var space_state = camera_3d.get_world_3d().direct_space_state
	var result = space_state.intersect_ray(query_params)
	if result and result.collider:
		var intersection_point = result.position
		return intersection_point

	else: return Vector3.ZERO
"""
