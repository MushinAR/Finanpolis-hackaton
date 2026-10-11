class_name Computer
extends Prop
## Computadora. Tiene su propia máquina de estados:
##   off -> booting -> in_use -> on -> off
## Arranca apagada; al usarla se enciende (tarda un poco), mientras la usan está "in_use",
## después queda prendida un rato y se vuelve a apagar sola.

@export var screen_off: Texture2D
@export var screen_booting: Texture2D
@export var screen_on: Texture2D
## Segundos que tarda en arrancar.
@export var boot_time: float = 1.5
## Segundos que queda prendida sin uso antes de apagarse sola.
@export var idle_off_time: float = 8.0

## Si volvimos a la habitación y la compu seguía prendida, cuánto le falta para apagarse.
## Lo consume el estado "on" al arrancar (-1 = usar idle_off_time).
var resume_off_in: float = -1.0

@onready var state_machine: StateMachine = $StateMachine


func _ready() -> void:
	super()
	interaction_started.connect(_on_used)
	interaction_finished.connect(_on_released)


func set_screen(texture: Texture2D) -> void:
	sprite.texture = texture


## Prendida o apagada, y cuánto le faltaba para apagarse sola.
## Arrancando o en uso cuenta como prendida con el tiempo entero por delante.
func save_state() -> Dictionary:
	match state_machine.current_state.name:
		&"Off":
			return {"on": false}
		&"On":
			return {"on": true, "off_in": state_machine.current_state.time_left()}
		_:
			return {"on": true, "off_in": idle_off_time}


## El tiempo siguió corriendo mientras no estabas: si ya se tendría que haber apagado, arranca apagada.
func load_state(state: Dictionary, elapsed: float) -> void:
	var off_in: float = state.get("off_in", 0.0) - elapsed
	if state.get("on", false) and off_in > 0.0:
		state_machine.initial_state = &"on"
		resume_off_in = off_in
	else:
		state_machine.initial_state = &"off"


func _on_used(_player: Player) -> void:
	# Apagada: hay que arrancarla. Prendida: se usa directo.
	if state_machine.current_state.name == &"Off":
		state_machine.switch_state(&"booting")
	elif state_machine.current_state.name == &"On":
		state_machine.switch_state(&"inuse")


func _on_released(_player: Player, _completed: bool) -> void:
	# Si se estaba arrancando, sigue arrancando y después queda prendida (ver Booting).
	if state_machine.current_state.name == &"InUse":
		state_machine.switch_state(&"on")
