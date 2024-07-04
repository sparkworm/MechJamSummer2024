#AudioManager
#Autoload
extends Node

#Music
@export var _music_1: AudioStreamPlayer

#SFX
@export var _hit1: AudioStreamPlayer
@export var _hit2: AudioStreamPlayer

#Property Getters would allow for additional logic if needed
var music_1: AudioStreamPlayer:
	get:
		return _music_1

var hit_1: AudioStreamPlayer:
	get:
		return _hit1

var hit_2: AudioStreamPlayer:
	get:
		return _hit2

#TODO: Add some tweening logic for cross fading between tracks
