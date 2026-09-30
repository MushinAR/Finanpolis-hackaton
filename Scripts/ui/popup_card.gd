class_name PopupCard
extends CanvasLayer
## Ventanita emergente del juego: franja de titulo, un mensaje y N botones apilados.
## Se usa igual para una pregunta de si/no que para una carta de evento con 3 opciones.

## Apretaron una opcion. `index` es la posicion en la lista que se le paso a show_card().
signal chosen(index: int)
## Se cerro sin elegir nada.
signal dismissed

@onready var header: Label = %HeaderLabel
@onready var message: Label = %MessageLabel
@onready var options: VBoxContainer = %Options


## Llena la card y la muestra. `opciones` es un Array[String].
func show_card(titulo: String, mensaje: String, opciones: Array) -> void:
	header.text = titulo.to_upper()
	message.text = mensaje
	for viejo in options.get_children():
		viejo.queue_free()
	for i in opciones.size():
		var boton := Button.new()
		boton.text = str(opciones[i])
		boton.pressed.connect(_on_pressed.bind(i))
		options.add_child(boton)
	show()


func _on_pressed(index: int) -> void:
	hide()
	chosen.emit(index)


func _unhandled_input(event: InputEvent) -> void:
	if visible and event.is_action_pressed(&"ui_cancel"):
		get_viewport().set_input_as_handled()
		hide()
		dismissed.emit()
