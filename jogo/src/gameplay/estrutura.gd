class_name Estrutura

extends Button

@export var nome : String
@export var custo_inicial : int
var custo : int
@export var renda : int
@export var quantidade : int


#Construtor
func _init(c_nome := " ", c_icon := "res://icon.svg", c_custo := 0, c_renda := 0, c_quantidade := 0) -> void:
	#Carrega um icone para representar a Estrutura
	icon = load(c_icon)
	#Construtor Recebe o Custo Inicial apenas
	custo_inicial = c_custo
	custo = custo_inicial
	
	nome = c_nome
	renda = c_renda
	quantidade = c_quantidade
	_atualizar_custo()


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	get_node("Nome").text = nome
	custo = custo_inicial

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	get_node("Custo").text = "Custo:" + str(int(custo)) + "Rações"
	get_node("Quantidade").text = "x" + str(int(quantidade))
	get_node("Renda").text = str(int(renda)) + "Rações por Segundo"

#Aumenta o custo quando o jogador compra uma estrutura
func _atualizar_custo() -> void:
	custo = custo*(1+ (quantidade/10))

#Chamado quando o usuario compra estruturas
func _comprar(buy_amount :int) -> void:
	for n in buy_amount:
		#Gasta o dinheiro para comprar uma estrutura
		if GlobalValues.dinheiro >= custo:
			GlobalValues.dinheiro += -custo
			quantidade += 1
			_atualizar_custo()
		#Encerra o Loop se nao houver Dinheiro o bastante para comprar a estrutura
		else:
			break

#Gera renda para o jogador
func _gerar_renda() -> void:
	GlobalValues.dinheiro += renda*quantidade

func _pressed() -> void:
	_comprar(1)
