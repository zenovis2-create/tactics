extends SceneTree

const HeirloomData = preload("res://scripts/data/heirloom_data.gd")
const ProgressionData = preload("res://scripts/data/progression_data.gd")
const SaveService = preload("res://scripts/battle/save_service.gd")
const UnitData = preload("res://scripts/data/unit_data.gd")

var _failed: bool = false

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var save_service := SaveService.new()
	root.add_child(save_service)
	var slot_3 := _seed_slot_three_progression()
	var save_error := save_service.save_progression(slot_3, 3)
	_assert(save_error == OK, "Slot 3 progression seed should save successfully.")
	await process_frame
	var heirloom_service = root.get_node_or_null("Heirloom")
	_assert(heirloom_service != null, "Heirloom autoload should be available at /root/Heirloom.")
	if _failed:
		quit(1)
		return

	var loaded_slot_3 := save_service.load_progression(3)
	_assert(loaded_slot_3.badges_of_heroism == 43, "Slot 3 seed should preserve the 43 badge count.")
	if _failed:
		quit(1)
		return

	var heirloom: HeirloomData = heirloom_service.generate_heirloom(loaded_slot_3)
	_assert(not heirloom.clan_name.is_empty(), "Heirloom generation should resolve a non-empty clan name.")
	_assert(not heirloom.chronicle_summary.is_empty(), "Heirloom generation should resolve a chronicle summary.")
	_assert(not heirloom.curse_units.is_empty(), "Heirloom generation should map at least one cursed unit from the prior run.")
	_assert(heirloom.rescued_fragment_holders.size() == 3, "Heirloom generation should map all three rescued fragment holders.")

	var ng_plus_progression := ProgressionData.new()
	var trainee := _build_unit(&"ally_rian", "Rian", "ally", 20, 6, 3, 4, 1)
	var boss := _build_unit(&"enemy_valgar", "Valgar", "enemy", 30, 8, 4, 3, 1, true)
	ng_plus_progression.unit_progression["ally_rian"] = {
		"level": 1,
		"exp": 0,
		"unit_data": trainee,
	}
	ng_plus_progression.unit_progression["enemy_valgar"] = {
		"level": 1,
		"exp": 0,
		"unit_data": boss,
	}

	heirloom_service.apply_heirloom_to_ngplus(heirloom, ng_plus_progression)

	var ally_bonus: Dictionary = heirloom_service.get_unit_bonus(&"ally_rian")
	var boss_bonus: Dictionary = heirloom_service.get_unit_bonus(&"enemy_valgar")
	_assert(not ally_bonus.is_empty(), "Heirloom bonuses should be applied to ally unit runtime bonuses.")
	_assert(int(boss_bonus.get("attack_percent_mod", 0)) >= 10, "Boss heirloom curse bonus should grant at least +10% attack.")
	_assert(String(ng_plus_progression.encyclopedia_comments.get("player_title", "")).find("clan of") != -1, "NG+ progression should receive the clan title marker.")
	_assert(ng_plus_progression.is_ally_unlocked(&"lete"), "NG+ progression should unlock Lete as an early-join NPC.")
	_assert(ng_plus_progression.is_ally_unlocked(&"mira"), "NG+ progression should unlock Mira as an early-join NPC.")
	_assert(ng_plus_progression.is_ally_unlocked(&"melkion"), "NG+ progression should unlock Melkion as an early-join NPC.")

	if _failed:
		quit(1)
		return
	print("[PASS] heirloom_legacy_runner validated generation, inheritance, curses, and clan bonuses.")
	quit(0)

func _seed_slot_three_progression() -> ProgressionData:
	var progression := ProgressionData.new()
	progression.badges_of_heroism = 43
	progression.earned_badges = [
		"stage_clear:CH01_05:three_star",
		"stage_clear:CH02_05:three_star",
		"stage_clear:CH03_05:three_star",
		"stage_clear:CH04_05:three_star",
		"stage_clear:CH05_05:three_star",
		"stage_clear:CH06_05:three_star",
		"stage_clear:CH07_05:three_star",
		"stage_clear:CH08_05:three_star",
		"stage_clear:CH09A_05:three_star",
		"stage_clear:CH09B_05:three_star",
		"stage_clear:CH10_05:three_star",
		"ending:true_resolution"
	]
	progression.ledger_count = 5
	progression.world_timeline_id = "A"
	progression.choices_made = [
		"CH05_CAMP:ch05_save_ledgers",
		"CH07_INTERLUDE:ch07_believe_mira",
		"CH08_PRE_BOSS:ch08_accept_lete",
		"CH09A_CAMP:ch09a_public_testimony",
		"CH10_PRE_FINALE:ch10_name_the_fallen"
	]
	progression.worldview_fragments = ["lete", "mira", "melkion"]
	progression.worldview_complete = true
	progression.unlock_ally(&"lete")
	progression.unlock_ally(&"mira")
	progression.unlock_ally(&"melkion")
	progression.sacrificed_units = [
		{"unit_id": "ally_serin", "name": "Serin", "epitaph": "She held the bridge lantern high enough for the squad to cross."}
	]
	progression.battle_records = [
		{"stage_id": "CH01_05", "result": "victory", "ally_deaths": 0, "enemy_deaths": 4},
		{"stage_id": "CH05_05", "result": "victory", "ally_deaths": 1, "enemy_deaths": 6},
		{"stage_id": "CH10_05", "result": "victory", "ally_deaths": 0, "enemy_deaths": 1}
	]
	progression.support_progress_by_pair = {
		"ally_rian|ally_tia": {"milestone_rank": 4, "battles_together": 6},
		"ally_rian|ally_noah": {"milestone_rank": 6, "battles_together": 8}
	}
	return progression

func _build_unit(unit_id: StringName, display_name: String, faction: String, max_hp: int, attack: int, defense: int, movement: int, attack_range: int, is_boss: bool = false) -> UnitData:
	var unit_data := UnitData.new()
	unit_data.unit_id = unit_id
	unit_data.display_name = display_name
	unit_data.faction = faction
	unit_data.max_hp = max_hp
	unit_data.attack = attack
	unit_data.defense = defense
	unit_data.movement = movement
	unit_data.attack_range = attack_range
	unit_data.is_boss = is_boss
	return unit_data

func _assert(condition: bool, message: String) -> void:
	if condition:
		return
	_failed = true
	push_error(message)
