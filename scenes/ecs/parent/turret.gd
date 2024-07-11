class_name Turret
extends Unit

@onready var _detection_area: Area3D = $DetectionArea
@onready var _vision_point: Node3D = $VisionPoint
@onready var _fire_point: Node3D = $FirePoint

@export_subgroup("Detection Layers")
@export var _target_layers: Array[LayerUtility.Layer] #Targets the turret will attack
@export var _target_obstructions: Array[LayerUtility.Layer] #Targets that block the turret's vision

var _targets_mask: int = 0
var _target_obstructions_mask: int = 0

func _ready() -> void:
	_targets_mask = LayerUtility.get_bitmask_from_bits(_target_layers)
	_target_obstructions_mask = LayerUtility.get_bitmask_from_bits(_target_obstructions)
	_detection_area.collision_mask = _targets_mask


func _physics_process(delta: float) -> void:

	for node3D: CollisionObject3D in _detection_area.get_overlapping_bodies():
		if (node3D is CollisionObject3D && _on_overlapping_body(node3D)):
			break

func _on_overlapping_body(collision_body: CollisionObject3D) -> bool:
	var collisionLayer: int = collision_body.get_collision_layer()

	if(!LayerUtility.check_any_bits_from_bitmask(collisionLayer, _targets_mask)):
		return false

	var body: Body
	if(collision_body is Body):
		body = collision_body as Body
	else:
		return false

	var collision_shape: CollisionShape3D = body.primary_collider
	if(_is_body_in_line_of_sight(body, collision_shape)):
		#fire at target
		return true
	else:
		return false

func _is_body_in_line_of_sight(collision_body: Body, collider: CollisionShape3D) -> bool:
	var combined_mask: int = LayerUtility.get_bitmask_from_bits([_targets_mask,_target_obstructions_mask])
	var result: Dictionary = TransformUtility.point_to_transform_raycast(_vision_point.global_position, collider, combined_mask)
	if result.size() > 0 && result.collider == collision_body:
		return true
	else:
		return false
