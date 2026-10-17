extends Control
## Pestaña "Invertir" de la compu: abre mushin.ar (inversión con interés compuesto).
## En el export Web se monta encima del juego; en escritorio se abre en el navegador.

@onready var label: Label = %StatusLabel

# La ComputerUI es un CanvasLayer: cuando el personaje deja la compu se oculta, pero esta
# vista sigue viva, así que hay que cerrar el módulo a mano.
var _layer: CanvasLayer


func _ready() -> void:
	_layer = _find_layer()
	if _layer:
		_layer.visibility_changed.connect(_on_layer_visibility_changed)
	if Mushin.is_available():
		label.text = "Abriendo mushin.ar..."
	else:
		label.text = "mushin.ar se abrió en tu navegador.\nSi no carga, corré demo.ps1"
	Mushin.open()


func _exit_tree() -> void:
	Mushin.close()


func _on_layer_visibility_changed() -> void:
	# En escritorio no se reabre: cada apertura sería una pestaña nueva del navegador.
	if _layer.visible and Mushin.is_available():
		Mushin.open()
	else:
		Mushin.close()


func _find_layer() -> CanvasLayer:
	var node := get_parent()
	while node and not node is CanvasLayer:
		node = node.get_parent()
	return node as CanvasLayer
