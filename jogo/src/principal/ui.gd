extends Control

@onready var dinheiro := $ColorRect/Dinheiro
@onready var timer := $Timer
@onready var estruturas = $Estruturas

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	timer.timeout.connect(_on_timeout)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	dinheiro.text = str(int(GlobalValues.dinheiro)) + " rações"
	pass

func _chamarEstruturas() -> void:
	for struct in estruturas.get_children():
		struct._gerar_renda()

func _on_timeout() -> void:
	_chamarEstruturas()
