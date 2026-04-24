extends SceneTree

const MAIN_SCENE: PackedScene = preload("res://scenes/Main.tscn")
const CH05_FINAL_STAGE = preload("res://data/stages/ch05_05_stage.tres")

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var main: Node = MAIN_SCENE.instantiate()
	root.add_child(main)

	await process_frame
	await process_frame

	var campaign = main.campaign_controller
	if campaign == null:
		push_error("Equipment direct select runner could not resolve campaign controller.")
		quit(1)
		return

	campaign.debug_unlock_armor_ids([
		&"ar_greenwood_cloak",
		&"ar_whiteflow_vestment",
		&"ar_archive_smoke_coat"
	])
	campaign.debug_unlock_weapon_ids([
		&"wp_archive_ashblade",
		&"wp_zero_trace_staff",
		&"wp_valtor_command_lance"
	])
	campaign.debug_unlock_accessory_ids([
		&"acc_militia_emblem",
		&"acc_broken_captain_seal",
		&"acc_gatekeeper_ring",
		&"acc_hardren_iron_crest"
	])
	campaign.debug_seed_chapter_camp(&"CH05", 4, CH05_FINAL_STAGE)
	await process_frame
	await process_frame

	var enoch_index: int = _find_party_index(main.campaign_panel.get_snapshot().get("party_details", []), "Enoch")
	if enoch_index == -1:
		push_error("Equipment direct select runner expected Enoch in the CH05 camp roster.")
		quit(1)
		return
	main.campaign_panel.select_party_index(enoch_index)
	await process_frame
	campaign.assign_unit_to_sortie(&"ally_enoch")
	await process_frame

	var chosen_weapon_label := await _select_popup_option(main.campaign_panel, "weapon")
	var chosen_armor_label := await _select_popup_option(main.campaign_panel, "armor")
	var chosen_accessory_label := await _select_popup_option(main.campaign_panel, "accessory")

	var updated_entry: Dictionary = _find_party_entry(main.campaign_panel.get_snapshot().get("party_details", []), "Enoch")
	if String(updated_entry.get("weapon_slot", "")) != chosen_weapon_label:
		push_error("Weapon direct selection should apply %s, got %s." % [chosen_weapon_label, String(updated_entry.get("weapon_slot", ""))])
		quit(1)
		return
	if String(updated_entry.get("armor_slot", "")) != chosen_armor_label:
		push_error("Armor direct selection should apply %s, got %s." % [chosen_armor_label, String(updated_entry.get("armor_slot", ""))])
		quit(1)
		return
	if String(updated_entry.get("accessory_slot", "")) != chosen_accessory_label:
		push_error("Accessory direct selection should apply %s, got %s." % [chosen_accessory_label, String(updated_entry.get("accessory_slot", ""))])
		quit(1)
		return

	main.advance_campaign_step()
	await process_frame
	await process_frame
	main.advance_campaign_step()
	await process_frame
	await process_frame

	var battle = main.battle_controller
	var enoch_unit = _find_battle_unit(battle.ally_units, "Enoch")
	if enoch_unit == null:
		push_error("Equipment direct select runner expected Enoch in battle after camp deploy.")
		quit(1)
		return
	if enoch_unit.get_equipped_weapon() == null or enoch_unit.get_equipped_weapon().display_name != chosen_weapon_label:
		push_error("Battle loadout should preserve direct-selected weapon.")
		quit(1)
		return
	if enoch_unit.get_equipped_armor() == null or enoch_unit.get_equipped_armor().display_name != chosen_armor_label:
		push_error("Battle loadout should preserve direct-selected armor.")
		quit(1)
		return
	if enoch_unit.get_equipped_accessory() == null or enoch_unit.get_equipped_accessory().display_name != chosen_accessory_label:
		push_error("Battle loadout should preserve direct-selected accessory.")
		quit(1)
		return

	print("[PASS] equipment_direct_select_runner: popup-based direct equipment selection carried from camp into battle.")
	quit(0)

func _select_popup_option(panel, slot_kind: String) -> String:
	match slot_kind:
		"weapon":
			panel._on_party_weapon_pressed()
		"armor":
			panel._on_party_armor_pressed()
		"accessory":
			panel._on_party_accessory_pressed()
	await process_frame

	var snapshot: Dictionary = panel.get_snapshot()
	if String(snapshot.get("equipment_popup_slot", "")) != slot_kind:
		push_error("%s popup should be active after pressing the select button." % slot_kind)
		quit(1)
		return ""
	var labels: Array = snapshot.get("equipment_popup_labels", [])
	if labels.is_empty():
		push_error("%s popup should expose at least one selectable option." % slot_kind)
		quit(1)
		return ""
	var option_index: int = labels.size() - 1
	var chosen_label: String = String(labels[option_index])
	match slot_kind:
		"weapon":
			panel._on_weapon_popup_id_pressed(option_index)
		"armor":
			panel._on_armor_popup_id_pressed(option_index)
		"accessory":
			panel._on_accessory_popup_id_pressed(option_index)
	await process_frame
	return chosen_label

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

func _find_battle_unit(units: Array, expected_name: String):
	for unit in units:
		if unit == null or not is_instance_valid(unit) or unit.unit_data == null:
			continue
		if unit.unit_data.display_name == expected_name:
			return unit
	return null
