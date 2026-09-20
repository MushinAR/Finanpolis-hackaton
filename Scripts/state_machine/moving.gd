extends State
## Camina hasta un punto. Si viene con un objeto, al llegar pasa a "interacting".
##
## msg: { "target": Vector2 (global), "usable": UsableObject (opcional) }

## A qué distancia del destino damos por llegado (px).
const ARRIVE_DISTANCE: float = 3.0
## Si avanza menos que esta fracción de la velocidad durante STUCK_TIME, se rinde.
const STUCK_SPEED_RATIO: float = 0.2
const STUCK_TIME: float = 0.4

var target: Vector2
var pending_usable: UsableObject
var stuck_timer: float = 0.0


func enter(msg: Dictionary = {}) -> void:
	target = msg.get("target", player.global_position)
	pending_usable = msg.get("usable")
	stuck_timer = 0.0


func exit() -> void:
	player.velocity = Vector2.ZERO
	pending_usable = null


func physics_update(delta: float) -> void:
	var to_target := target - player.global_position
	if to_target.length() <= ARRIVE_DISTANCE:
		_arrive()
		return

	player.velocity = CoordinateUtils.iso_velocity(to_target, player.speed)
	player.face_towards(to_target)
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
	player.global_position = target
	var usable := pending_usable  # exit() lo limpia, por eso lo guardamos antes
	player.arrived.emit()
	if usable:
		state_machine.switch_state(&"interacting", {"usable": usable})
	else:
		state_machine.switch_state(&"idle")
