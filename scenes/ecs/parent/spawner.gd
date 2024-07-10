extends Node3D

@onready var _spawn_point: Node3D = $SpawnPoint
@onready var _trigger_component: Node3D = $Components/TriggerComponent

@export var _scene_to_spawn: PackedScene = null
@export var _spawn_cooldown: float = 10
@export var _random_range_spawn_offset: Vector3 = Vector3.ZERO
var _current_spawn_cooldown: float = 0

func _ready() -> void:
	_trigger_component.connect("trigger", _trigger_spawn)
	pass

func _trigger_spawn() -> void:
	var currentTime: float = Time.get_unix_time_from_system()
	if(_current_spawn_cooldown > currentTime):
		return

	else: _current_spawn_cooldown = _spawn_cooldown + currentTime

	if(GameManager.current_level_scene != null):
		var new_object: Node = _scene_to_spawn.instantiate()
		var currentLevel: Level = GameManager.current_level_scene as Level
		currentLevel.add_child(new_object)

		if(new_object is Node3D):
			var new_node_3D: Node3D = new_object as Node3D
			var random_offset: Vector3 = GameUtility.get_random_point_in_radius(_random_range_spawn_offset)
			var new_spawn_position: Vector3 = _spawn_point.global_position + random_offset
			new_node_3D.global_position = new_spawn_position
