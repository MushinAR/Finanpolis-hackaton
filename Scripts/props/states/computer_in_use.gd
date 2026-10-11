extends ComputerState
## Alguien la está usando: pantalla prendida y ruido de teclado.


func enter(_msg: Dictionary = {}) -> void:
	computer.set_screen(computer.screen_on)
	Sfx.play(&"typing")


func exit() -> void:
	Sfx.stop(&"typing")


# Si la habitación se va con la compu en uso (al cargar una partida), exit() no llega a correr
# y el teclado seguiría sonando en la habitación siguiente.
func _exit_tree() -> void:
	if state_machine and state_machine.current_state == self:
		Sfx.stop(&"typing")
