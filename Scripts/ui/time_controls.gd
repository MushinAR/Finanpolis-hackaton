class_name TimeControls
extends HBoxContainer
## Selector de velocidad del tiempo (x1, x2, x4, x8) y la fecha, a la derecha del HUD.
##
## Reglas de la guía de UI: no hay botón de pausa, los cuatro botones van pegados
## formando un solo grupo, y el sistema puede forzar x1 ante un evento importante
## (con force_speed) aunque el jugador no lo haya tocado.
##
## Todavía no existe el TimeManager: por ahora esto solo avisa con su señal y muestra
## el texto que le pasen. Cuando exista, se engancha acá sin tocar el resto.

## Cambió la velocidad. `scale` es 1, 2, 4 u 8.
signal speed_changed(scale: float)

const SPEEDS: Array[float] = [1.0, 2.0, 4.0, 8.0]

@onready var buttons: HBoxContainer = %Speeds
@onready var date_label: Label = %DateLabel

var current_speed: float = 1.0


func _ready() -> void:
	for i in buttons.get_child_count():
		var button := buttons.get_child(i) as Button
		if button:
			button.pressed.connect(_on_button_pressed.bind(i))
	_select(0, false)


## La usa el juego para frenar a x1 ante un evento importante. El botón se marca solo.
func force_speed(scale: float = 1.0) -> void:
	var index := SPEEDS.find(scale)
	if index >= 0:
		_select(index, true)


## Texto de la fecha (ej: "Semana 12 · Marzo"). Se lo pasará el TimeManager.
func set_date_text(text: String) -> void:
	date_label.text = text


func _on_button_pressed(index: int) -> void:
	_select(index, true)


func _select(index: int, notify: bool) -> void:
	for i in buttons.get_child_count():
		var button := buttons.get_child(i) as Button
		if button:
			button.set_pressed_no_signal(i == index)
	current_speed = SPEEDS[index]
	if notify:
		speed_changed.emit(current_speed)
