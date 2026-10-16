class_name Estrutura

extends Button

@export var nome : String
@export var custo_inicial : int
var custo : int
@export var renda : int
@export var quantidade : int
var mod_soma : int = 0
var mod_prod : int = 1

@onready var label_nome : Label = $Nome
@onready var label_custo : Label = $Custo
@onready var label_quantidade : Label = $Quantidade

#Construtor
func _init(c_nome := " ", c_icon := "res://icon.svg", c_custo := 0, c_renda := 0, c_quantidade := 0) -> void:
	#Carrega um icone para representar a Estrutura
	icon = load(c_icon)
	#Construtor Recebe o Custo Inicial apenas
	custo_inicial = c_custo
	
	nome = c_nome
	renda = c_renda
	quantidade = c_quantidade

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	label_nome.text = nome
	atualizar_custo()

#Aumenta o custo quando o jogador compra uma estrutura
func atualizar_custo() -> void:
	custo = int(custo_inicial*(1.0 + (quantidade/10.0)))
	label_custo.text = str(int(custo))
	label_quantidade.text = "x" + str(int(quantidade))

#Chamado quando o usuario compra estruturas
func comprar(buy_amount :int) -> void:
	for n in buy_amount:
		#Gasta o dinheiro para comprar uma estrutura
		if GlobalValues.dinheiro >= custo:
			GlobalValues.dinheiro += -custo
			quantidade += 1
			atualizar_custo()
		#Encerra o Loop se nao houver Dinheiro o bastante para comprar a estrutura
		else:
			break

#Gera renda para o jogador
func _gerar_renda() -> void:
	GlobalValues.dinheiro += ((renda + mod_soma) * mod_prod)*quantidade

func _pressed() -> void:
	comprar(1)
