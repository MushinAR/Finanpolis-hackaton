class_name PlayerStat
extends RefCounted
## El valor vivo de una variable del jugador. Su definición está en el StatData.
##
## Las señales son "de borde": se emiten solo cuando el valor CRUZA un límite,
## no en cada cambio. Así otra escena puede escuchar `zone_changed` sin recibir
## un aviso por frame mientras la energía sigue baja.

## Zona en la que está el valor respecto de los umbrales del StatData.
enum Zone {
	LOW,     ## Por debajo de low_threshold.
	NORMAL,  ## Entre los dos umbrales.
	HIGH,    ## Por encima de high_threshold.
}

## Cambió el valor (por poco que sea).
signal changed(value: float, previous: float)
## Pasó de una zona a otra (de NORMAL a LOW, etc.).
signal zone_changed(zone: Zone, previous_zone: Zone)
## Tocó el piso (energía en 0, plata en 0).
signal hit_min()
## Tocó el techo (estrés en 100).
signal hit_max()

var data: StatData
## Valor actual. Siempre queda dentro del rango del StatData.
var value: float:
	get: return _value
	set(new_value): set_value(new_value)
var zone: Zone = Zone.NORMAL

# Guardamos el valor aparte para que el setter pueda escribirlo sin llamarse a sí mismo.
var _value: float = 0.0


func _init(stat_data: StatData) -> void:
	data = stat_data
	_value = data.clamp_value(data.initial_value)
	zone = _zone_for(_value)


func set_value(new_value: float) -> void:
	var clamped := data.clamp_value(new_value)
	if is_equal_approx(clamped, _value):
		return
	var previous := _value
	_value = clamped
	changed.emit(_value, previous)

	var new_zone := _zone_for(_value)
	if new_zone != zone:
		var previous_zone := zone
		zone = new_zone
		zone_changed.emit(zone, previous_zone)

	# Los topes solo avisan al llegar, no mientras se quedan ahí.
	if is_equal_approx(_value, data.min_value) and not is_equal_approx(previous, data.min_value):
		hit_min.emit()
	elif data.has_max() and is_equal_approx(_value, data.max_value) and not is_equal_approx(previous, data.max_value):
		hit_max.emit()


func add(amount: float) -> void:
	set_value(_value + amount)


## 0.0 a 1.0, para la barra del HUD.
func ratio() -> float:
	return data.ratio(_value)


func is_low() -> bool:
	return zone == Zone.LOW


func is_high() -> bool:
	return zone == Zone.HIGH


## True cuando la variable está en su zona mala: baja, o alta si es invertida (estrés).
func is_critical() -> bool:
	return is_high() if data.inverted else is_low()


func _zone_for(check_value: float) -> Zone:
	if check_value <= data.low_threshold:
		return Zone.LOW
	if check_value >= data.high_threshold:
		return Zone.HIGH
	return Zone.NORMAL
