class_name Item
extends Area2D
## Algo que el jugador puede agarrar, llevar y soltar en otro lado (libro, caja de pizza, ropa...).
## Los datos viven en un ItemData (Data/items/*.tres).

## Clickearon el item. El World la escucha y le avisa al Player.
signal requested(item: Item)

## Offset del dibujo cuando el item está en el piso.
const FLOOR_OFFSET := Vector2(0, -16)

@export var data: ItemData

## true mientras el Player lo lleva en las manos.
var is_carried: bool = false
## Con qué nombre lo recuerda el WorldState. Sale solo de la habitación donde está puesto;
## si el item se crea por código (lo trajiste de otra habitación), lo pone el que lo crea.
var persist_id: String = ""

@onready var click_area: CollisionShape2D = $ClickArea
@onready var sprite: Sprite2D = $Sprite


func _ready() -> void:
	input_event.connect(_on_input_event)
	add_to_group(&"items")
	if persist_id.is_empty():
		var room := WorldState.get_room_of(self)
		persist_id = WorldState.make_item_id(room, self) if room else "spawned::%d" % ResourceUID.create_id()


## Lo llama el Player al agarrarlo / soltarlo. Cargado, no se puede clickear.
## `draw_offset` sube el sprite sin mover el nodo.
func set_carried(carried: bool, draw_offset: Vector2 = Vector2.ZERO) -> void:
	is_carried = carried
	click_area.set_deferred("disabled", carried)
	sprite.offset = FLOOR_OFFSET + draw_offset


func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		get_viewport().set_input_as_handled()
		requested.emit(self)
