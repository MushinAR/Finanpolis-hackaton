extends Node2D
## Mundo de prueba: convierte los clicks en órdenes para el Player y la cámara lo sigue.
## Más adelante la parte de interacción puede irse a interaction_system.gd.

@onready var player: Player = $Player
@onready var camera: Camera2D = $Camera2D
@onready var usable_objects: Node2D = $UsableObjects


func _ready() -> void:
	for child in usable_objects.get_children():
		if child is UsableObject:
			child.requested.connect(player.interact_with)
	camera.global_position = player.global_position


func _unhandled_input(event: InputEvent) -> void:
	# Click en el piso. Los clicks sobre objetos los agarra el propio UsableObject.
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		player.move_to(get_global_mouse_position())


func _process(_delta: float) -> void:
	camera.global_position = player.global_position
