class_name StatBar
extends HBoxContainer
## Un indicador del HUD: el ícono de la variable con su barra (o con su número, si no
## tiene tope, como el dinero). Se arma solo con lo que dice el StatData.
##
## El arte se cambia desde Scenes/ui/stat_bar.tscn (tamaños, bordes, separación) y los
## colores desde cada Data/stats/*.tres. Acá no hay nada hardcodeado.

## Cuánto tarda la barra en llegar al valor nuevo, en segundos. 0 = salta de una.
@export_range(0.0, 2.0, 0.05, "suffix:s") var fill_time: float = 0.25

var stat: PlayerStat

@onready var icon: TextureRect = $Icon
@onready var bar: ProgressBar = $Bar
@onready var value_label: Label = $Value

var _fill_tween: Tween
var _alert_tween: Tween


## La llama el HUD al crearlo.
func setup(new_stat: PlayerStat) -> void:
	if not is_node_ready():
		await ready
	stat = new_stat
	var data := stat.data
	name = String(data.id).capitalize()
	tooltip_text = data.display_name
	icon.texture = data.icon

	var is_bar: bool = data.display_mode == "bar" and data.has_max()
	bar.visible = is_bar
	value_label.visible = not is_bar
	if is_bar:
		# Copiamos el estilo del .tscn y le ponemos el color de la variable, así el
		# diseñador puede cambiar forma y bordes sin tocar código.
		var fill := bar.get_theme_stylebox(&"fill").duplicate() as StyleBoxFlat
		fill.bg_color = data.color
		bar.add_theme_stylebox_override(&"fill", fill)
	else:
		value_label.add_theme_color_override(&"font_color", data.color)

	_refresh(false)
	_set_alert(stat.is_critical())
	stat.changed.connect(_on_stat_changed)
	stat.zone_changed.connect(_on_zone_changed)


func _on_stat_changed(_value: float, _previous: float) -> void:
	_refresh(true)


func _on_zone_changed(_zone: PlayerStat.Zone, _previous: PlayerStat.Zone) -> void:
	_set_alert(stat.is_critical())


func _refresh(animate: bool) -> void:
	if bar.visible:
		var target: float = stat.ratio() * 100.0
		if _fill_tween:
			_fill_tween.kill()
		if animate and fill_time > 0.0:
			_fill_tween = create_tween()
			_fill_tween.tween_property(bar, ^"value", target, fill_time)
		else:
			bar.value = target
	else:
		value_label.text = stat.data.format_value(stat.value)


# Cuando la variable entra en su zona mala, late para que se note.
func _set_alert(on: bool) -> void:
	if _alert_tween:
		_alert_tween.kill()
		_alert_tween = null
	if not on:
		modulate.a = 1.0
		return
	_alert_tween = create_tween().set_loops()
	_alert_tween.tween_property(self, ^"modulate:a", 0.35, 0.5).set_trans(Tween.TRANS_SINE)
	_alert_tween.tween_property(self, ^"modulate:a", 1.0, 0.5).set_trans(Tween.TRANS_SINE)
