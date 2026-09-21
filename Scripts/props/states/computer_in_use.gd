extends ComputerState
## Alguien la está usando: pantalla prendida.


func enter(_msg: Dictionary = {}) -> void:
	computer.set_screen(computer.screen_on)
