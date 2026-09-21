extends ComputerState
## Apagada: pantalla negra.


func enter(_msg: Dictionary = {}) -> void:
	computer.set_screen(computer.screen_off)
