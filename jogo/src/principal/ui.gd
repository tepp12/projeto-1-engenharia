extends Control

@onready var dinheiro: Label = $ColorRect/Dinheiro


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	dinheiro.text = str(GlobalValues.game_state.food) + " rações"
