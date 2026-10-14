extends Button
class_name ComputerTab

@export var tab_scene : PackedScene

signal tab_pressed (view : Control)


func _ready() -> void:
	self.pressed.connect(_tab_create_view)

func _tab_create_view():
	var tab_instance = tab_scene.instantiate()
	emit_signal("tab_pressed",tab_instance)
