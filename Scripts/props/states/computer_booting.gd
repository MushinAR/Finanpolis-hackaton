extends ComputerState
## Arrancando. Cuando termina, pasa a "in_use" si alguien la está usando, o a "on" si no.

var timer: SceneTreeTimer


func enter(_msg: Dictionary = {}) -> void:
	computer.set_screen(computer.screen_booting)
	timer = get_tree().create_timer(computer.boot_time)
	timer.timeout.connect(_on_booted)


func exit() -> void:
	if timer and timer.timeout.is_connected(_on_booted):
		timer.timeout.disconnect(_on_booted)
	timer = null


func _on_booted() -> void:
	state_machine.switch_state(&"inuse" if computer.is_occupied else &"on")
