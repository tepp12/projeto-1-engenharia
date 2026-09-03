extends Button
	
@onready var NomeTXT = get_node("Nome")
@onready var QuantidadeTXT = get_node("Quantidade")
@onready var RendaTXT = get_node("Renda")
@onready var CustoTXT = get_node("Custo")
@onready var Data = get_node("Estrutura")

	# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	NomeTXT.text = Data.nome
	icon = Data.e_icon

	# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	QuantidadeTXT = "x" + str(int(Data.quantidade))
	CustoTXT = "Custo:" + str(int(Data.custo)) + "Rações"
	RendaTXT = str(int(Data.renda)) + "Rações por segundo"

func _on_pressed() -> void:
	Data._comprar(1)
