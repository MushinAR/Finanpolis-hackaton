class_name MoneyDisplay
extends PanelContainer
## El dinero en el HUD. Tiene su propio contenedor destacado y su número más grande que
## el resto: es la variable central del juego y nunca se agrupa igual que los stats de
## bienestar (norma de la guía de UI).

var stat: PlayerStat

@onready var icon: TextureRect = %MoneyIcon
@onready var value_label: Label = %MoneyValue


func setup(new_stat: PlayerStat) -> void:
	if not is_node_ready():
		await ready
	stat = new_stat
	tooltip_text = stat.data.display_name
	icon.texture = stat.data.icon
	_refresh()
	stat.changed.connect(_on_stat_changed)


func _on_stat_changed(_value: float, _previous: float) -> void:
	_refresh()


func _refresh() -> void:
	value_label.text = stat.data.format_value(stat.value)
