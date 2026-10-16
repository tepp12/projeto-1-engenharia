extends Button

@export var nome := ""
@export var desc := ""
@export var custo := 0

@onready var panel := get_parent().get_node("Panel")

func _on_mouse_entered() -> void:
	panel.visible = true
	panel.get_child(0).text = nome
	panel.get_child(1).text = desc
	panel.get_child(3).text = str(custo)

func _on_mouse_exited() -> void:
	panel.visible = false
	

func _on_pressed() -> void:
	if GlobalValues.dinheiro >= custo:
		GlobalValues.poder_click = 2.0
		GlobalValues.dinheiro -= custo
		self.visible = false
