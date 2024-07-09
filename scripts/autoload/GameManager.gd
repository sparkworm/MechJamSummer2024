#GameManager
#Autoload
extends Node

#TODO: figure out our states
enum GameState {
	Load = 0,
	Intro = 1,
	Game = 2,
}

@export var _load_scene: PackedScene
@export var _intro_scene: PackedScene
@export var _game_scene: PackedScene
@export var _levels: Array[PackedScene] = []

var _game_state: GameState = GameState.Load
var _current_scene: Node

var _current_level_index: int = -1
var _current_level_scene: Level = null
var current_level_scene: Level:
	get:
		return _current_level_scene

func _ready() -> void:
	#should start in loading scene via project settings
	pass

func change_state(state: GameState) -> void:
	call_deferred("_change_state_deffered", state)

func _change_state_deffered(state: GameState) -> void:
	_state_clean_up()
	_game_state = state
	_state_initialization()

func _state_clean_up() -> void:
	if(_game_state == GameState.Load):
		pass
	elif(_game_state == GameState.Intro):
		pass
	else: #(_game_state == GameState.Game):
		_current_level_scene.free()
		_current_level_index = -1
		pass

	_current_scene.free()

func _state_initialization() -> void:
	if(_game_state == GameState.Load):
		_current_scene = _load_scene.instantiate()
	elif(_game_state == GameState.Intro):
		_current_scene = _intro_scene.instantiate()
	else:
		_current_scene = _game_scene.instantiate()

	get_tree().root.add_child(_current_scene)
	get_tree().current_scene = _current_scene

func change_level(level_index: int) -> void:
	if(_game_state != GameState.Game):
		print("GameManager: cannot change level while in incorrect GameState")
		return

	if(level_index + 1 > _levels.size()):
		print("GameManager: cannot change level with incorrect Level index")
		return

	var next_level: PackedScene = _levels[level_index]
	call_deferred("_on_change_level_deffered", next_level)
	_current_level_index = level_index

func change_to_next_level() -> void:
	change_level(_current_level_index + 1)

func _on_change_level_deffered(next_level: PackedScene) -> void:
	if(_current_level_scene != null):
		_current_level_scene.free()

	_current_level_scene = next_level.instantiate()
	_current_scene.add_child(_current_level_scene)
	#Change player position and stuff here according to the Level data

func get_current_delta_time() -> float:
	if(Engine.is_in_physics_frame):
		return get_physics_process_delta_time()
	else:
		return get_process_delta_time()

#TODO: Add some tweening logic for cross fading between scenes
