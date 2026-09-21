extends Node2D
## Mundo de prueba: convierte los clicks en órdenes para el Player y la cámara lo sigue.
## Más adelante la parte de interacción puede irse a interaction_system.gd.

@onready var player: Player = $Player
@onready var camera: Camera2D = $Camera2D
@onready var props: Node2D = $Props
@onready var floor_layer: Floor = $Floor
@onready var nav_region: NavigationRegion2D = $NavigationRegion2D


func _ready() -> void:
	_bake_navigation()
	for child in props.get_children():
		if child is Prop:
			child.requested.connect(player.interact_with)
	camera.global_position = player.global_position


func _unhandled_input(event: InputEvent) -> void:
	# Click en el piso. Los clicks sobre props los agarra el propio Prop.
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		player.move_to(get_global_mouse_position())


func _process(_delta: float) -> void:
	camera.global_position = player.global_position


# El piso caminable sale de los tiles del Ground; los obstáculos son todo lo que
# esté en el grupo "nav_obstacles" (paredes, props, cajas). Se cocina al arrancar.
func _bake_navigation() -> void:
	var nav_poly := nav_region.navigation_polygon
	nav_poly.clear_outlines()
	var outline := PackedVector2Array()
	for point in floor_layer.get_walkable_outline():
		outline.append(nav_region.to_local(point))
	nav_poly.add_outline(outline)
	nav_region.bake_navigation_polygon(false)
