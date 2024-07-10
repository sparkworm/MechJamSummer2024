#Abstract
class_name Switch
extends Unit

enum SwitchModeType
{
	OneShot,
	Constant
}

@export var _switch_trigger: TriggerComponent
var switch_trigger: TriggerComponent:
	get:
		return _switch_trigger
	set(value):
		_switch_trigger = value

@export var _switch_mode_type: SwitchModeType = SwitchModeType.OneShot
@export var _switch_cooldown: float = 5
var _current_cooldown: float = 0
var _is_active: bool = false

func activate_switch() -> void:
	_is_active = true

func deactivate_switch() -> void:
	_is_active = false

func _process(delta: float) -> void:
	if(!_is_active):
		return

	var currentTime: float = Time.get_unix_time_from_system()
	if(_current_cooldown > currentTime):
		return

	else: _current_cooldown = _switch_cooldown + currentTime

	if(_switch_mode_type == SwitchModeType.OneShot):
		_switch_trigger.emit_trigger()
		_is_active = false

	else: #_switch_type == SwitchType.Constant
		_switch_trigger.emit_trigger()

func _physics_process(delta: float) -> void:
	pass
