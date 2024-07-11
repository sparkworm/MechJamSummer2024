class_name InteractableSwitch
extends Switch

@onready var _interact_component: InteractComponent = $Components/InteractComponent

func _ready() -> void:
	super()
	_interact_component.connect("interact", activate_switch)
