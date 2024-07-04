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

var _game_state: GameState = GameState.Load
var _scene_paths: = {}
var _current_scene: Node

func _ready() -> void:
	_scene_paths[GameState.Load] = _load_scene
	_scene_paths[GameState.Intro] = _intro_scene
	_scene_paths[GameState.Game] = _game_scene

func change_state(state: GameState) -> void:
	call_deferred("_change_state", state)

func _change_state(state: GameState) -> void:
	_state_clean_up()
	_game_state = state
	_state_initialization()

func _state_clean_up() -> void:
	if(_game_state == GameState.Load):
		pass
	elif(_game_state == GameState.Intro):
		pass
	else: #(_game_state == GameState.Game):
		pass

	_current_scene.free()

func _state_initialization() -> void:
	if(_game_state == GameState.Load):
		pass
	elif(_game_state == GameState.Intro):
		pass
	else: #(_game_state == GameState.Game):
		pass

	_current_scene = _scene_paths[_game_state].instantiate()
	get_tree().root.add_child(_current_scene)
	get_tree().current_scene = _current_scene

#TODO: Add some tweening logic for cross fading between scenes
