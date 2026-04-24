extends SceneTree

const META_MENU_SCENE: PackedScene = preload("res://scenes/ui/meta_system_menu.tscn")

class TestEquip:
	extends RefCounted
	var tier: int = 0
	var attack_bonus: int = 2
	var defense_bonus: int = 1
	var movement_bonus: int = 0
	var unit_owner = null
	var enchant_type: String = ""
	var enchant_power: int = 0

class TestUnit:
	extends RefCounted
	var gold: int = 0
	var inventory: Dictionary = {}
	var equipment: Dictionary = {}

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	if not await _assert_meta_menu_scene_loads():
		return
	if not await _assert_forge_upgrade_flow():
		return
	if not await _assert_enchant_flow():
		return
	if not await _assert_reforge_flow():
		return
	print("[PASS] meta_progression_runner: meta forge/enchant/reforge menu flows passed.")
	quit(0)

func _spawn_menu():
	var menu = META_MENU_SCENE.instantiate()
	root.add_child(menu)
	await process_frame
	await process_frame
	return menu

func _build_unit(start_tier: int = 0, gold: int = 0, forge_materials: int = 0) -> TestUnit:
	var unit := TestUnit.new()
	unit.gold = gold
	unit.inventory = {"forge_materials": forge_materials}
	var equip := TestEquip.new()
	equip.tier = start_tier
	equip.unit_owner = unit
	unit.equipment = {"weapon": equip}
	return unit

func _assert_meta_menu_scene_loads() -> bool:
	var menu = await _spawn_menu()
	if menu == null:
		return _fail("MetaSystemMenu scene should instantiate.")
	if menu.result_label == null:
		return _fail("MetaSystemMenu should expose ResultLabel for action feedback.")
	if menu.close_button == null:
		return _fail("MetaSystemMenu should expose CloseButton.")
	menu.queue_free()
	await process_frame
	return true

func _assert_forge_upgrade_flow() -> bool:
	var menu = await _spawn_menu()
	var unit := _build_unit(0, 500, 5)
	menu.open(null, unit)
	menu.selected_slot = "weapon"
	menu._on_forge_pressed()
	await process_frame
	var equip = unit.equipment.get("weapon")
	if equip == null or int(equip.tier) != 1:
		return _fail("Forge action should raise tier 0 weapon to tier 1 when enough gold/material exists.")
	if unit.gold != 300:
		return _fail("Forge action should spend the tier-1 upgrade gold cost.")
	if int(unit.inventory.get("forge_materials", 0)) != 0:
		return _fail("Forge action should spend the required forge materials.")
	if String(menu.result_label.text).find("강화 성공") == -1:
		return _fail("Forge action should surface a readable success result.")
	menu.queue_free()
	await process_frame
	return true

func _assert_enchant_flow() -> bool:
	var menu = await _spawn_menu()
	var unit := _build_unit(1, 800, 0)
	menu.open(null, unit)
	menu.selected_slot = "weapon"
	menu._on_enchant_pressed()
	await process_frame
	var equip = unit.equipment.get("weapon")
	if equip == null or String(equip.enchant_type).is_empty():
		return _fail("Enchant action should apply a default enchant type to tier-1 equipment.")
	if int(equip.enchant_power) != 1:
		return _fail("Enchant action should apply tier-based enchant power.")
	if unit.gold != 500:
		return _fail("Enchant action should spend the tier-1 enchant gold cost.")
	if String(menu.result_label.text).find("인챈트 성공") == -1:
		return _fail("Enchant action should surface a readable success result.")
	menu.queue_free()
	await process_frame
	return true

func _assert_reforge_flow() -> bool:
	var menu = await _spawn_menu()
	var unit := _build_unit(1, 1200, 0)
	menu.open(null, unit)
	menu.selected_slot = "weapon"
	menu._on_reforge_pressed()
	await process_frame
	var equip = unit.equipment.get("weapon")
	if equip == null or int(equip.tier) != 2:
		return _fail("Reforge action should raise tier by 1 when gold is sufficient.")
	if unit.gold != 700:
		return _fail("Reforge action should spend the base reforge gold cost.")
	if String(menu.result_label.text).find("재련 성공") == -1:
		return _fail("Reforge action should surface a readable success result.")
	menu.queue_free()
	await process_frame
	return true

func _fail(message: String) -> bool:
	print("[FAIL] %s" % message)
	quit(1)
	return false
