class_name Pickup
extends Unit

#TODO: Pickup homing logic
@export var _pickup_data: PickupData = null
@export var _obtain_distance: float = 1
@export var _attract_speed: float = 2
#Do we want a duration?
@export var _attract_duration: float = 2

var _current_attract_target: Node3D = null
var _current_attract_duration: float = 0

var pickup_data: PickupData:
	get:
		return _pickup_data
	set(value):
		_pickup_data = value
		#update mesh data and stuff

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	_current_attract_duration -= delta
	if(_current_attract_duration > 0 && _current_attract_target != null):
		_attract_towards_target(_current_attract_target)

func _attract_towards_target(node: Node3D) -> void:
	TransformUtility.move_transform_towards_point(self, _current_attract_target.global_position, _attract_speed)

func assign_attract_target(node: Node3D) -> void:
	if(node != null):
		_current_attract_target = node
		_current_attract_duration = _attract_duration

func obtain_pickup_data_and_expire() -> PickupData:
	_expire_pickup()
	return pickup_data

func _expire_pickup() -> void:
	queue_free()
