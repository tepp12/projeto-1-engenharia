extends Panel

@onready var nome_parque := $LineEdit


func _on_line_edit_text_submitted(new_text: String) -> void:
	if new_text == "":
		nome_parque.placeholder_text = "Parque de ???"
	nome_parque.text = "Parque de " + new_text
	nome_parque.deselect()
	nome_parque.release_focus()

func _on_line_edit_editing_toggled(toggled_on: bool) -> void:
	if toggled_on:
		nome_parque.text = ""
		nome_parque.placeholder_text = ""
