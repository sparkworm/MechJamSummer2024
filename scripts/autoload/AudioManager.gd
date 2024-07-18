#AudioManager
#Autoload
extends Node

#Music
@export var _music_1: AudioStreamPlayer

@export var _dash: AudioStreamPlayer
@export var _enemy_hit: AudioStreamPlayer
@export var _lazer_1: AudioStreamPlayer
@export var _lazer_2: AudioStreamPlayer
@export var _minigun: AudioStreamPlayer
@export var _pickup: AudioStreamPlayer
@export var _player_hit: AudioStreamPlayer
@export var _weapon_obtained: AudioStreamPlayer
@export var _axe: AudioStreamPlayer

var audio_dict = {}

func _ready():
	audio_dict = {
		EnumUtility.AudioClips.DASH: _dash,
		EnumUtility.AudioClips.ENEMY_HIT: _enemy_hit,
		EnumUtility.AudioClips.LAZER_1: _lazer_1,
		EnumUtility.AudioClips.LAZER_2: _lazer_2,
		EnumUtility.AudioClips.MINIGUN: _minigun,
		EnumUtility.AudioClips.PICKUP: _pickup,
		EnumUtility.AudioClips.PLAYER_HIT: _player_hit,
		EnumUtility.AudioClips.WEAPON_OBTAINED: _weapon_obtained,
		EnumUtility.AudioClips.AXE: _axe,
	}

func play_audio(clip: EnumUtility.AudioClips) -> void:
	if audio_dict.has(clip):
		var streamer: AudioStreamPlayer = audio_dict[clip] as AudioStreamPlayer
		streamer.play()
	else:
		print("Clip not found: ", clip)
