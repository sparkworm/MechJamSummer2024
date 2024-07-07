#MouseUtility
#Autoload
extends Node

func get_mouse_pos_3d(ray_length:float = 1000) -> Vector3:
	var mouse_pos: Vector2 = get_viewport().get_mouse_position()
	var from: Vector3 = get_viewport().get_camera_3d().project_ray_origin(mouse_pos)
	var to: Vector3 = from + get_viewport().get_camera_3d().project_ray_normal(mouse_pos) * ray_length
	return Plane(Vector3.UP, 0).intersects_ray(from, to)
