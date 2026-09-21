class_name Lamp
extends Prop
## Lámpara. Su máquina de estados es simple: off <-> on.
## Cada vez que el jugador la usa hasta el final, cambia de estado.

@export var texture_off: Texture2D
@export var texture_on: Texture2D

@onready var state_machine: StateMachine = $StateMachine
@onready var sprite: Sprite2D = $Sprite


func _ready() -> void:
	super()
	interaction_finished.connect(_on_released)


func set_light(is_on: bool) -> void:
	sprite.texture = texture_on if is_on else texture_off


func _on_released(_player: Player, completed: bool) -> void:
	if not completed:
		return
	var next := &"off" if state_machine.current_state.name == &"On" else &"on"
	state_machine.switch_state(next)
