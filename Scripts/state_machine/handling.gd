extends PlayerState
## Agarrar o soltar un item. Dura un instante; si el jugador cambia de idea, se corta sin efecto.
##
## msg: { "action": &"pick" | &"drop", "item": Item (solo para pick) }

const HANDLE_TIME: float = 0.4

var action: StringName
var item: Item
var timer: SceneTreeTimer


func enter(msg: Dictionary = {}) -> void:
	action = msg.get("action", &"")
	item = msg.get("item")
	player.velocity = Vector2.ZERO
	player.play_animation(&"pickup" if action == &"pick" else &"drop")
	timer = get_tree().create_timer(HANDLE_TIME)
	timer.timeout.connect(_on_done)


func exit() -> void:
	if timer and timer.timeout.is_connected(_on_done):
		timer.timeout.disconnect(_on_done)
	timer = null
	item = null


func _on_done() -> void:
	if action == &"pick":
		# Puede que alguien más lo haya tomado o que ya lleve otra cosa.
		if is_instance_valid(item) and not item.is_carried and player.carried_item == null:
			player.attach_item(item)
	elif action == &"drop":
		player.drop_carried_item()
	state_machine.switch_state(&"idle")
