extends Node
## Autoload "Mushin": abre el módulo mushin.ar (inversión con interés compuesto) cuando el
## personaje usa la compu, y traduce sus mensajes a señales de Godot.
##
## Funciona en el export Web: el módulo se monta como <iframe> encima del canvas del juego.
## La carpeta Web/mushin del proyecto se copia dentro del export, como `mushin/`, para que
## quede en el mismo sitio que el juego.
##
## Si en la escena hay un TimeManager, cada día del juego se le avisa al módulo y el módulo
## deja de usar su propio reloj.

## El módulo terminó de abrir una cuenta (alias, avatar, publicKey, goal).
signal account_created(data: Dictionary)
## El jugador apretó ⏻ en el módulo. Ya se cerró el iframe.
signal closed(data: Dictionary)
## Compró un ítem en la tienda. `id` es el del catálogo (pizza, shirt, book, lamp, chair, bed, console).
signal item_bought(id: String, price: int)
## Cambió el saldo de tokens FNP de práctica.
signal tokens_changed(tokens: int)
## Cualquier evento del módulo, por si se necesita algo que no tiene señal propia.
signal event_received(type: String, data: Dictionary)

const IFRAME_ID := "mushin-frame"

## Ruta del módulo relativa al index.html del export.
@export var module_url: String = "mushin/index.html"
## Dónde se abre el módulo fuera del export Web (lo sirve demo.ps1).
@export var desktop_url: String = "http://localhost:8080/"

var is_open: bool = false

# Hay que guardar la referencia al callback: si no, el recolector lo borra y deja de llegar.
var _on_message_cb: JavaScriptObject
var _time_manager: TimeManager


func _ready() -> void:
	get_tree().node_added.connect(_on_node_added)
	# El TimeManager puede haber entrado antes que este autoload (lo carga WorldState).
	_find_time_manager.call_deferred(get_tree().root)
	if not is_available():
		return
	_on_message_cb = JavaScriptBridge.create_callback(_on_message)
	JavaScriptBridge.get_interface("window").addEventListener("message", _on_message_cb)


func is_available() -> bool:
	return OS.has_feature("web")


## Abre el módulo. Sin nombre, el módulo muestra su pantalla de ingreso.
func open(player_name: String = "") -> void:
	var query := "?boot=1"
	if not player_name.is_empty():
		query += "&player=" + player_name.uri_encode()
	if not is_available():
		# Escritorio (editor o build de Windows): se abre en el navegador del sistema.
		# Necesita el servidor local corriendo (demo.ps1) y no hay puente de vuelta.
		OS.shell_open(desktop_url + query)
		return
	var url := module_url + query
	if _time_manager:
		url += "&clock=game"
	JavaScriptBridge.eval("""
		(function () {
			var f = document.getElementById(%s);
			if (!f) {
				f = document.createElement('iframe');
				f.id = %s;
				f.style.cssText = 'position:fixed;inset:0;width:100%%;height:100%%;border:0;z-index:10;background:#0c0614';
				document.body.appendChild(f);
			}
			f.src = %s;
			f.style.display = 'block';
			f.focus();
		})();
	""" % [JSON.stringify(IFRAME_ID), JSON.stringify(IFRAME_ID), JSON.stringify(url)])
	is_open = true


func close() -> void:
	if not is_available() or not is_open:
		return
	is_open = false
	JavaScriptBridge.eval("""
		(function () {
			var f = document.getElementById(%s);
			if (f) { f.style.display = 'none'; f.src = 'about:blank'; }
			var c = document.querySelector('canvas');
			if (c) c.focus();
		})();
	""" % JSON.stringify(IFRAME_ID))


## Premia al jugador con tokens de práctica (ej: por trabajar en la compu).
func add_tokens(amount: int, reason: String = "") -> void:
	_send("add_tokens", {"amount": amount, "reason": reason})


## Avanza el calendario del módulo (las inversiones capitalizan por día).
func advance_days(days: int = 1) -> void:
	_send("advance_days", {"days": days})


func _send(type: String, data: Dictionary) -> void:
	if not is_available() or not is_open:
		return
	var msg := JSON.stringify({"target": "mushin", "type": type, "data": data})
	JavaScriptBridge.eval("""
		(function () {
			var f = document.getElementById(%s);
			if (f && f.contentWindow) f.contentWindow.postMessage(%s, '*');
		})();
	""" % [JSON.stringify(IFRAME_ID), JSON.stringify(msg)])


# Engancha el TimeManager apenas entra al árbol, sin tocar sus escenas.
func _on_node_added(node: Node) -> void:
	if node is TimeManager and _time_manager == null:
		_time_manager = node
		_time_manager.time_passed.connect(_on_time_passed)
		_time_manager.tree_exiting.connect(func() -> void: _time_manager = null)


func _find_time_manager(node: Node) -> void:
	if _time_manager:
		return
	_on_node_added(node)
	for child in node.get_children():
		_find_time_manager(child)


func _on_time_passed(time_size: TimeManager.TimeSize) -> void:
	if time_size == TimeManager.TimeSize.DAY:
		advance_days(1)


func _on_message(args: Array) -> void:
	var raw = JavaScriptBridge.get_interface("JSON").stringify(args[0].data)
	var msg = JSON.parse_string(str(raw))
	if typeof(msg) != TYPE_DICTIONARY or msg.get("source") != "mushin":
		return
	var type: String = msg.get("type", "")
	var data: Dictionary = msg.get("data", {})
	event_received.emit(type, data)
	match type:
		"account_created":
			account_created.emit(data)
		"item_bought":
			item_bought.emit(str(data.get("id", "")), int(data.get("price", 0)))
		"tokens_changed":
			tokens_changed.emit(int(data.get("tokens", 0)))
		"exit":
			close()
			closed.emit(data)
