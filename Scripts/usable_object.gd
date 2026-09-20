class_name UsableObject
extends Area2D
## Cosa del escenario que el Player puede usar (cama, silla, compu...).
## Acá solo se describe cómo se usa; el que lo ejecuta es el estado "interacting".

## Clickearon el objeto. El World la escucha y le avisa al Player.
signal requested(usable: UsableObject)
## Alguien empezó / terminó de usarlo. Acá se van a colgar necesidades, tiempo, plata, etc.
signal interaction_started(player: Player)
signal interaction_finished(player: Player)

@export var display_name: String = "Objeto"
## Animación del Player mientras lo usa (sit, sleep, use_computer...).
@export var animation: StringName = &"use"
## Para dónde mira el Player mientras lo usa.
@export var facing: StringName = &"se"
## Cuánto dura en segundos. 0 = hasta que el jugador haga otra cosa (dormir, sentarse).
@export_range(0.0, 600.0, 0.5, "suffix:s") var duration: float = 0.0
## Color del dibujito provisorio.
@export var placeholder_color: Color = Color(0.5, 0.35, 0.2)

var is_occupied: bool = false
var user: Player

# Markers opcionales. Si faltan, se para abajo del objeto y se usa desde el centro.
@onready var stand_point: Marker2D = get_node_or_null("StandPoint")
@onready var use_point: Marker2D = get_node_or_null("UsePoint")


func _ready() -> void:
	input_event.connect(_on_input_event)


## Dónde se para el Player para usarlo (y donde queda al terminar).
func get_stand_position() -> Vector2:
	return stand_point.global_position if stand_point else global_position + Vector2(0, 24)


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


func end_interaction(player: Player) -> void:
	is_occupied = false
	user = null
	interaction_finished.emit(player)


func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		# Lo marcamos como manejado para que el World no lo tome también como clic en el piso.
		get_viewport().set_input_as_handled()
		requested.emit(self)


# Rombo provisorio hasta que haya pixel art.
func _draw() -> void:
	var points := PackedVector2Array([Vector2(0, -16), Vector2(32, 0), Vector2(0, 16), Vector2(-32, 0)])
	draw_colored_polygon(points, placeholder_color)
	draw_polyline(points + PackedVector2Array([points[0]]), Color.BLACK, 1.0)
