extends Node
## Efectos de sonido del juego. Es un autoload para que un sonido no se corte
## cuando cambia la habitación (ej: la puerta). Uso: Sfx.play(&"pickup").

const SOUNDS: Dictionary = {
	# Se usa tanto al agarrar como al soltar.
	&"pickup": preload("res://Assets/audio/sfx/pickup.mp3"),
	&"door_open": preload("res://Assets/audio/sfx/door_open.mp3"),
	&"typing": preload("res://Assets/audio/sfx/typing.mp3"),
}
## Los que se repiten hasta que alguien los corta con stop().
const LOOPING: Array[StringName] = [&"typing"]
## Volumen de cada sonido en dB (0 = como viene el archivo). Los que no están acá van a 0.
const VOLUME_DB: Dictionary = {
	&"door_open": -6.0,
}

var _players: Dictionary = {}


func _ready() -> void:
	for sound: StringName in SOUNDS:
		var stream: AudioStreamMP3 = SOUNDS[sound]
		stream.loop = sound in LOOPING
		var player := AudioStreamPlayer.new()
		player.stream = stream
		player.volume_db = VOLUME_DB.get(sound, 0.0)
		add_child(player)
		_players[sound] = player


func play(sound: StringName) -> void:
	_players[sound].play()


func stop(sound: StringName) -> void:
	_players[sound].stop()
