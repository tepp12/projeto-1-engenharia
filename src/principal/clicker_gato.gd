extends AnimatedSprite2D

var escala_original := scale
var escala_desejada : Vector2

@onready var click_area := $ClickArea

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	escala_desejada = escala_original


func _process(_delta: float) -> void:
	scale = lerp(scale, escala_desejada, 0.15)

func _mouse_entered() -> void:
	escala_desejada = Vector2(2.5, 2.5)
	
func _mouse_exited() -> void:
	escala_desejada =  escala_original
	
func _on_click_area_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			escala_desejada = Vector2(3, 3)
			GlobalValues.dinheiro = GlobalValues.dinheiro + 1 * GlobalValues.poder_click
			
	if event is InputEventMouseButton and event.is_released():
		if event.button_index == MOUSE_BUTTON_LEFT:
			escala_desejada = escala_original
