extends ComputerState
## Prendida sin uso. Pasado un rato se apaga sola.

var timer: SceneTreeTimer


func enter(_msg: Dictionary = {}) -> void:
	computer.set_screen(computer.screen_on)
	# Si venimos de otra habitación, le queda lo que le faltaba; si no, el tiempo entero.
	var wait := computer.resume_off_in if computer.resume_off_in > 0.0 else computer.idle_off_time
	computer.resume_off_in = -1.0
	timer = get_tree().create_timer(wait)
	timer.timeout.connect(_on_timeout)


func exit() -> void:
	if timer and timer.timeout.is_connected(_on_timeout):
		timer.timeout.disconnect(_on_timeout)
	timer = null


## Segundos que le faltan para apagarse sola (para el WorldState).
func time_left() -> float:
	return timer.time_left if timer else computer.idle_off_time


func _on_timeout() -> void:
	state_machine.switch_state(&"off")
