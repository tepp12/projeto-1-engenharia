class_name Estrutura

extends Node

var nome : String
var custo_inicial : int
var custo : float
var renda : int
var quantidade : float

#Aumenta o custo quando o jogador compra uma estrutura
func _atualizar_custo() -> void:
	custo = round(custo*(1+ (quantidade/100)))

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
