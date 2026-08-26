extends SceneTree


func _init() -> void:
	var source_data: Dictionary = {
		"save_version": GameState.CURRENT_SAVE_VERSION,
		"park_name": "Parque de Teste",
		"food": 25.5,
		"total_food_earned": 40.0,
		"click_power": 2.5,
		"cats": [
			{
				"cat_id": "cat-1",
				"cat_type": "default",
				"name": "Mingau",
				"appearance_id": "default",
				"status": "ATIVO"
			}
		],
		"cat_upgrades": [
			{
				"cat_upgrade_id": "cat-upgrade-1",
				"cat_id": "cat-1",
				"cat_upgrade_type": "AUTOMATION",
				"cat_upgrade_level": 1
			}
		],
		"upgrades": [
			{
				"upgrade_id": "upgrade-1",
				"upgrade_type": "CLICK_POWER",
				"upgrade_level": 1
			}
		]
	}

	var initial_state: GameState = GameState.from_dict(source_data)
	if initial_state == null:
		_fail("Não foi possível criar o estado inicial")
		return

	var json_text: String = JSON.stringify(initial_state.to_dict())
	var parsed_data: Variant = JSON.parse_string(json_text)
	if typeof(parsed_data) != TYPE_DICTIONARY:
		_fail("O JSON serializado não foi reconstruído como Dictionary")
		return

	var parsed_dictionary: Dictionary = parsed_data
	var restored_state: GameState = GameState.from_dict(parsed_dictionary)
	if restored_state == null:
		_fail("Não foi possível reconstruir o estado serializado")
		return
	if restored_state.to_dict() != initial_state.to_dict():
		_fail("O estado reconstruído é diferente do estado original")
		return

	print("GameState round-trip: OK")
	quit(0)


func _fail(message: String) -> void:
	push_error(message)
	quit(1)
