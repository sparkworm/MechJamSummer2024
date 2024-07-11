#TransformUtility
#Autoload
extends Node

func smooth_look_at(node3D: Node3D, target_position: Vector3, rot_speed: float) -> void:
	var direction: Vector3 = (target_position - node3D.global_transform.origin).normalized()
	direction.y = 0

	var current_rotation: Quaternion = node3D.global_transform.basis.get_rotation_quaternion()
	var target_rotation: Quaternion = Quaternion(Vector3.FORWARD, direction).normalized()

	var delta_time: float = GameUtility.get_current_delta_time()

	var new_rotation: Quaternion = current_rotation.slerp(target_rotation, rot_speed * delta_time)
	node3D.global_transform.basis = Basis(new_rotation)
	return

func point_to_transform_raycast(point_start: Vector3, node_target: Node3D, bitmask: int) -> Dictionary:
	var space_state: PhysicsDirectSpaceState3D = node_target.get_world_3d().direct_space_state
	var ray_query: PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.create(
		point_start, node_target.global_position)
	ray_query.collision_mask = bitmask
	return space_state.intersect_ray(ray_query)


func lerp_transform_towards_point(node3D: Node3D, point: Vector3, speed: float) -> void:
	var delta: float = GameUtility.get_current_delta_time()
	node3D.global_transform.origin = node3D.global_transform.origin.lerp(point, speed * delta)
	return

#just testing different lerpings
func move_transform_towards_point(node3D: Node3D, point: Vector3, speed: float) -> void:
	var direction: Vector3 = (point - node3D.global_transform.origin).normalized()
	var distance_to_target: float = (point - node3D.global_transform.origin).length()

	if distance_to_target > 0.001:
		var distance_to_move: float = min(speed * GameUtility.get_current_delta_time(), distance_to_target)
		node3D.global_transform.origin += direction * distance_to_move

