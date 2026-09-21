extends PlayerState
## Usando un prop (sentado, durmiendo, en la compu...).
## Un solo estado sirve para todos: lo que cambia (animación, posición, duración)
## lo define el PropData de cada prop.
##
## Si el jugador corta a la mitad, se levanta enseguida y el prop avisa completed = false.
## La próxima vez que lo use, el temporizador arranca de cero (no retoma donde quedó).
##
## msg: { "prop": Prop }

var prop: Prop
var timer: SceneTreeTimer
var completed: bool = false


func enter(msg: Dictionary = {}) -> void:
	prop = msg.get("prop")
	completed = false
	if prop == null or not prop.begin_interaction(player):
		# Estaba ocupado o no vino nada: volvemos a idle.
		prop = null
		state_machine.switch_state.call_deferred(&"idle")
		return

	player.velocity = Vector2.ZERO
	player.current_prop = prop
	player.global_position = prop.get_use_position()
	player.facing = prop.data.facing
	player.play_animation(prop.data.animation)
	player.interaction_started.emit(prop)

	# duration 0 = se queda hasta que el jugador haga otra cosa.
	if prop.data.duration > 0.0:
		timer = get_tree().create_timer(prop.data.duration)
		timer.timeout.connect(_on_duration_finished)


func exit() -> void:
	if timer and timer.timeout.is_connected(_on_duration_finished):
		timer.timeout.disconnect(_on_duration_finished)
	timer = null
	if prop == null:
		return
	# Se levanta y queda parado al lado del prop.
	player.global_position = prop.get_stand_position()
	player.current_prop = null
	prop.end_interaction(player, completed)
	player.interaction_finished.emit(prop, completed)
	prop = null


func _on_duration_finished() -> void:
	completed = true
	# Si el prop recibe items (basurero), se queda con lo que el jugador lleve en las manos.
	if prop.data.accepts_items and player.carried_item:
		prop.receive_item(player.release_item())
	state_machine.switch_state(&"idle")
