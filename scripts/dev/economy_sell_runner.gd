extends SceneTree

const MAIN_SCENE: PackedScene = preload("res://scenes/Main.tscn")
const CH05_FINAL_STAGE = preload("res://data/stages/ch05_05_stage.tres")
const SaveService = preload("res://scripts/battle/save_service.gd")
const ProgressionData = preload("res://scripts/data/progression_data.gd")

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	if not await _assert_gold_save_load():
		return
	if not await _assert_hunt_gold_commit():
		return
	if not await _assert_equipped_item_sell_flow():
		return
	if not await _assert_inventory_item_sell_flow():
		return
	print("[PASS] economy_sell_runner: gold persistence and equipped/inventory sell flow checks passed.")
	quit(0)

func _assert_gold_save_load() -> bool:
	var svc := SaveService.new()
	root.add_child(svc)
	await process_frame
	var data := ProgressionData.new()
	data.gold = 4321
	svc.save_progression(data, 2)
	var loaded: ProgressionData = svc.load_progression(2)
	if loaded.gold != 4321:
		return _fail("Gold should persist through SaveService save/load.")
	svc.delete_slot(2)
	svc.queue_free()
	await process_frame
	return true

func _assert_hunt_gold_commit() -> bool:
	var main: Node = MAIN_SCENE.instantiate()
	root.add_child(main)
	await process_frame
	await process_frame
	var campaign = main.campaign_controller
	campaign.debug_seed_chapter_camp(&"CH08", 4, CH05_FINAL_STAGE)
	await process_frame
	var progression = campaign._get_progression_data()
	var hunt_ids: Array[StringName] = [&"hunt_lete"]
	progression.unlocked_hunt_ids = hunt_ids
	var before_gold: int = progression.gold
	if not campaign.apply_hunt_victory_to_current_camp(&"hunt_lete"):
		return _fail("Hunt victory integration should succeed in camp mode.")
	if progression.gold != before_gold + 1000:
		return _fail("Hunt gold reward should commit real gold into progression.")
	main.queue_free()
	await process_frame
	return true

func _assert_equipped_item_sell_flow() -> bool:
	var main: Node = MAIN_SCENE.instantiate()
	root.add_child(main)
	await process_frame
	await process_frame
	var campaign = main.campaign_controller
	campaign.debug_unlock_weapon_ids([&"wp_archive_ashblade"])
	campaign.debug_unlock_armor_ids([&"ar_archive_smoke_coat"])
	campaign.debug_unlock_accessory_ids([&"acc_militia_emblem"])
	campaign.debug_seed_chapter_camp(&"CH05", 4, CH05_FINAL_STAGE)
	await process_frame
	await process_frame
	var progression = campaign._get_progression_data()
	var enoch_index: int = _find_party_index(main.campaign_panel.get_snapshot().get("party_details", []), "Enoch")
	if enoch_index == -1:
		return _fail("Economy runner expected Enoch in the CH05 camp roster.")
	main.campaign_panel.select_party_index(enoch_index)
	await process_frame
	campaign.assign_unit_to_sortie(&"ally_enoch")
	await process_frame
	campaign.set_weapon_for_unit(&"ally_enoch", &"wp_archive_ashblade")
	campaign.set_armor_for_unit(&"ally_enoch", &"ar_archive_smoke_coat")
	campaign.set_accessory_for_unit(&"ally_enoch", &"acc_militia_emblem")
	await process_frame
	var before_gold: int = progression.gold
	main.campaign_panel._on_party_weapon_sell_pressed()
	if not bool(main.campaign_panel.get_snapshot().get("sell_confirm_visible", false)):
		return _fail("Weapon sell should open a confirmation dialog before selling.")
	main.campaign_panel.sell_confirm_dialog.confirmed.emit()
	main.campaign_panel._on_party_armor_sell_pressed()
	if not bool(main.campaign_panel.get_snapshot().get("sell_confirm_visible", false)):
		return _fail("Armor sell should open a confirmation dialog before selling.")
	main.campaign_panel.sell_confirm_dialog.confirmed.emit()
	main.campaign_panel._on_party_accessory_sell_pressed()
	if not bool(main.campaign_panel.get_snapshot().get("sell_confirm_visible", false)):
		return _fail("Accessory sell should open a confirmation dialog before selling.")
	main.campaign_panel.sell_confirm_dialog.confirmed.emit()
	await process_frame
	var snapshot: Dictionary = main.campaign_panel.get_snapshot()
	var enoch_entry: Dictionary = _find_party_entry(snapshot.get("party_details", []), "Enoch")
	if String(enoch_entry.get("weapon_slot", "")) != "없음":
		return _fail("Selling equipped weapon should unequip it from the unit.")
	if String(enoch_entry.get("armor_slot", "")) != "없음":
		return _fail("Selling equipped armor should unequip it from the unit.")
	if String(enoch_entry.get("accessory_slot", "")) != "없음":
		return _fail("Selling equipped accessory should unequip it from the unit.")
	if progression.gold <= before_gold:
		return _fail("Selling equipped items should increase progression gold.")
	var inventory_entries: Array = snapshot.get("inventory_entries", [])
	if not _contains_line(inventory_entries, "판매:"):
		return _fail("Camp inventory should log sale results.")
	main.queue_free()
	await process_frame
	return true

func _assert_inventory_item_sell_flow() -> bool:
	var main: Node = MAIN_SCENE.instantiate()
	root.add_child(main)
	await process_frame
	await process_frame
	var campaign = main.campaign_controller
	campaign.debug_unlock_weapon_ids([&"wp_archive_ashblade", &"wp_zero_trace_staff"])
	campaign.debug_unlock_armor_ids([&"ar_archive_smoke_coat", &"ar_greenwood_cloak"])
	campaign.debug_unlock_accessory_ids([&"acc_militia_emblem", &"acc_gatekeeper_ring"])
	campaign.debug_seed_chapter_camp(&"CH05", 4, CH05_FINAL_STAGE)
	await process_frame
	await process_frame
	var progression = campaign._get_progression_data()
	progression.add_owned_item(&"weapon", &"wp_archive_ashblade", 1)
	await process_frame
	var before_gold: int = progression.gold
	main.campaign_panel._select_section(main.campaign_panel.SECTION_INVENTORY)
	await process_frame
	main.campaign_panel._on_inventory_weapon_sell_pressed()
	var weapon_snapshot: Dictionary = main.campaign_panel.get_snapshot()
	if not bool(weapon_snapshot.get("equipment_popup_visible", false)):
		return _fail("Inventory weapon sell should open a stack selection popup when multiple weapon stacks exist.")
	var weapon_labels: Array = weapon_snapshot.get("equipment_popup_labels", [])
	if weapon_labels.is_empty() or String(weapon_labels[0]).find("x") == -1 or String(weapon_labels[0]).find("미장착") == -1:
		return _fail("Inventory weapon stack popup should surface count and equipped state in labels.")
	main.campaign_panel._on_inventory_weapon_popup_id_pressed(0)
	if not bool(main.campaign_panel.get_snapshot().get("sell_confirm_visible", false)):
		return _fail("Inventory weapon popup selection should open a confirmation dialog.")
	main.campaign_panel.sell_confirm_dialog.confirmed.emit()
	main.campaign_panel._on_inventory_armor_sell_pressed()
	if not bool(main.campaign_panel.get_snapshot().get("sell_confirm_visible", false)):
		return _fail("Inventory armor sell should open a confirmation dialog.")
	main.campaign_panel.sell_confirm_dialog.confirmed.emit()
	main.campaign_panel._on_inventory_accessory_sell_pressed()
	if not bool(main.campaign_panel.get_snapshot().get("sell_confirm_visible", false)):
		return _fail("Inventory accessory sell should open a confirmation dialog.")
	main.campaign_panel.sell_confirm_dialog.confirmed.emit()
	await process_frame
	var snapshot: Dictionary = main.campaign_panel.get_snapshot()
	if progression.gold <= before_gold:
		return _fail("Selling unequipped inventory items should increase progression gold.")
	var inventory_entries: Array = snapshot.get("inventory_entries", [])
	if not _contains_line(inventory_entries, "판매:"):
		return _fail("Inventory sale should be reflected in camp inventory entries.")
	main.queue_free()
	await process_frame
	return true

func _find_party_index(party_details: Array, expected_name: String) -> int:
	for index in range(party_details.size()):
		var entry = party_details[index]
		if typeof(entry) == TYPE_DICTIONARY and String(entry.get("name", "")) == expected_name:
			return index
	return -1

func _find_party_entry(party_details: Array, expected_name: String) -> Dictionary:
	for entry in party_details:
		if typeof(entry) == TYPE_DICTIONARY and String(entry.get("name", "")) == expected_name:
			return entry
	return {}

func _contains_line(lines: Array, needle: String) -> bool:
	for line in lines:
		if String(line).find(needle) != -1:
			return true
	return false

func _fail(message: String) -> bool:
	push_error(message)
	quit(1)
	return false
