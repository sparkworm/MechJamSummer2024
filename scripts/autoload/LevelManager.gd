#LevelManager
#AutoLoad
extends Node

#Could preload all the scenes and stuff them here at start, otherwise instantiate on scene change

@export var levels: Array[PackedScene] = []
var _current_level_index: int = -1

var _current_level_scene: Level = null
var current_level_scene: Level:
	get:
		return _current_level_scene

func change_to_next_level() -> PackedScene:
	_current_level_index += 1
	var next_level: PackedScene = levels[_current_level_index]
	call_deferred("_on_change_level", next_level)
	return next_level

func _on_change_level(next_level: PackedScene) -> void:
	if(_current_level_scene != null):
		_current_level_scene.queue_free()

	_current_level_scene = next_level.instantiate()
	add_child(_current_level_scene)
	#Change player position and stuff here according to the Level data
