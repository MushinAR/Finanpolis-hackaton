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
## Agarró un item / lo soltó en el piso. Quien tenga el mundo (World) lo vuelve a poner en escena.
signal item_picked(item: Item)
signal item_dropped(item: Item, at_position: Vector2)
## Cambió el estado de la máquina (sirve para HUD o debug).
signal state_changed(state_name: StringName)

## Valores del Player (velocidad, direcciones, animaciones). Ver Data/player_config.tres.
@export var config: PlayerConfig

## Velocidad actual sobre el piso, en px/s. Arranca con el valor de config.speed
## y se puede modificar en juego (cansancio, bonus, etc.).
var speed: float

## Para dónde mira (se, sw, nw, ne). Define el sufijo de la animación.
var facing: StringName = &"se"
## Prop que está usando ahora (null si ninguno).
var current_prop: Prop
## Item que lleva en las manos (null si ninguno).
var carried_item: Item

@onready var state_machine: StateMachine = $StateMachine
@onready var sprite: AnimatedSprite2D = $Sprite
@onready var nav_agent: NavigationAgent2D = $NavigationAgent2D
@onready var carry_slot: Marker2D = $CarrySlot


func _ready() -> void:
	speed = config.speed
	sprite.sprite_frames = SpriteFramesLoader.build(config, "player")
	state_machine.state_changed.connect(state_changed.emit)


## Camina hasta un punto (coordenadas globales).
func move_to(target: Vector2) -> void:
	state_machine.switch_state(&"moving", {"target": target})


## Camina hasta el prop y lo usa al llegar.
func interact_with(prop: Prop) -> void:
	if prop == current_prop or prop.is_occupied:
		return
	# Regla: con las manos ocupadas solo se usan los props que reciben items (basurero).
	# Y esos solo tienen sentido si llevás algo.
	if prop.data.accepts_items != (carried_item != null):
		return
	state_machine.switch_state(&"moving", {
		"target": prop.get_stand_position(),
		"prop": prop,
	})


## Camina hasta el item y lo agarra. Con las manos ocupadas no hace nada.
func pick_up(item: Item) -> void:
	if carried_item or item.is_carried:
		return
	state_machine.switch_state(&"moving", {
		"target": item.global_position,
		"action": &"pick",
		"item": item,
	})


## Camina hasta un punto y suelta lo que lleve. Sin nada en las manos no hace nada.
func drop_item_at(target: Vector2) -> void:
	if carried_item == null:
		return
	state_machine.switch_state(&"moving", {"target": target, "action": &"drop"})


## Se queda con el item en las manos (lo llaman los estados).
func attach_item(item: Item) -> void:
	if item.get_parent():
		item.get_parent().remove_child(item)
	carry_slot.add_child(item)
	item.position = Vector2.ZERO
	item.set_carried(true)
	carried_item = item
	item_picked.emit(item)


## Le saca el item de las manos y lo devuelve suelto (sin padre).
func release_item() -> Item:
	var item := carried_item
	if item:
		carry_slot.remove_child(item)
		item.set_carried(false)
		carried_item = null
	return item


## Suelta el item en el piso, donde está parado. El World lo vuelve a poner en escena.
func drop_carried_item() -> void:
	var item := release_item()
	if item:
		item_dropped.emit(item, global_position)


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
