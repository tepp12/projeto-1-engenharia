class_name Estrutura

extends Node

var nome : String
var custo_inicial : int
var renda : int
var quantidade : float
var buy_amount := 1

var upgrade_cost1 := 50.00
var upgrade_cost2 := 100
var upgrade_cost3 := 100
var upgrade_cost4 := 1000
var upgrade_cost5 := 10000
var upgrade_cost6 := 50000

func _process(_delta: float) -> void:
	gerar_renda();

#Aumenta o custo quando o jogador compra uma estrutura
func atualizar_custo(upgrade) -> void:
	upgrade = round(upgrade*(1+ (quantidade/100)))

#Chamado quando o usuario compra estruturas
func _comprar_estrutura(_viewport: Node, event: InputEvent, _shape_idx: int, upgrade_cost) -> void:
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			print("clicou")
			for n in buy_amount:
				#Gasta o dinheiro para comprar uma estrutura
				if GlobalValues.dinheiro >= upgrade_cost:
					GlobalValues.dinheiro += - upgrade_cost
					quantidade += 1
					atualizar_custo(upgrade_cost)
				#Encerra o Loop se nao houver Dinheiro o bastante para comprar a estrutura
				else:
					break

#Gera renda para o jogador
func gerar_renda() -> void:
	GlobalValues.dinheiro += renda
