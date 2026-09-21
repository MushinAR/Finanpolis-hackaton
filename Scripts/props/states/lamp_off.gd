extends LampState
## Apagada.


func enter(_msg: Dictionary = {}) -> void:
	lamp.set_light(false)
