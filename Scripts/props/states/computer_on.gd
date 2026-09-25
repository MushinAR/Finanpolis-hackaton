extends ComputerState
## Prendida sin uso. Pasado un rato se apaga sola.

var timer: SceneTreeTimer


func enter(_msg: Dictionary = {}) -> void:
	computer.set_screen(computer.screen_on)
	timer = get_tree().create_timer(computer.idle_off_time)
	timer.timeout.connect(_on_timeout)


func exit() -> void:
	if timer and timer.timeout.is_connected(_on_timeout):
		timer.timeout.disconnect(_on_timeout)
	timer = null


func _on_timeout() -> void:
	state_machine.switch_state(&"off")
