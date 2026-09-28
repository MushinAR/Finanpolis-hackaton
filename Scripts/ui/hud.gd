class_name Hud
extends CanvasLayer
## La barra de variables del jugador, fija arriba a la izquierda de la pantalla.
##
## Se arma sola: busca al PlayerStats y crea un StatBar por cada variable del StatSet,
## en ese orden. Sumar o sacar una variable es cuestión de editar Data/stats/stat_set.tres.
##
## Es una escena aparte, sin cables a mano: se la suelta en cualquier escena que tenga
## un Player y funciona. Para probar otro diseño, se la reemplaza entera; nada en el
## juego depende de este nodo.

const STAT_BAR := preload("res://Scenes/ui/stat_bar.tscn")

## Nodo PlayerStats. Vacío = lo busca solo por el grupo "player_stats".
@export var stats_path: NodePath

@onready var container: HBoxContainer = %Stats

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
		var bar: StatBar = STAT_BAR.instantiate()
		container.add_child(bar)
		bar.setup(stat)


func _find_stats() -> PlayerStats:
	if not stats_path.is_empty():
		return get_node_or_null(stats_path) as PlayerStats
	return get_tree().get_first_node_in_group(&"player_stats") as PlayerStats
