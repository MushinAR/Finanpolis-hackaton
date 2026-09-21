class_name Prop
extends Area2D
## Cosa del escenario que el Player puede usar (cama, silla, compu...).
## Los datos de uso (animación, duración...) están en un PropData (Data/props/*.tres);
## el que ejecuta la interacción es el estado "interacting" del Player.

## Clickearon el prop. El World la escucha y le avisa al Player.
signal requested(prop: Prop)
## Alguien empezó a usarlo.
signal interaction_started(player: Player)
## Alguien dejó de usarlo. `completed` es false si el jugador lo cortó antes de que termine.
## Los efectos (energía, plata, etc.) se enganchan acá y se aplican solo si completed es true.
signal interaction_finished(player: Player, completed: bool)

@export var data: PropData

var is_occupied: bool = false
var user: Player

# Markers opcionales. Si faltan, se para abajo del prop y se usa desde el centro.
@onready var stand_point: Marker2D = get_node_or_null("StandPoint")
@onready var use_point: Marker2D = get_node_or_null("UsePoint")


func _ready() -> void:
	input_event.connect(_on_input_event)


## Dónde se para el Player para usarlo (y donde queda al terminar).
func get_stand_position() -> Vector2:
	return stand_point.global_position if stand_point else global_position + Vector2(0, 32)


## Dónde queda el Player mientras lo usa (arriba de la cama, en la silla...).
func get_use_position() -> Vector2:
	return use_point.global_position if use_point else global_position


## La llama el estado "interacting". Devuelve false si ya lo está usando otro.
func begin_interaction(player: Player) -> bool:
	if is_occupied:
		return false
	is_occupied = true
	user = player
	interaction_started.emit(player)
	return true


func end_interaction(player: Player, completed: bool) -> void:
	is_occupied = false
	user = null
	interaction_finished.emit(player, completed)


func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		# Lo marcamos como manejado para que el World no lo tome también como clic en el piso.
		get_viewport().set_input_as_handled()
		requested.emit(self)
