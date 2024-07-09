#PlayerManager
#Autoload
extends Node

#Usually I keep track the player references through other means, but this should be fine

@onready var _player: PlayerCharacter = $Player
var player: PlayerCharacter:
	get:
		return _player

func change_player_global_position(position: Vector3) -> void:
	_player.global_position = position

func change_player_transform(transform: Transform3D) -> void:
	_player.transform = transform
