extends Node
## Memoria del mundo: cómo quedó cada habitación cuando el jugador se fue (luces, compu,
## dónde están los items), qué lleva en las manos y cuánto tiempo de juego pasó.
## Es un autoload (Proyecto > Configuración > Autoload), así que vive por encima de las
## escenas y no se borra cuando la puerta cambia de habitación.
##
## Cómo se usa:
##   - Un nodo que quiere acordarse de su estado llama a WorldState.track(self) en su _ready
##     y tiene dos funciones: save_state() -> Dictionary y load_state(state, elapsed).
##     `elapsed` son los segundos que pasaron desde que el jugador se fue de esa habitación,
##     para que el tiempo siga corriendo aunque no la estés mirando (la compu se apaga sola,
##     y más adelante los NPCs pueden hacer sus cosas).
##   - Los items se manejan aparte (pueden cambiar de habitación): ver restore_items().
##   - La puerta llama a leave_room() justo antes de cambiar de escena.
##   - save_game() / load_game() escriben y leen todo esto en disco.

## Dónde se guarda la partida. En Linux queda en ~/.local/share/godot/app_userdata/Dev-Finanpolis/.
const SAVE_PATH := "user://savegame.txt"
## Sube si cambia la forma de lo que se guarda, para poder convertir partidas viejas.
const SAVE_VERSION := 1

## Segundos de juego desde que arrancó la partida. Cuando entre el TimeManager,
## este reloj sale de ahí.
var clock: float = 0.0

## Lo que se recuerda de cada habitación, por ruta de escena:
## {
##   "res://Scenes/world.tscn": {
##     "left_at": 123.4,                                  # clock cuando el jugador se fue
##     "objects": { "Props/NightLamp": {"on": true}, ... }, # save_state() de cada nodo
##     "items": { "<id>": {"scene": "res://...", "position": Vector2(...)}, ... },
##   },
## }
var rooms: Dictionary = {}

## El item que el jugador tenía en las manos al cruzar la puerta ({} si nada).
## { "id": "...", "scene": "res://Scenes/book.tscn" }
var carried_item: Dictionary = {}

# Al cargar una partida, dónde hay que poner al Player cuando aparezca la habitación.
var _pending_player_position: Variant = null
# Al cruzar una puerta, de qué habitación venimos (para aparecer al lado de la puerta que lleva de vuelta).
var _came_from: String = ""


func _process(delta: float) -> void:
	clock += delta


func _unhandled_input(event: InputEvent) -> void:
	# Atajos de prueba hasta que haya un menú: F5 guarda, F9 carga. Solo en debug.
	if not OS.is_debug_build() or not (event is InputEventKey and event.pressed and not event.echo):
		return
	if event.keycode == KEY_F5:
		save_game()
	elif event.keycode == KEY_F9:
		load_game()


#region Objetos que se acuerdan de su estado

## Lo llama cada nodo persistente en su _ready. Si la habitación ya se había visitado,
## le devuelve su estado enseguida (antes de que arranquen sus máquinas de estado).
func track(node: Node) -> void:
	var room := get_room_of(node)
	if room == null:
		return
	node.set_meta(&"persist_id", String(room.get_path_to(node)))
	node.add_to_group(&"persistent")
	var saved: Dictionary = rooms.get(room.scene_file_path, {})
	if saved.is_empty() or not node.has_method(&"load_state"):
		return
	var state: Dictionary = saved.objects.get(node.get_meta(&"persist_id"), {})
	if not state.is_empty():
		node.load_state(state, clock - saved.left_at)


## La habitación a la que pertenece un nodo: la raíz de la escena donde fue puesto a mano.
## Subimos por los owner y no usamos current_scene porque mientras se arma la escena
## nueva puede seguir apuntando a la vieja.
func get_room_of(node: Node) -> Node:
	var room := node.owner
	while room and room.owner:
		room = room.owner
	return room

#endregion


#region Items (pueden cambiar de habitación)

## ID de un item que viene puesto en una escena: habitación + ruta. Es único en todo el juego,
## así el libro de la pieza sigue siendo "el libro de la pieza" aunque lo lleves al living.
func make_item_id(room: Node, item: Node) -> String:
	return "%s::%s" % [room.scene_file_path, room.get_path_to(item)]


## Deja los items de la habitación como estaban la última vez: mueve los que siguen,
## saca los que ya no están (los tiraste o te los llevaste) y crea los que trajiste de otro lado.
## Devuelve los items creados para que el World les conecte las señales.
## Si la habitación nunca se visitó, no toca nada.
func restore_items(room: Node, container: Node) -> Array[Item]:
	var created: Array[Item] = []
	var saved: Dictionary = rooms.get(room.scene_file_path, {})
	if saved.is_empty():
		return created
	var wanted: Dictionary = saved.items.duplicate()
	for item in _items_in(room):
		if wanted.has(item.persist_id):
			item.global_position = wanted[item.persist_id].position
			wanted.erase(item.persist_id)
		else:
			item.get_parent().remove_child(item)
			item.queue_free()
	for id in wanted:
		var item := spawn_item(id, wanted[id].scene)
		if item:
			container.add_child(item)
			item.global_position = wanted[id].position
			created.append(item)
	return created


## Crea un item desde su escena, con su ID de siempre. No lo agrega al árbol.
func spawn_item(id: String, scene_path: String) -> Item:
	var scene := load(scene_path) as PackedScene
	if scene == null:
		push_warning("WorldState: no se pudo cargar el item '%s'" % scene_path)
		return null
	var item := scene.instantiate() as Item
	item.persist_id = id
	return item


## Si el jugador cruzó la puerta con algo en la mano, lo crea de nuevo y se lo devuelve.
## Devuelve el item (o null) para que el World le conecte las señales.
func restore_carried_item(player: Player) -> Item:
	if carried_item.is_empty():
		return null
	var item := spawn_item(carried_item.id, carried_item.scene)
	carried_item = {}
	if item:
		player.attach_item(item)
	return item


func _items_in(room: Node) -> Array[Item]:
	var list: Array[Item] = []
	for node in get_tree().get_nodes_in_group(&"items"):
		var item := node as Item
		if item and not item.is_carried and not item.is_queued_for_deletion() and room.is_ancestor_of(item):
			list.append(item)
	return list

#endregion


#region Entrar y salir de habitaciones

## Saca una foto de la habitación: el estado de cada nodo persistente y dónde está cada item.
## También anota qué lleva el jugador en las manos.
func snapshot_room(room: Node) -> void:
	var objects := {}
	for node in get_tree().get_nodes_in_group(&"persistent"):
		if room.is_ancestor_of(node) and node.has_method(&"save_state"):
			var state: Dictionary = node.save_state()
			if not state.is_empty():
				objects[node.get_meta(&"persist_id")] = state
	var items := {}
	for item in _items_in(room):
		items[item.persist_id] = {"scene": item.scene_file_path, "position": item.global_position}
	rooms[room.scene_file_path] = {"left_at": clock, "objects": objects, "items": items}

	carried_item = {}
	var player := get_tree().get_first_node_in_group(&"player") as Player
	if player and player.carried_item:
		carried_item = {"id": player.carried_item.persist_id, "scene": player.carried_item.scene_file_path}


## La llama la puerta antes de cambiar de escena.
func leave_room() -> void:
	var room := get_tree().current_scene
	if room:
		snapshot_room(room)
		_came_from = room.scene_file_path


## Lo llama el World al arrancar: si venimos de cargar una partida, pone al Player donde estaba;
## si venimos de cruzar una puerta, lo pone al lado de la puerta que lleva de vuelta.
func place_player(player: Player) -> void:
	var came_from := _came_from
	_came_from = ""
	if _pending_player_position != null:
		player.global_position = _pending_player_position
		_pending_player_position = null
		return
	if came_from.is_empty():
		return
	for node in player.get_parent().get_children():
		var door := node as Door
		if door and door.target_scene == came_from:
			player.global_position = door.to_global(door.spawn_offset)
			return

#endregion


#region Guardar y cargar partida

## Empieza de cero: olvida habitaciones, items, reloj y las variables del jugador.
func new_game() -> void:
	clock = 0.0
	rooms.clear()
	carried_item = {}
	_pending_player_position = null
	_came_from = ""
	PlayerStats.reset_persisted()


func save_game(path: String = SAVE_PATH) -> bool:
	var room := get_tree().current_scene
	if room == null:
		return false
	snapshot_room(room)
	var player := get_tree().get_first_node_in_group(&"player") as Player
	var data := {
		"version": SAVE_VERSION,
		"clock": clock,
		"current_room": room.scene_file_path,
		"player_position": player.global_position if player else Vector2.ZERO,
		"carried_item": carried_item,
		"rooms": rooms,
		"stats": PlayerStats.get_persisted(),
	}
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		push_error("WorldState: no se pudo guardar en '%s' (%s)" % [path, error_string(FileAccess.get_open_error())])
		return false
	# var_to_str escribe texto legible y entiende Vector2, StringName, etc.
	file.store_string(var_to_str(data))
	print("Partida guardada en ", ProjectSettings.globalize_path(path))
	return true


## Lee la partida y abre la habitación donde estaba el jugador.
func load_game(path: String = SAVE_PATH) -> bool:
	if not FileAccess.file_exists(path):
		push_warning("WorldState: no hay partida guardada en '%s'" % path)
		return false
	var data = str_to_var(FileAccess.get_file_as_string(path))
	if not data is Dictionary or data.get("version", 0) != SAVE_VERSION:
		push_error("WorldState: la partida guardada no se puede leer")
		return false
	clock = data.clock
	rooms = data.rooms
	carried_item = data.carried_item
	_pending_player_position = data.player_position
	PlayerStats.set_persisted(data.stats)
	get_tree().change_scene_to_file(data.current_room)
	print("Partida cargada")
	return true

#endregion
