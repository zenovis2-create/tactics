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
		push_error("Equipment unequip runner could not resolve campaign controller.")
		quit(1)
		return

	campaign.debug_unlock_armor_ids([
		&"ar_greenwood_cloak",
		&"ar_whiteflow_vestment"
	])
	campaign.debug_unlock_weapon_ids([
		&"wp_archive_ashblade",
		&"wp_zero_trace_staff"
	])
	campaign.debug_unlock_accessory_ids([
		&"acc_militia_emblem",
		&"acc_gatekeeper_ring"
	])
	campaign.debug_seed_chapter_camp(&"CH05", 4, CH05_FINAL_STAGE)
	await process_frame
	await process_frame

	var enoch_index: int = _find_party_index(main.campaign_panel.get_snapshot().get("party_details", []), "Enoch")
	if enoch_index == -1:
		push_error("Equipment unequip runner expected Enoch in the CH05 camp roster.")
		quit(1)
		return
	main.campaign_panel.select_party_index(enoch_index)
	await process_frame
	campaign.assign_unit_to_sortie(&"ally_enoch")
	campaign.set_weapon_for_unit(&"ally_enoch", &"wp_zero_trace_staff")
	campaign.set_armor_for_unit(&"ally_enoch", &"ar_whiteflow_vestment")
	campaign.set_accessory_for_unit(&"ally_enoch", &"acc_gatekeeper_ring")
	await process_frame

	main.campaign_panel._on_party_weapon_unequip_pressed()
	main.campaign_panel._on_party_armor_unequip_pressed()
	main.campaign_panel._on_party_accessory_unequip_pressed()
	await process_frame

	var updated_entry: Dictionary = _find_party_entry(main.campaign_panel.get_snapshot().get("party_details", []), "Enoch")
	if String(updated_entry.get("weapon_slot", "")) != "없음":
		push_error("Weapon unequip should clear the camp slot text.")
		quit(1)
		return
	if String(updated_entry.get("armor_slot", "")) != "없음":
		push_error("Armor unequip should clear the camp slot text.")
		quit(1)
		return
	if String(updated_entry.get("accessory_slot", "")) != "없음":
		push_error("Accessory unequip should clear the camp slot text.")
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
		push_error("Equipment unequip runner expected Enoch in battle after camp deploy.")
		quit(1)
		return
	if enoch_unit.get_equipped_weapon() != null:
		push_error("Battle loadout should keep weapon empty after camp unequip.")
		quit(1)
		return
	if enoch_unit.get_equipped_armor() != null:
		push_error("Battle loadout should keep armor empty after camp unequip.")
		quit(1)
		return
	if enoch_unit.get_equipped_accessory() != null:
		push_error("Battle loadout should keep accessory empty after camp unequip.")
		quit(1)
		return

	print("[PASS] equipment_unequip_runner: camp unequip cleared equipment slots before battle deployment.")
	quit(0)

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
