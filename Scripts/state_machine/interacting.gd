extends State
## Usando un objeto (sentado, durmiendo, en la compu...).
## Un solo estado sirve para todos: lo que cambia (animación, posición, duración)
## lo define cada UsableObject.
##
## msg: { "usable": UsableObject }

var usable: UsableObject
var timer: SceneTreeTimer


func enter(msg: Dictionary = {}) -> void:
	usable = msg.get("usable")
	if usable == null or not usable.begin_interaction(player):
		# Estaba ocupado o no vino nada: volvemos a idle.
		usable = null
		state_machine.switch_state.call_deferred(&"idle")
		return

	player.velocity = Vector2.ZERO
	player.current_usable = usable
	player.global_position = usable.get_use_position()
	player.facing = usable.facing
	player.play_animation(usable.animation)
	player.interaction_started.emit(usable)

	# duration 0 = se queda hasta que el jugador haga otra cosa.
	if usable.duration > 0.0:
		timer = get_tree().create_timer(usable.duration)
		timer.timeout.connect(_on_duration_finished)


func exit() -> void:
	if timer and timer.timeout.is_connected(_on_duration_finished):
		timer.timeout.disconnect(_on_duration_finished)
	timer = null
	if usable == null:
		return
	# Se levanta y queda parado al lado del objeto.
	player.global_position = usable.get_stand_position()
	player.current_usable = null
	usable.end_interaction(player)
	player.interaction_finished.emit(usable)
	usable = null


func _on_duration_finished() -> void:
	state_machine.switch_state(&"idle")
