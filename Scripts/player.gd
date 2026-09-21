class_name Player
extends CharacterBody2D
## El personaje del jugador. Recibe órdenes ("andá para allá", "usá esto")
## y se las pasa a su StateMachine, que maneja movimiento, animación e interacción.
##
## Las órdenes bajan con llamadas (World -> Player) y los avisos suben con señales.

## Llegó al destino de un move_to().
signal arrived
## Empezó / terminó de usar un prop. `completed` es false si el jugador lo cortó antes.
## Necesidades y tiempo se enganchan acá.
signal interaction_started(prop: Prop)
signal interaction_finished(prop: Prop, completed: bool)
## Cambió el estado de la máquina (sirve para HUD o debug).
signal state_changed(state_name: StringName)

## Valores del Player (velocidad, direcciones, animaciones). Ver Data/player_config.tres.
@export var config: PlayerConfig

## Para dónde mira (se, sw, nw, ne). Define el sufijo de la animación.
var facing: StringName = &"se"
## Prop que está usando ahora (null si ninguno).
var current_prop: Prop

@onready var state_machine: StateMachine = $StateMachine
@onready var sprite: AnimatedSprite2D = $Sprite
@onready var nav_agent: NavigationAgent2D = $NavigationAgent2D


func _ready() -> void:
	sprite.sprite_frames = SpriteFramesLoader.build(config, "player")
	state_machine.state_changed.connect(state_changed.emit)


## Camina hasta un punto (coordenadas globales).
func move_to(target: Vector2) -> void:
	state_machine.switch_state(&"moving", {"target": target})


## Camina hasta el prop y lo usa al llegar.
func interact_with(prop: Prop) -> void:
	if prop == current_prop or prop.is_occupied:
		return
	state_machine.switch_state(&"moving", {
		"target": prop.get_stand_position(),
		"prop": prop,
	})


## Frena todo y se queda quieto.
func stop() -> void:
	state_machine.switch_state(&"idle")


func face_towards(direction: Vector2) -> void:
	if direction.length_squared() > 0.0001:
		facing = CoordinateUtils.direction_name(direction, config.direction_count)


## Reproduce "<nombre>_<dirección>" (ej: walk_se). Si no existe, prueba solo "<nombre>".
## Si todavía no hay esa animación, no hace nada.
func play_animation(animation: StringName) -> void:
	var directional := StringName("%s_%s" % [animation, facing])
	if sprite.sprite_frames.has_animation(directional):
		sprite.play(directional)
	elif sprite.sprite_frames.has_animation(animation):
		sprite.play(animation)
