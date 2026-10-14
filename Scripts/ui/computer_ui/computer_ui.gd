extends CanvasLayer
class_name ComputerUI

@onready var tabs_container: HBoxContainer = %TabsContainer
@onready var current_computer_view: Control = %CurrentComputerView

var tabs_buttons : Array[ComputerTab] = []

func _ready() -> void:
	for child in tabs_container.get_children():
		if child is ComputerTab:
			tabs_buttons.append(child)
			child.tab_pressed.connect(_tab_show_view)

func _tab_show_view(view : Control):
	for child in current_computer_view.get_children():
		child.queue_free()
	
	current_computer_view.add_child(view)
	
