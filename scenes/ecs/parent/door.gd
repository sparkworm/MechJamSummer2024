class_name Door
extends Unit

@onready var _trigger_component: TriggerComponent = $Components/TriggerComponent

# Called when the node enters the scene tree for the first time.
func _ready():
	_trigger_component.connect("trigger", _open)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _open():
	queue_free()
	pass
