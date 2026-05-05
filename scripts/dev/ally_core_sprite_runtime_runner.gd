extends SceneTree

const UNIT_SCENE: PackedScene = preload("res://scenes/battle/Unit.tscn")
const BattleArtCatalog = preload("res://scripts/battle/battle_art_catalog.gd")

const UNITS := [
	{
		"label": "Rian",
		"unit_id": "ally_rian",
		"display_name": "Rian",
		"anchor": "sprite_anchor_rian",
		"data": preload("res://data/units/ally_rian.tres"),
	},
	{
		"label": "Serin",
		"unit_id": "ally_serin",
		"display_name": "Serin",
		"anchor": "sprite_anchor_serin",
		"data": preload("res://data/units/ally_serin.tres"),
	},
	{
		"label": "Tia",
		"unit_id": "ally_tia",
		"display_name": "Tia",
		"anchor": "sprite_anchor_tia",
		"data": preload("res://data/units/ally_tia.tres"),
	},
	{
		"label": "Bran",
		"unit_id": "ally_bran",
		"display_name": "Bran",
		"anchor": "sprite_anchor_bran",
		"data": preload("res://data/units/ally_bran.tres"),
	},
]

const STATES := ["idle", "move", "attack", "cast", "hit", "guard", "defeat"]
const FACINGS := ["front_right", "front_left", "back_right", "back_left"]


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	for config in UNITS:
		if not _assert_runtime_contract(config):
			return
		if not _assert_catalog_aliases(config):
			return
		if not await _assert_unit_visual_layer(config):
			return

	print("[PASS] ally_core_sprite_runtime_runner validated Rian/Serin/Tia/Bran v02.1 sprite runtimes.")
	quit(0)


func _assert_runtime_contract(config: Dictionary) -> bool:
	var anchor := String(config["anchor"])
	var contract_path := "res://assets/characters/%s/runtime_contract_v02.json" % anchor
	var absolute_contract_path := ProjectSettings.globalize_path(contract_path)
	if not FileAccess.file_exists(absolute_contract_path):
		return _fail("%s should have runtime_contract_v02.json." % config["label"])

	var text := FileAccess.get_file_as_string(contract_path)
	var parsed = JSON.parse_string(text)
	if not (parsed is Dictionary):
		return _fail("%s runtime contract should parse as a dictionary." % config["label"])

	if String(parsed.get("direction_set", "")) != "diagonal_4":
		return _fail("%s runtime contract should use diagonal_4." % config["label"])

	var states: Dictionary = parsed.get("states", {})
	for state in STATES:
		if not states.has(state):
			return _fail("%s runtime contract should include %s state." % [config["label"], state])
		var state_contract: Dictionary = states[state]
		if int(state_contract.get("frame_count", 0)) != 8:
			return _fail("%s %s flat frame_count should be 8." % [config["label"], state])
		var facings: Dictionary = state_contract.get("facings", {})
		for facing in FACINGS:
			if not facings.has(facing):
				return _fail("%s %s should include %s facing." % [config["label"], state, facing])
			if int(facings[facing].get("frame_count", 0)) != 16:
				return _fail("%s %s.%s should declare 16 frames." % [config["label"], state, facing])

		var flat_dir := "res://assets/characters/%s/runtime/%s" % [anchor, state]
		if _count_pngs(flat_dir) != 8:
			return _fail("%s %s flat runtime should contain 8 png frames." % [config["label"], state])

		for facing in FACINGS:
			var facing_dir := "res://assets/characters/%s/runtime/facing_frames/%s/%s" % [anchor, state, facing]
			if _count_pngs(facing_dir) != 16:
				return _fail("%s %s.%s should contain 16 png frames." % [config["label"], state, facing])

	return true


func _assert_catalog_aliases(config: Dictionary) -> bool:
	for lookup_name in [String(config["unit_id"]), String(config["display_name"])]:
		for state in STATES:
			var frames := BattleArtCatalog.load_character_sprite_frames(lookup_name, state)
			if frames.size() != 8:
				return _fail("%s should resolve 8 %s frames via %s, found %d." % [config["label"], state, lookup_name, frames.size()])
	return true


func _assert_unit_visual_layer(config: Dictionary) -> bool:
	var unit = UNIT_SCENE.instantiate()
	root.add_child(unit)
	unit.setup_from_data(config["data"])
	await process_frame

	var art_layer: CanvasItem = unit.get_node_or_null("CharacterVisualRoot")
	if art_layer == null:
		return _fail("%s Unit scene should expose CharacterVisualRoot layer." % config["label"])
	if not art_layer.visible:
		return _fail("%s should show CharacterVisualRoot when sprite frames exist." % config["label"])
	var frames := BattleArtCatalog.load_character_sprite_frames(String(config["unit_id"]), "idle")
	if not frames.has(unit.character_sprite.texture):
		return _fail("%s should render a catalog idle sprite frame." % config["label"])
	if unit.token_art.visible:
		return _fail("%s should hide token art when character sprites exist." % config["label"])

	unit.queue_free()
	await process_frame
	return true


func _count_pngs(dir_path: String) -> int:
	var dir := DirAccess.open(dir_path)
	if dir == null:
		return 0
	var count := 0
	dir.list_dir_begin()
	while true:
		var file_name := dir.get_next()
		if file_name.is_empty():
			break
		if not dir.current_is_dir() and file_name.to_lower().ends_with(".png"):
			count += 1
	dir.list_dir_end()
	return count


func _fail(message: String) -> bool:
	push_error(message)
	quit(1)
	return false
