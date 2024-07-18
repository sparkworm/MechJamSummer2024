#Abstract
class_name Switch
extends Unit

enum SwitchModeType
{
	OneShot,
	Constant
}

@export var _trigger_target: TriggerComponent
var trigger_target: TriggerComponent:
	get:
		return _trigger_target
	set(value):
		_trigger_target = value

@export var _active_switch_mesh: MeshInstance3D = null
@export var _deactive_switch_mesh: MeshInstance3D = null
@export var _is_active: bool = false
@export var _switch_mode_type: SwitchModeType = SwitchModeType.OneShot
@export var _switch_cooldown: float = 5
@export var _switch_sfx: EnumUtility.AudioClips = EnumUtility.AudioClips.ENEMY_HIT
var _current_cooldown: float = 0

func _ready():
	if(_is_active):
		activate_switch()
	else:
		deactivate_switch()

func activate_switch() -> void:
	_active_switch_mesh.visible = true
	_deactive_switch_mesh.visible = false
	_is_active = true

func deactivate_switch() -> void:
	_is_active = false
	_active_switch_mesh.visible = false
	_deactive_switch_mesh.visible = true

func _process(delta: float) -> void:
	if(!_is_active
	|| _trigger_target == null
	|| !is_instance_valid(_trigger_target)):
		return

	var currentTime: float = Time.get_unix_time_from_system()
	if(_current_cooldown > currentTime):
		return

	else: _current_cooldown = _switch_cooldown + currentTime

	if(_switch_mode_type == SwitchModeType.OneShot):
		_trigger_target.emit_trigger()
		_is_active = false

	else: #_switch_type == SwitchType.Constant
		_trigger_target.emit_trigger()

func _physics_process(delta: float) -> void:
	pass
