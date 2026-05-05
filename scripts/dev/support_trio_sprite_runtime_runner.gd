extends SceneTree

const UNIT_SCENE: PackedScene = preload("res://scenes/battle/Unit.tscn")
const BattleArtCatalog = preload("res://scripts/battle/battle_art_catalog.gd")

const UNITS := [
	{
		"label": "Enoch",
		"unit_id": "ally_enoch",
		"display_name": "Enoch",
		"anchor": "sprite_anchor_enoch",
		"data": preload("res://data/units/ally_enoch.tres"),
		"aliases": ["ally_enoch", "Enoch"],
	},
	{
		"label": "Kyle",
		"unit_id": "ally_kyle",
		"display_name": "Kyle",
		"anchor": "sprite_anchor_kyle",
		"data": preload("res://data/units/ally_kyle.tres"),
		"aliases": ["ally_kyle", "ally_karl", "Kyle"],
	},
	{
		"label": "Noah",
		"unit_id": "ally_noah",
		"display_name": "Noah",
		"anchor": "sprite_anchor_noah",
		"data": preload("res://data/units/ally_noah.tres"),
		"aliases": ["ally_noah", "Noah"],
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

	print("[PASS] support_trio_sprite_runtime_runner validated Enoch/Kyle/Noah v02.1 sprite runtimes.")
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
	for lookup_name in config["aliases"]:
		for state in STATES:
			var frames := BattleArtCatalog.load_character_sprite_frames(String(lookup_name), state)
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
