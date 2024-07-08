class_name Pickup
extends Unit

#TODO: Pickup homing logic
@export var _item_data: ItemData = null
@export var _homing_speed: float = 2
@export var _homing_duration: float = 2

var _current_homing_target: Body = null
var _current_homing_duration: float = 0

var item_data: ItemData:
	get:
		return _item_data

func insert_item_data(new_item_data):
	_item_data = new_item_data
	#update mesh data and stuff

func _ready() -> void:
	pass # Replace with function body.

func _process(delta: float) -> void:
	pass

func magnet_towards_body(body: Body) -> void:
	pass
