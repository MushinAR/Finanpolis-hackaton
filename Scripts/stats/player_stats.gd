class_name PlayerStats
extends Node
## Las variables del jugador (dinero, energía, felicidad, salud, estrés), todas juntas.
## Es hijo del Player y es el nodo con el que hablan las demás escenas: le piden
## valores, le aplican efectos y escuchan sus señales.
##
## Las órdenes bajan con llamadas (un prop suma energía) y los avisos suben con señales
## (la energía llegó al piso). Nadie necesita conocer al Player para escuchar.
##
## Se anota en el grupo "player_stats", así el HUD (u otra escena) lo encuentra sin cables.

## Cambió el valor de una variable. `ratio` va de 0 a 1 (1 fijo si no tiene tope).
signal stat_changed(id: StringName, value: float, ratio: float)
## Cruzó hacia abajo su low_threshold (energía baja, plata que se acaba).
signal stat_reached_low(id: StringName, value: float)
## Cruzó hacia arriba su high_threshold (estrés por las nubes).
signal stat_reached_high(id: StringName, value: float)
## Volvió a la zona sana, entre los dos umbrales.
signal stat_back_to_normal(id: StringName, value: float)
## Tocó el mínimo (energía en 0). Acá se engancha un desmayo, un game over, etc.
signal stat_depleted(id: StringName)
## Tocó el máximo (estrés en 100).
signal stat_maxed(id: StringName)

## Las variables que tiene este jugador. Ver Data/stats/stat_set.tres.
@export var stat_set: StatSet
## Si las variables se desgastan solas con el tiempo (ver change_per_minute de cada una).
@export var auto_change: bool = true
## Cuántos minutos de juego pasa cada segundo real. Cuando exista el TimeManager,
## este valor sale de ahí y se borra de acá.
@export_range(0.0, 60.0, 0.1) var minutes_per_second: float = 1.0

var _stats: Dictionary[StringName, PlayerStat] = {}
var _built: bool = false
# Prop que el jugador está usando ahora, para aplicarle los efectos por segundo.
var _active_prop: Prop


func _ready() -> void:
	add_to_group(&"player_stats")
	_build()
	var player := owner as Player
	if player:
		player.interaction_started.connect(_on_interaction_started)
		player.interaction_finished.connect(_on_interaction_finished)


func _process(delta: float) -> void:
	if _active_prop:
		apply(_active_prop.data.effects_per_second, delta)
	if not auto_change:
		return
	var minutes := delta * minutes_per_second
	for stat in _stats.values():
		if stat.data.change_per_minute != 0.0:
			stat.add(stat.data.change_per_minute * minutes)


## Devuelve la variable entera (para leerle la zona, el color, el StatData...).
func get_stat(id: StringName) -> PlayerStat:
	_build()
	var stat: PlayerStat = _stats.get(id)
	return stat


## Todas las variables, en el orden del StatSet. Lo usa el HUD para armarse solo.
func get_stats() -> Array[PlayerStat]:
	_build()
	var list: Array[PlayerStat] = []
	for stat in _stats.values():
		list.append(stat)
	return list


func get_value(id: StringName) -> float:
	var stat := get_stat(id)
	return stat.value if stat else 0.0


func get_ratio(id: StringName) -> float:
	var stat := get_stat(id)
	return stat.ratio() if stat else 0.0


func set_value(id: StringName, value: float) -> void:
	var stat := get_stat(id)
	if stat:
		stat.value = value


## Suma (o resta, con negativo) a una variable.
func add(id: StringName, amount: float) -> void:
	var stat := get_stat(id)
	if stat:
		stat.add(amount)


## Aplica de una varios efectos: { "energia": 40.0, "estres": -10.0 }.
## `scale` sirve para los efectos por segundo (se multiplican por el delta).
func apply(effects: Dictionary, scale: float = 1.0) -> void:
	for id in effects:
		add(StringName(id), float(effects[id]) * scale)


## ¿Alcanza la plata? (o cualquier otra variable, por si hay que "gastar" energía).
func can_afford(amount: float, id: StringName = &"dinero") -> bool:
	var stat := get_stat(id)
	return stat != null and stat.value >= amount


## Descuenta si alcanza y avisa si se pudo. Para compras.
func spend(amount: float, id: StringName = &"dinero") -> bool:
	if not can_afford(amount, id):
		return false
	add(id, -amount)
	return true


## True si la variable está en su zona mala (baja, o alta si es invertida como el estrés).
func is_critical(id: StringName) -> bool:
	var stat := get_stat(id)
	return stat != null and stat.is_critical()


# Arma las variables la primera vez que alguien las pide (puede ser antes del _ready).
func _build() -> void:
	if _built:
		return
	_built = true
	if stat_set == null:
		push_error("PlayerStats: falta el StatSet (Data/stats/stat_set.tres)")
		return
	for data in stat_set.stats:
		if data == null or data.id.is_empty():
			continue
		var stat := PlayerStat.new(data)
		_stats[data.id] = stat
		stat.changed.connect(_on_stat_changed.bind(stat))
		stat.zone_changed.connect(_on_stat_zone_changed.bind(stat))
		stat.hit_min.connect(stat_depleted.emit.bind(data.id))
		stat.hit_max.connect(stat_maxed.emit.bind(data.id))


func _on_stat_changed(value: float, _previous: float, stat: PlayerStat) -> void:
	stat_changed.emit(stat.data.id, value, stat.ratio())


func _on_stat_zone_changed(zone: PlayerStat.Zone, _previous: PlayerStat.Zone, stat: PlayerStat) -> void:
	match zone:
		PlayerStat.Zone.LOW:
			stat_reached_low.emit(stat.data.id, stat.value)
		PlayerStat.Zone.HIGH:
			stat_reached_high.emit(stat.data.id, stat.value)
		_:
			stat_back_to_normal.emit(stat.data.id, stat.value)


func _on_interaction_started(prop: Prop) -> void:
	_active_prop = prop


# Los efectos de una sola vez se cobran solo si la interacción terminó entera.
func _on_interaction_finished(prop: Prop, completed: bool) -> void:
	_active_prop = null
	if completed:
		apply(prop.data.effects_on_finish)
