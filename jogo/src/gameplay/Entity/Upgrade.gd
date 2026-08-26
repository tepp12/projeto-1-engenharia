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


var _upgrade_id: String
var _upgrade_type: UpgradeType
var _upgrade_level: int

var upgrade_id: String:
	get:
		return _upgrade_id

var upgrade_type: UpgradeType:
	get:
		return _upgrade_type

var upgrade_level: int:
	get:
		return _upgrade_level


func _init(id: String, type: UpgradeType, level: int) -> void:
	assert(id.strip_edges() != "", "upgrade_id não pode ser vazio")
	assert(level >= 1, "upgrade_level deve ser no mínimo 1")
	_upgrade_id = id
	_upgrade_type = type
	_upgrade_level = level


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

	var raw_id: Variant = data["upgrade_id"]
	var raw_type: Variant = data["upgrade_type"]
	var raw_level: Variant = data["upgrade_level"]

	if typeof(raw_id) != TYPE_STRING or String(raw_id).strip_edges() == "":
		push_error("upgrade_id inválido: " + str(raw_id))
		return null

	if typeof(raw_type) != TYPE_STRING:
		push_error("upgrade_type deve ser String: " + str(raw_type))
		return null

	var type_name: String = String(raw_type)

	if not UpgradeType.keys().has(type_name):
		push_error("upgrade_type desconhecido: " + type_name)
		return null

	if not _is_integer_number(raw_level) or int(raw_level) < 1:
		push_error("upgrade_level inválido: " + str(raw_level))
		return null
	
	var id: String = String(raw_id)
	var type: UpgradeType = UpgradeType[type_name]
	var level: int = int(raw_level)
	
	return Upgrade.new(id, type, level)


static func _is_integer_number(value: Variant) -> bool:
	if typeof(value) != TYPE_INT and typeof(value) != TYPE_FLOAT:
		return false

	var numeric_value: float = float(value)
	return is_finite(numeric_value) and numeric_value == floor(numeric_value)



func _to_string() -> String:
	return "Upgrade: {id=%s, type=%s, level=%d}" % [upgrade_id, UpgradeType.keys()[upgrade_type], upgrade_level]
