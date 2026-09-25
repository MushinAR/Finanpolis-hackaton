extends ToggleState
## Apagado.


func enter(_msg: Dictionary = {}) -> void:
	prop.apply_state(false)
