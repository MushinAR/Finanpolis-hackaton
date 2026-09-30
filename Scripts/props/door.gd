class_name Door
extends Area2D
## Puerta que lleva a otra habitación. Cuando el Player entra en su zona,
## se le pregunta si quiere pasar. No es un Prop: no se clickea, se dispara solo.
##
## La pregunta la muestra el PopupCard de la sala (el nodo del grupo "popup"),

## A qué escena lleva. Se elige desde el inspector.
@export_file("*.tscn") var target_scene: String = ""
## Título de la franja amarilla.
@export var title: String = "Puerta"
## Qué dice la ventanita.
@export var question: String = "¿Querés ir al comedor?"
## Textos de los dos botones.
@export var yes_text: String = "Sí"
@export var no_text: String = "No"

var _card: PopupCard


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func _on_body_entered(body: Node2D) -> void:
	var player := body as Player
	if player == null:
		return
	var card := _get_card()
	if card == null:
		push_warning("Door: no hay ningún PopupCard en la escena (grupo 'popup').")
		return
	# Que no siga caminando mientras decide.
	player.stop()
	if not card.chosen.is_connected(_on_chosen):
		card.chosen.connect(_on_chosen)
	if not card.dismissed.is_connected(_desconectar):
		card.dismissed.connect(_desconectar)
	card.show_card(title, question, [yes_text, no_text])


func _on_body_exited(body: Node2D) -> void:
	if body is Player:
		var card := _get_card()
		if card and card.visible:
			card.hide()
		_desconectar()


func _on_chosen(index: int) -> void:
	_desconectar()
	if index != 0:  # 0 = el primer botón, o sea "Sí"
		return
	if target_scene.is_empty():
		push_warning("Door: falta elegir target_scene en el inspector.")
		return
	get_tree().change_scene_to_file(target_scene)


## La card es de la sala, no de la puerta: la buscamos por grupo así no importa
## dónde esté colgada ni cómo se llame el nodo.
func _get_card() -> PopupCard:
	if _card == null or not is_instance_valid(_card):
		_card = get_tree().get_first_node_in_group(&"popup") as PopupCard
	return _card


## Suelta las conexiones para que la próxima card que abra otra cosa no nos avise a nosotros.
func _desconectar() -> void:
	var card := _get_card()
	if card == null:
		return
	if card.chosen.is_connected(_on_chosen):
		card.chosen.disconnect(_on_chosen)
	if card.dismissed.is_connected(_desconectar):
		card.dismissed.disconnect(_desconectar)
