class_name Trap
extends Unit

@onready var _fire_point: Node3D = $FirePoint
@onready var _trigger_component: TriggerComponent = $Components/TriggerComponent

func _ready() -> void:
	_trigger_component.connect("trigger", trigger_trap)
	pass

func trigger_trap() -> void:
	pass

