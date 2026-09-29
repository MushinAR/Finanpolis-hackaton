class_name Hud
extends CanvasLayer
## La franja de arriba: dinero, bienestar y tiempo. Una sola barra anclada al borde
## superior, de ancho completo (norma de la guía de UI, Docs/ui_guidelines.md).
##
## Se arma sola: busca al PlayerStats y reparte cada variable según cómo pida mostrarse
## (`display_mode`): el dinero va a su contenedor propio y el resto sale como ícono + barra,
## en el orden de Data/stats/stat_set.tres.
##
## Es una escena aparte, sin cables a mano: se la suelta en cualquier escena que tenga
## un Player y funciona. Para probar otro diseño, se la reemplaza entera.

const STAT_BAR := preload("res://Scenes/ui/stat_bar.tscn")

## Nodo PlayerStats. Vacío = lo busca solo por el grupo "player_stats".
@export var stats_path: NodePath

@onready var money: MoneyDisplay = %Money
@onready var bars: HBoxContainer = %Bars
@onready var time_controls: TimeControls = %Time

var stats: PlayerStats


func _ready() -> void:
	stats = _find_stats()
	if stats == null:
		# Por si el HUD quedó antes que el Player en el árbol: le damos un frame.
		await get_tree().process_frame
		stats = _find_stats()
	if stats == null:
		push_warning("Hud: no encontré un PlayerStats en la escena")
		return
	for stat in stats.get_stats():
		if stat.data.display_mode == "number":
			money.setup(stat)
		else:
			var bar: StatBar = STAT_BAR.instantiate()
			bars.add_child(bar)
			bar.setup(stat)


func _find_stats() -> PlayerStats:
	if not stats_path.is_empty():
		return get_node_or_null(stats_path) as PlayerStats
	return get_tree().get_first_node_in_group(&"player_stats") as PlayerStats
