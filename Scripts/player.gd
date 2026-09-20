class_name Player
extends CharacterBody2D
## El personaje del jugador. Recibe órdenes ("andá para allá", "usá esto")
## y se las pasa a su StateMachine, que maneja movimiento, animación e interacción.
##
## Las órdenes bajan con llamadas (World -> Player) y los avisos suben con señales.

## Llegó al destino de un move_to().
signal arrived
## Empezó / terminó de usar un objeto. Necesidades y tiempo se enganchan acá.
signal interaction_started(usable: UsableObject)
signal interaction_finished(usable: UsableObject)
## Cambió el estado de la máquina (sirve para HUD o debug).
signal state_changed(state_name: StringName)

## Velocidad sobre el piso, en px/s.
@export var speed: float = 90.0
## Dibuja un muñeco provisorio hasta tener sprites.
@export var show_placeholder: bool = true

## Para dónde mira (e, se, s, sw, w, nw, n, ne). Define el sufijo de la animación.
var facing: StringName = &"s"
## Objeto que está usando ahora (null si ninguno).
var current_usable: UsableObject

@onready var state_machine: StateMachine = $StateMachine
@onready var sprite: AnimatedSprite2D = $Sprite


func _ready() -> void:
	state_machine.state_changed.connect(state_changed.emit)


## Camina hasta un punto (coordenadas globales).
func move_to(target: Vector2) -> void:
	state_machine.switch_state(&"moving", {"target": target})


## Camina hasta el objeto y lo usa al llegar.
func interact_with(usable: UsableObject) -> void:
	if usable == current_usable or usable.is_occupied:
		return
	state_machine.switch_state(&"moving", {
		"target": usable.get_stand_position(),
		"usable": usable,
	})


## Frena todo y se queda quieto.
func stop() -> void:
	state_machine.switch_state(&"idle")


func face_towards(direction: Vector2) -> void:
	if direction.length_squared() > 0.0001:
		facing = CoordinateUtils.direction_name(direction)


## Reproduce "<nombre>_<dirección>" (ej: walk_se). Si no existe, prueba solo "<nombre>".
## Si todavía no hay animaciones, no hace nada.
func play_animation(animation: StringName) -> void:
	if sprite.sprite_frames == null:
		return
	var directional := StringName("%s_%s" % [animation, facing])
	if sprite.sprite_frames.has_animation(directional):
		sprite.play(directional)
	elif sprite.sprite_frames.has_animation(animation):
		sprite.play(animation)


func _process(_delta: float) -> void:
	if show_placeholder:
		queue_redraw()


# Muñeco provisorio: el origen está en los pies y la línea negra marca para dónde mira.
func _draw() -> void:
	if not show_placeholder:
		return
	var busy := current_usable != null
	draw_circle(Vector2(0, -12), 8.0, Color(0.4, 0.7, 0.9) if busy else Color(0.9, 0.6, 0.2))
	draw_circle(Vector2(0, -26), 6.0, Color(0.95, 0.8, 0.65))
	var index := CoordinateUtils.DIRECTIONS.find(facing)
	var dir := Vector2.from_angle(index * PI / 4.0) if index >= 0 else Vector2.DOWN
	draw_line(Vector2(0, -12), Vector2(0, -12) + dir * 14.0, Color.BLACK, 2.0)
