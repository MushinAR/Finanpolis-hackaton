extends ComputerState
## Alguien la está usando: pantalla prendida y ruido de teclado.


func enter(_msg: Dictionary = {}) -> void:
	computer.set_screen(computer.screen_on)
	Sfx.play(&"typing")


func exit() -> void:
	Sfx.stop(&"typing")
