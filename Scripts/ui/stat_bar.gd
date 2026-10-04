class_name StatBar
extends HBoxContainer
## Un stat de bienestar en la franja del HUD: ícono + barra, sin número
## (norma de la guía de UI: los stats de bienestar nunca muestran su valor exacto).
##
## El color de la barra sale del nivel, no de la variable: arriba del 60% va en verde,
## entre 30 y 60 en amarillo y abajo de 30 en rojo. El estrés usa la escala al revés
## (poco estrés = verde), porque tiene `inverted` prendido en su .tres.
##
## La forma de la barra (alto, bordes, cápsula) se edita en Scenes/ui/stat_bar.tscn.

## Cuánto tarda la barra en llegar al valor nuevo, en segundos. 0 = salta de una.
@export_range(0.0, 2.0, 0.05, "suffix:s") var fill_time: float = 0.25

var stat: PlayerStat

@onready var icon: TextureRect = $Icon
@onready var bar: ProgressBar = $Bar

var _fill: StyleBoxFlat
var _fill_tween: Tween


## La llama el HUD al crearlo.
func setup(new_stat: PlayerStat) -> void:
	if not is_node_ready():
		await ready
	stat = new_stat
	name = String(stat.data.id).capitalize()
	tooltip_text = stat.data.display_name
	icon.texture = stat.data.icon
	# Copiamos el estilo del .tscn para poder recolorear solo el relleno.
	_fill = bar.get_theme_stylebox(&"fill").duplicate() as StyleBoxFlat
	bar.add_theme_stylebox_override(&"fill", _fill)
	_refresh(false)
	stat.changed.connect(_on_stat_changed)


func _on_stat_changed(_value: float, _previous: float) -> void:
	_refresh(true)


func _refresh(animate: bool) -> void:
	var ratio := stat.ratio()
	_fill.bg_color = Palette.bar_color(ratio, stat.data.inverted)
	var target := ratio * 100.0
	if _fill_tween:
		_fill_tween.kill()
	if animate and fill_time > 0.0:
		_fill_tween = create_tween()
		_fill_tween.tween_property(bar, ^"value", target, fill_time)
	else:
		bar.value = target
