class_name Estrutura

extends Node

@export var nome : String
@export var e_icon : Texture2D
@export var custo_inicial : int
var custo : int
@export var renda : int
@export var quantidade : int

#Construtor
func _init(c_nome := " ", c_icon := "res://icon.svg", c_custo := 0, c_renda := 0, c_quantidade := 0) -> void:
	#Carrega um icone para representar a Estrutura
	e_icon = load(c_icon)
	
	#Construtor Recebe o Custo Inicial apenas
	custo_inicial = c_custo
	custo = custo_inicial
	
	nome = c_nome
	renda = c_renda
	quantidade = c_quantidade
	_atualizar_custo()


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

#Aumenta o custo quando o jogador compra uma estrutura
func _atualizar_custo() -> void:
	custo = custo*(1+ (quantidade/100))

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
	GlobalValues.dinheiro += renda
