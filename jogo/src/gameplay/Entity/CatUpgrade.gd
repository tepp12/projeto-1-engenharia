class_name CatUpgrade
extends RefCounted

enum CatUpgradeType {
	AUTOMATION
}

var _cat_upgrade_id: String
var _cat_upgrade_type: CatUpgradeType
var _cat_upgrade_level: int
var cat_id: String

var cat_upgrade_id: String:
	get:
		return _cat_upgrade_id

var cat_upgrade_type: CatUpgradeType:
	get:
		return _cat_upgrade_type

var cat_upgrade_level: int:
	get:
		return _cat_upgrade_level


func _init(id: String, upgrade_type: CatUpgradeType, level: int, cat: String) -> void:
	assert(id.strip_edges() != "", "cat_upgrade_id não pode ser vazio")
	assert(cat.strip_edges() != "", "cat_id não pode ser vazio")
	assert(level >= 1, "cat_upgrade_level deve ser no mínimo 1")

	_cat_upgrade_id = id
	_cat_upgrade_type = upgrade_type
	_cat_upgrade_level = level
	cat_id = cat


func to_dict() -> Dictionary:
	return {
		"cat_upgrade_id": cat_upgrade_id,
		"cat_id": cat_id,
		"cat_upgrade_type": CatUpgradeType.keys()[cat_upgrade_type],
		"cat_upgrade_level": cat_upgrade_level
	}


static func from_dict(data: Dictionary) -> CatUpgrade:
	if not data.has("cat_upgrade_id") or not data.has(
		"cat_upgrade_type") or not data.has("cat_upgrade_level") or not data.has("cat_id"):
		push_error("Dados de cat upgrade incompletos: " + str(data))
		return null

	var raw_cat_upgrade_id: Variant = data["cat_upgrade_id"]
	var raw_cat_upgrade_type: Variant = data["cat_upgrade_type"]
	var raw_cat_upgrade_level: Variant = data["cat_upgrade_level"]
	var raw_cat_id: Variant = data["cat_id"]

	if typeof(raw_cat_upgrade_id) != TYPE_STRING or String(raw_cat_upgrade_id).strip_edges() == "":
		push_error("cat_upgrade_id inválido: " + str(raw_cat_upgrade_id))
		return null
	if typeof(raw_cat_id) != TYPE_STRING or String(raw_cat_id).strip_edges() == "":
		push_error("cat_id inválido: " + str(raw_cat_id))
		return null
	if typeof(raw_cat_upgrade_type) != TYPE_STRING:
		push_error("cat_upgrade_type deve ser String: " + str(raw_cat_upgrade_type))
		return null

	var type_name: String = String(raw_cat_upgrade_type)
	if not CatUpgradeType.keys().has(type_name):
		push_error("cat_upgrade_type desconhecido: " + type_name)
		return null
	if not _is_integer_number(raw_cat_upgrade_level) or int(raw_cat_upgrade_level) < 1:
		push_error("cat_upgrade_level inválido: " + str(raw_cat_upgrade_level))
		return null

	var id: String = String(raw_cat_upgrade_id)
	var cat: String = String(raw_cat_id)
	var upgrade_type: CatUpgradeType = CatUpgradeType[type_name]
	var level: int = int(raw_cat_upgrade_level)

	return CatUpgrade.new(id, upgrade_type, level, cat)


static func _is_integer_number(value: Variant) -> bool:
	if typeof(value) != TYPE_INT and typeof(value) != TYPE_FLOAT:
		return false

	var numeric_value: float = float(value)
	return is_finite(numeric_value) and numeric_value == floor(numeric_value)


func _to_string() -> String:
	return "CatUpgrade: {id=%s, cat_id=%s, type=%s, level=%d}" % [cat_upgrade_id, cat_id, CatUpgradeType.keys()[cat_upgrade_type], cat_upgrade_level]
