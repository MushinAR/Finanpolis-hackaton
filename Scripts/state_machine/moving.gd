extends PlayerState
## Camina hasta un punto esquivando obstáculos (usa el NavigationAgent2D del Player).
## Al llegar, según lo que venga en el mensaje, pasa a usar un prop, agarrar/soltar un item, o a idle.
##
## msg: { "target": Vector2 (global),
##        "prop": Prop (opcional),
##        "action": &"pick" | &"drop" (opcional), "item": Item (opcional, para pick) }

## Si avanza menos que esta fracción de la velocidad durante STUCK_TIME, se rinde.
const STUCK_SPEED_RATIO: float = 0.2
const STUCK_TIME: float = 0.4

var target: Vector2
var pending_prop: Prop
var pending_action: StringName
var pending_item: Item
var stuck_timer: float = 0.0


func enter(msg: Dictionary = {}) -> void:
	target = msg.get("target", player.global_position)
	pending_prop = msg.get("prop")
	pending_action = msg.get("action", &"")
	pending_item = msg.get("item")
	stuck_timer = 0.0
	player.nav_agent.target_position = target


func exit() -> void:
	player.velocity = Vector2.ZERO
	pending_prop = null
	pending_item = null
	pending_action = &""


func physics_update(delta: float) -> void:
	# Si el destino cae dentro de un obstáculo, el agente termina en el punto más cercano.
	if player.nav_agent.is_navigation_finished():
		_arrive()
		return

	var to_next := player.nav_agent.get_next_path_position() - player.global_position
	player.velocity = CoordinateUtils.iso_velocity(to_next, player.speed)
	player.face_towards(to_next)
	player.play_animation(&"walk")
	player.move_and_slide()

	# Anti-atasco: si chocó con algo y no avanza, corta.
	if player.get_real_velocity().length() < player.speed * STUCK_SPEED_RATIO:
		stuck_timer += delta
		if stuck_timer >= STUCK_TIME:
			state_machine.switch_state(&"idle")
	else:
		stuck_timer = 0.0


func _arrive() -> void:
	# exit() limpia los pendientes, por eso los guardamos antes.
	var prop := pending_prop
	var action := pending_action
	var item := pending_item
	player.arrived.emit()
	if prop:
		player.global_position = target
		state_machine.switch_state(&"interacting", {"prop": prop})
	elif action != &"":
		state_machine.switch_state(&"handling", {"action": action, "item": item})
	else:
		state_machine.switch_state(&"idle")
