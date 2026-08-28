extends Area2D

@export var current_upgrade_cost = 20

signal upgrade_signal(upgrade_cost)

func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			print("wow")
			upgrade_signal.emit(current_upgrade_cost)
