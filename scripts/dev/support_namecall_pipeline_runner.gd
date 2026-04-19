extends SceneTree

const BattleController = preload("res://scripts/battle/battle_controller.gd")
const CampaignController = preload("res://scripts/campaign/campaign_controller.gd")
const CampaignShellDialogueCatalog = preload("res://scripts/campaign/campaign_shell_dialogue_catalog.gd")
const ProgressionData = preload("res://scripts/data/progression_data.gd")
const StageData = preload("res://scripts/data/stage_data.gd")
const SupportConversations = preload("res://data/support_conversations.gd")
const UnitData = preload("res://scripts/data/unit_data.gd")

const BATTLE_SCENE: PackedScene = preload("res://scenes/battle/BattleScene.tscn")
const CAMPAIGN_PANEL_SCENE: PackedScene = preload("res://scenes/campaign/CampaignPanel.tscn")

const STAGE_IDS: Array[StringName] = [
	&"CH01_05",
	&"CH02_05",
	&"CH03_05",
	&"CH04_05",
	&"CH05_05",
	&"CH06_05",
	&"CH07_05",
	&"CH08_05",
	&"CH09A_05",
	&"CH10_05"
]

const SUPPORT_PAIRS: Array[String] = [
	"rian_serin",
	"rian_bran",
	"rian_tia",
	"rian_enoch",
	"rian_karl",
	"rian_noah"
]

var _assertions: int = 0
var _failed: bool = false

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	if not _assert_support_catalog_coverage():
		return
	if not await _assert_support_rank_progression_and_result_screen():
		return
	if not await _assert_support_persistence_round_trip():
		return
	if not await _assert_ch10_s_rank_name_call():
		return

	print("[PASS] support_namecall_pipeline_runner: %d assertions passed" % _assertions)
	quit(0)

func _assert_support_catalog_coverage() -> bool:
	for pair_id in SUPPORT_PAIRS:
		for rank in [1, 2, 3, 4]:
			var conversation := SupportConversations.get_conversation(pair_id, rank)
			if conversation.is_empty():
				return _fail("SupportConversations must define %s rank %d" % [pair_id, rank])
		for rank in [1, 2, 3]:
			var catalog_line := CampaignShellDialogueCatalog.get_support_dialogue(pair_id, rank)
			if catalog_line.is_empty():
				return _fail("CampaignShellDialogueCatalog must expose %s rank %d dialogue" % [pair_id, rank])
	_assertions += 1
	return true

func _assert_support_rank_progression_and_result_screen() -> bool:
	var battle: BattleController = BATTLE_SCENE.instantiate() as BattleController
	var panel = CAMPAIGN_PANEL_SCENE.instantiate()
	var campaign := CampaignController.new()
	root.add_child(battle)
	root.add_child(panel)
	root.add_child(campaign)
	campaign.setup(battle, panel)
	await process_frame
	await process_frame

	for battle_index in range(STAGE_IDS.size()):
		var stage_id: StringName = STAGE_IDS[battle_index]
		var stage := _make_serin_stage(stage_id)
		battle.set_stage(stage)
		await process_frame
		await process_frame
		battle.last_result_summary = _make_base_result_summary(stage_id)
		battle.hud.show_result_screen(battle.last_result_summary)
		campaign._commit_stage_rewards(stage)
		campaign.debug_queue_support_rolls([0.0 if battle_index + 1 in [3, 6, 10] else 0.99])
		campaign._process_post_battle_supports(stage)

		var support_rank: int = battle.bond_service.get_support_rank(&"ally_rian", &"ally_serin")
		if battle_index + 1 == 3 and support_rank != 1:
			_cleanup_nodes([campaign, panel, battle])
			return _fail("After 3 battles, Rian + Serin should be at C-rank support")
		if battle_index + 1 == 6 and support_rank != 2:
			_cleanup_nodes([campaign, panel, battle])
			return _fail("After 6 battles, Rian + Serin should be at B-rank support")
		if battle_index + 1 == 10 and support_rank != 3:
			_cleanup_nodes([campaign, panel, battle])
			return _fail("After 10 battles, Rian + Serin should be at A-rank support")

		var hud_snapshot: Dictionary = battle.hud.get_result_snapshot()
		var result_body := String(hud_snapshot.get("body", ""))
		if battle_index + 1 == 3 and result_body.find("border trail") == -1:
			_cleanup_nodes([campaign, panel, battle])
			return _fail("The C-rank Serin conversation should appear on the result surface after battle 3")
		if battle_index + 1 == 6 and result_body.find("worth protecting") == -1:
			_cleanup_nodes([campaign, panel, battle])
			return _fail("The B-rank Serin conversation should appear on the result surface after battle 6")
		if battle_index + 1 == 10 and result_body.find("I'm staying") == -1:
			_cleanup_nodes([campaign, panel, battle])
			return _fail("The A-rank Serin conversation should appear on the result surface after battle 10")

	_cleanup_nodes([campaign, panel, battle])
	_assertions += 1
	return true

func _assert_support_persistence_round_trip() -> bool:
	var progression := ProgressionData.new()
	var battle: BattleController = BATTLE_SCENE.instantiate() as BattleController
	root.add_child(battle)
	await process_frame
	await process_frame
	for _index in range(10):
		battle.bond_service.register_shared_battle(&"ally_rian", &"ally_serin")
	battle.bond_service.export_to_progression(progression)
	var restored: BattleController = BATTLE_SCENE.instantiate() as BattleController
	root.add_child(restored)
	await process_frame
	await process_frame
	restored.bond_service.load_from_progression(progression)
	if restored.bond_service.get_support_rank(&"ally_rian", &"ally_serin") != 3:
		_cleanup_nodes([restored, battle])
		return _fail("Support rank should persist through ProgressionData export/load")
	_cleanup_nodes([restored, battle])
	_assertions += 1
	return true

func _assert_ch10_s_rank_name_call() -> bool:
	var battle: BattleController = BATTLE_SCENE.instantiate() as BattleController
	root.add_child(battle)
	await process_frame
	await process_frame
	var stage := _make_serin_stage(&"CH10_05", true)
	battle.set_stage(stage)
	await process_frame
	await process_frame
	var pair_id := SupportConversations.get_pair_id("ally_rian", "ally_serin")
	battle.bond_service.support_ranks[pair_id] = 4
	if battle.enemy_units.is_empty():
		_cleanup_nodes([battle])
		return _fail("CH10 S-rank test requires the final boss to spawn")
	var boss = battle.enemy_units[0]
	battle._check_boss_special_events(boss, 75.0)
	var name_call_snapshot: Dictionary = battle.get_last_name_call_snapshot()
	var expected_line := SupportConversations.get_conversation("rian_serin", 4)
	if String(name_call_snapshot.get("line", "")) != expected_line:
		_cleanup_nodes([battle])
		return _fail("CH10 S-rank ally should fire the Serin-specific Name Call line")
	if String(name_call_snapshot.get("speaker_id", "")) != "ally_serin":
		_cleanup_nodes([battle])
		return _fail("CH10 S-rank Name Call should be attributed to ally_serin")
	_cleanup_nodes([battle])
	_assertions += 1
	return true

func _make_serin_stage(stage_id: StringName, include_karon: bool = false) -> StageData:
	var stage := StageData.new()
	stage.stage_id = stage_id
	stage.stage_title = String(stage_id)
	stage.grid_size = Vector2i(8, 8)
	stage.cell_size = Vector2i(64, 64)
	stage.win_condition = &"defeat_all_enemies"
	stage.ally_units = [
		_make_unit_data(&"ally_rian", "Rian", "ally", 18, 6, 2, 4, 1),
		_make_unit_data(&"ally_serin", "Serin", "ally", 16, 5, 2, 4, 1)
	]
	stage.ally_spawns = [Vector2i(1, 6), Vector2i(2, 6)]
	if include_karon:
		stage.enemy_units = [_make_karon_boss_data()]
		stage.enemy_spawns = [Vector2i(5, 1)]
	else:
		stage.enemy_units = [_make_unit_data(&"enemy_raider", "Raider", "enemy", 8, 3, 0, 3, 1)]
		stage.enemy_spawns = [Vector2i(5, 1)]
	return stage

func _make_base_result_summary(stage_id: StringName) -> Dictionary:
	return {
		"outcome": "victory",
		"title": "Victory",
		"stage_id": String(stage_id),
		"objective": "Defeat all enemies.",
		"reward_entries": [],
		"unit_exp_results": [],
		"memory_entries": [],
		"evidence_entries": [],
		"letter_entries": [],
		"fragment_id": "",
		"command_unlocked": "",
		"recovered_fragment_ids": [],
		"unlocked_command_ids": [],
		"support_attack_count": 0,
		"supporter_bond_level": 0,
		"support_conversations": [],
		"name_call_line": "",
		"name_call_speaker": "",
		"burden_delta": 0,
		"trust_delta": 0,
	}

func _make_unit_data(unit_id: StringName, display_name: String, faction: String, max_hp: int, attack: int, defense: int, movement: int, attack_range: int) -> UnitData:
	var unit_data := UnitData.new()
	unit_data.unit_id = unit_id
	unit_data.display_name = display_name
	unit_data.faction = faction
	unit_data.max_hp = max_hp
	unit_data.attack = attack
	unit_data.defense = defense
	unit_data.movement = movement
	unit_data.attack_range = attack_range
	return unit_data

func _make_karon_boss_data() -> UnitData:
	var unit_data := _make_unit_data(&"enemy_karon_final", "Karuon", "enemy", 30, 8, 3, 4, 1)
	unit_data.is_boss = true
	unit_data.boss_pattern = &"karon_final_ch10_05"
	return unit_data

func _cleanup_nodes(nodes: Array) -> void:
	for node in nodes:
		if node != null and is_instance_valid(node):
			node.queue_free()
	await process_frame

func _fail(message: String) -> bool:
	print("[FAIL] %s" % message)
	_failed = true
	quit(1)
	return false
