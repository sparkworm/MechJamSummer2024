class_name Pickup
extends Unit

#TODO: Pickup homing logic
@export var _pickup_data: PickupData = null
@export var _homing_speed: float = 2

#Do we want a duration?
@export var _homing_duration: float = 2

var _current_homing_target: Body = null
var _current_homing_duration: float = 0

var pickup_data: PickupData:
	get:
		return _pickup_data
	set(value):
		_pickup_data = value
		#update mesh data and stuff

func _ready() -> void:
	pass # Replace with function body.

func _process(delta: float) -> void:
	_current_homing_duration -= delta
	if(_current_homing_duration > 0 && _current_homing_target != null):
		_magnet_towards_body(_current_homing_target)
	pass

func _magnet_towards_body(body: Body) -> void:
	TransformUtility.move_transform_towards_point(self, _current_homing_target.global_position, _homing_speed)

func assign_current_target(body: Body):
	if(body != null):
		_current_homing_target = body
		_current_homing_duration = _homing_duration
