#PlayerManager
#Autoload
extends Node

#Usually I keep track the player references through other means, but this should be fine

@export var _player_scene: PackedScene = null
var _player: PlayerCharacter = null
var player: PlayerCharacter:
	get:
		return _player

func _ready() -> void:
	instantiate_new_player_character()
	pass

func instantiate_new_player_character() -> PlayerCharacter:
	if(_player != null):
		_player.queue_free()

	var player_character: PlayerCharacter = _player_scene.instantiate() as PlayerCharacter
	add_child(player_character)
	_player = player_character
	return _player

func change_player_global_position(position: Vector3) -> void:
	_player.global_position = position

func change_player_transform(transform: Transform3D) -> void:
	_player.transform = transform

