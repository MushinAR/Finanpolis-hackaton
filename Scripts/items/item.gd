class_name Item
extends Area2D
## Algo que el jugador puede agarrar, llevar y soltar en otro lado (libro, caja de pizza, ropa...).
## Los datos viven en un ItemData (Data/items/*.tres).

## Clickearon el item. El World la escucha y le avisa al Player.
signal requested(item: Item)

@export var data: ItemData

## true mientras el Player lo lleva en las manos.
var is_carried: bool = false

@onready var click_area: CollisionShape2D = $ClickArea


func _ready() -> void:
	input_event.connect(_on_input_event)


## Lo llama el Player al agarrarlo / soltarlo. Cargado, no se puede clickear.
func set_carried(carried: bool) -> void:
	is_carried = carried
	click_area.set_deferred("disabled", carried)


func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		get_viewport().set_input_as_handled()
		requested.emit(self)
