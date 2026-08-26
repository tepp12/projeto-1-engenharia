class_name Upgrade
extends RefCounted


# Contrato de criação:
# - upgrade_id é gerado e controlado pelo backend Java, nunca pelo cliente.
# - Um Upgrade "oficial" só deve existir a partir de from_dict(), reconstruindo
#   dados que já vieram validados do servidor (ex: após confirmar uma compra).
# - Chamar Upgrade.new(...) diretamente com um ID inventado no cliente pode
#   gerar dessincronia entre o estado local e o backend. Evitar fora de from_dict().
#
# Contrato de progressão:
# - upgrade_level nunca deve ser incrementado diretamente no cliente.
# - Ao melhorar um upgrade, o Godot envia ao backend apenas a intenção
#   (ex: qual upgrade_type o jogador quer melhorar), sem calcular o novo nível.
# - O backend valida saldo/custo, incrementa o nível no banco, e devolve o
#   Upgrade atualizado. O Godot reconstrói o objeto via from_dict() com essa
#   resposta — nunca fazendo upgrade.upgrade_level += 1 localmente.




enum UpgradeType {
	CLICK_POWER,
	GLOBAL_PRODUCTION
}


var _upgrade_id_definido: bool = false
var upgrade_id: String:
	set(value):
		if _upgrade_id_definido:
			push_error("upgrade_id não pode ser alterado após a criação")
			return
		upgrade_id = value
		_upgrade_id_definido = true
var upgrade_type: UpgradeType
var upgrade_level: int


func _init(id: String, type: UpgradeType, level: int):
	assert(id.strip_edges() != "", "upgrade_id não pode ser vazio")
	assert(level >= 1, "upgrade_level deve ser no mínimo 1")
	upgrade_id = id
	upgrade_type = type
	upgrade_level = level

func to_dict() -> Dictionary:
	return {
		"upgrade_id": upgrade_id,
		"upgrade_type": UpgradeType.keys()[upgrade_type],
		"upgrade_level": upgrade_level
	}

static func from_dict(data: Dictionary) -> Upgrade:
	if not data.has("upgrade_id") or not data.has("upgrade_type") or not data.has("upgrade_level"):
		push_error("Dados de upgrade incompletos: " + str(data))
		return null

	var id = data["upgrade_id"]
	var type_str = data["upgrade_type"]
	var level = data["upgrade_level"]

	if typeof(id) != TYPE_STRING or id.strip_edges() == "":
		push_error("upgrade_id inválido: " + str(id))
		return null
	if typeof(type_str) != TYPE_STRING or not UpgradeType.keys().has(type_str):
		push_error("upgrade_type desconhecido: " + str(type_str))
		return null
	if typeof(level) != TYPE_INT or level < 1:
		push_error("upgrade_level inválido: " + str(level))
		return null

	return Upgrade.new(id, UpgradeType[type_str], level)
	
func _to_string() -> String:
	return "Upgrade: {id=%s, type=%s, level=%d}" % [upgrade_id, UpgradeType.keys()[upgrade_type], upgrade_level]
