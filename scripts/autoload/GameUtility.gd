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
