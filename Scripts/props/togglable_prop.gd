class_name TogglableProp
extends Prop
## Prop que se prende y se apaga (lámpara, interruptor). Tiene su propia máquina de estados
## off <-> on: cada vez que el jugador lo usa hasta el final, cambia de estado.
## Los hijos pisan apply_state() para hacer algo más (prender una luz, etc.).

@export var texture_off: Texture2D
@export var texture_on: Texture2D
## Si arranca prendido.
@export var starts_on: bool = false

@onready var state_machine: StateMachine = $StateMachine
@onready var sprite: Sprite2D = $Sprite


func _ready() -> void:
	super()
	# La máquina arranca cuando este nodo termina su _ready, así que todavía llegamos a tiempo.
	state_machine.initial_state = &"on" if starts_on else &"off"
	interaction_finished.connect(_on_released)


## Lo llaman los estados off / on. Los hijos pisan esto y llaman a super().
func apply_state(is_on: bool) -> void:
	sprite.texture = texture_on if is_on else texture_off


func _on_released(_player: Player, completed: bool) -> void:
	if not completed:
		return
	var next := &"off" if state_machine.current_state.name == &"On" else &"on"
	state_machine.switch_state(next)
