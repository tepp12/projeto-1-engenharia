class_name GameState
extends RefCounted

const CURRENT_SAVE_VERSION: int = 1
const DEFAULT_PARK_NAME: String = "Parque do Jogador"

var _park_name: String = DEFAULT_PARK_NAME
var _food: int = 0
var _total_food_earned: int = 0
var _click_power: int = 1
var _cats: Array[Cat] = []
var _cat_upgrades: Array[CatUpgrade] = []
var _upgrades: Array[Upgrade] = []

var save_version: int:
	get:
		return CURRENT_SAVE_VERSION

var park_name: String:
	get:
		return _park_name

var food: int:
	get:
		return _food

var total_food_earned: int:
	get:
		return _total_food_earned

var click_power: int:
	get:
		return _click_power

var cats: Array[Cat]:
	get:
		return _cats.duplicate()

var cat_upgrades: Array[CatUpgrade]:
	get:
		return _cat_upgrades.duplicate()

var upgrades: Array[Upgrade]:
	get:
		return _upgrades.duplicate()


func earn_food(amount: int) -> bool:
	if amount <= 0:
		push_error("A quantidade de ração recebida deve ser maior que zero")
		return false

	_food += amount
	_total_food_earned += amount
	return true


func rename_park(new_name: String) -> bool:
	var normalized_name: String = new_name.strip_edges()
	if normalized_name.is_empty():
		push_error("O nome do parque não pode ser vazio")
		return false

	_park_name = normalized_name
	return true


func to_dict() -> Dictionary:
	var serialized_cats: Array[Dictionary] = []
	for cat: Cat in _cats:
		serialized_cats.append(cat.to_dict())

	var serialized_cat_upgrades: Array[Dictionary] = []
	for cat_upgrade: CatUpgrade in _cat_upgrades:
		serialized_cat_upgrades.append(cat_upgrade.to_dict())

	var serialized_upgrades: Array[Dictionary] = []
	for upgrade: Upgrade in _upgrades:
		serialized_upgrades.append(upgrade.to_dict())

	return {
		"save_version": save_version,
		"park_name": park_name,
		"food": food,
		"total_food_earned": total_food_earned,
		"click_power": click_power,
		"cats": serialized_cats,
		"cat_upgrades": serialized_cat_upgrades,
		"upgrades": serialized_upgrades
	}


static func from_dict(data: Dictionary) -> GameState:
	var required_fields: Array[String] = [
		"save_version",
		"park_name",
		"food",
		"total_food_earned",
		"click_power",
		"cats",
		"cat_upgrades",
		"upgrades"
	]
	for field: String in required_fields:
		if not data.has(field):
			push_error("GameState sem o campo obrigatório: " + field)
			return null

	var raw_save_version: Variant = data["save_version"]
	var raw_park_name: Variant = data["park_name"]
	var raw_food: Variant = data["food"]
	var raw_total_food_earned: Variant = data["total_food_earned"]
	var raw_click_power: Variant = data["click_power"]
	var raw_cats: Variant = data["cats"]
	var raw_cat_upgrades: Variant = data["cat_upgrades"]
	var raw_upgrades: Variant = data["upgrades"]

	if not _is_integer_number(raw_save_version) or int(raw_save_version) != CURRENT_SAVE_VERSION:
		push_error("save_version incompatível: " + str(raw_save_version))
		return null
	if typeof(raw_park_name) != TYPE_STRING or String(raw_park_name).strip_edges().is_empty():
		push_error("park_name inválido: " + str(raw_park_name))
		return null
	if not _is_integer_number(raw_food) or int(raw_food) < 0:
		push_error("food inválido: " + str(raw_food))
		return null
	if not _is_integer_number(raw_total_food_earned) or int(raw_total_food_earned) < 0:
		push_error("total_food_earned inválido: " + str(raw_total_food_earned))
		return null
	if int(raw_total_food_earned) < int(raw_food):
		push_error("total_food_earned não pode ser menor que food")
		return null
	if not _is_integer_number(raw_click_power) or int(raw_click_power) <= 0:
		push_error("click_power inválido: " + str(raw_click_power))
		return null
	if typeof(raw_cats) != TYPE_ARRAY or typeof(raw_cat_upgrades) != TYPE_ARRAY or typeof(raw_upgrades) != TYPE_ARRAY:
		push_error("As coleções do GameState devem ser arrays")
		return null

	var restored_cats: Array[Cat] = []
	var cat_ids: Dictionary = {}
	for raw_cat: Variant in raw_cats:
		if typeof(raw_cat) != TYPE_DICTIONARY:
			push_error("Item inválido em cats: " + str(raw_cat))
			return null
		var cat_data: Dictionary = raw_cat
		var restored_cat: Cat = Cat.from_dict(cat_data)
		if restored_cat == null:
			return null
		if cat_ids.has(restored_cat.cat_id):
			push_error("cat_id duplicado no GameState: " + restored_cat.cat_id)
			return null
		cat_ids[restored_cat.cat_id] = true
		restored_cats.append(restored_cat)

	var restored_cat_upgrades: Array[CatUpgrade] = []
	var cat_upgrade_ids: Dictionary = {}
	for raw_cat_upgrade: Variant in raw_cat_upgrades:
		if typeof(raw_cat_upgrade) != TYPE_DICTIONARY:
			push_error("Item inválido em cat_upgrades: " + str(raw_cat_upgrade))
			return null
		var cat_upgrade_data: Dictionary = raw_cat_upgrade
		var restored_cat_upgrade: CatUpgrade = CatUpgrade.from_dict(cat_upgrade_data)
		if restored_cat_upgrade == null:
			return null
		if cat_upgrade_ids.has(restored_cat_upgrade.cat_upgrade_id):
			push_error("cat_upgrade_id duplicado no GameState: " + restored_cat_upgrade.cat_upgrade_id)
			return null
		if not cat_ids.has(restored_cat_upgrade.cat_id):
			push_error("CatUpgrade referencia um cat_id inexistente: " + restored_cat_upgrade.cat_id)
			return null
		cat_upgrade_ids[restored_cat_upgrade.cat_upgrade_id] = true
		restored_cat_upgrades.append(restored_cat_upgrade)

	var restored_upgrades: Array[Upgrade] = []
	var upgrade_ids: Dictionary = {}
	for raw_upgrade: Variant in raw_upgrades:
		if typeof(raw_upgrade) != TYPE_DICTIONARY:
			push_error("Item inválido em upgrades: " + str(raw_upgrade))
			return null
		var upgrade_data: Dictionary = raw_upgrade
		var restored_upgrade: Upgrade = Upgrade.from_dict(upgrade_data)
		if restored_upgrade == null:
			return null
		if upgrade_ids.has(restored_upgrade.upgrade_id):
			push_error("upgrade_id duplicado no GameState: " + restored_upgrade.upgrade_id)
			return null
		upgrade_ids[restored_upgrade.upgrade_id] = true
		restored_upgrades.append(restored_upgrade)

	var restored_state: GameState = GameState.new()
	restored_state._park_name = String(raw_park_name).strip_edges()
	restored_state._food = int(raw_food)
	restored_state._total_food_earned = int(raw_total_food_earned)
	restored_state._click_power = int(raw_click_power)
	restored_state._cats = restored_cats
	restored_state._cat_upgrades = restored_cat_upgrades
	restored_state._upgrades = restored_upgrades
	return restored_state


static func _is_number(value: Variant) -> bool:
	return typeof(value) == TYPE_INT or typeof(value) == TYPE_FLOAT


static func _is_integer_number(value: Variant) -> bool:
	if not _is_number(value):
		return false

	var numeric_value: float = float(value)
	return is_finite(numeric_value) and numeric_value == floor(numeric_value)
