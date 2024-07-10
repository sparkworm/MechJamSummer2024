class_name TriggerComponent
extends Node

## emitted when component is triggered
signal trigger

func emit_trigger() -> void:
	trigger.emit()
