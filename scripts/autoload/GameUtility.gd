#GameUtility
#Autoload
extends Node

func get_current_delta_time() -> float:
	if(Engine.is_in_physics_frame):
		return get_physics_process_delta_time()
	else:
		return get_process_delta_time()

func get_random_point_in_radius(radius: Vector3) -> Vector3:
	return Vector3(
			randf_range(-radius.x, radius.x),
			randf_range(-radius.y, radius.y),
			randf_range(-radius.z, radius.z))

func global_to_iso_dir(global_dir: Vector3) -> Vector3:
	var iso_x = Vector3(1, 0, -1).normalized()
	var iso_y = Vector3(0, 1, 0)
	var iso_z = Vector3(1, 0, 1).normalized()

	var iso_dir = Vector3(
		global_dir.dot(iso_x),
		global_dir.dot(iso_y),
		global_dir.dot(iso_z)
	)

	return iso_dir
