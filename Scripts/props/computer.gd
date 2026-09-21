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

@onready var state_machine: StateMachine = $StateMachine
@onready var sprite: Sprite2D = $Sprite


func _ready() -> void:
	super()
	interaction_started.connect(_on_used)
	interaction_finished.connect(_on_released)


func set_screen(texture: Texture2D) -> void:
	sprite.texture = texture


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
