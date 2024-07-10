#GameUtility
#Autoload
extends Node

func get_current_delta_time() -> float:
	if(Engine.is_in_physics_frame):
		return get_physics_process_delta_time()
	else:
		return get_process_delta_time()
