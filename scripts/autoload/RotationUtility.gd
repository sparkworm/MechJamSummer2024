#RotationUtility
#Autoload
extends Node

func smooth_look_at(node3D: Node3D, target_position: Vector3, rot_speed: float) -> void:
	var direction: Vector3 = (target_position - node3D.global_transform.origin).normalized()
	direction.y = 0

	var current_rotation: Quaternion = node3D.global_transform.basis.get_rotation_quaternion()
	var target_rotation: Quaternion = Quaternion(Vector3.FORWARD, direction).normalized()

	var delta_time: float = GameManager.get_current_delta_time()
	#print(delta_time)
	var new_rotation: Quaternion = current_rotation.slerp(target_rotation, rot_speed * delta_time)
	node3D.global_transform.basis = Basis(new_rotation)
