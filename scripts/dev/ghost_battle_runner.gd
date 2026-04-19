extends SceneTree

# Ghost Battle Runner — Headless verification
# Verifies: GhostFormationData, GhostFormationExtractor, GhostBattleManager
# Run: godot --headless --path . --script scripts/dev/ghost_battle_runner.gd

const PASS := "✅ PASS"
const FAIL := "❌ FAIL"

const GhostFormationDataRef = preload("res://scripts/data/ghost_formation_data.gd")
const GhostFormationExtractorRef = preload("res://scripts/battle/ghost_formation_extractor.gd")
const GhostBattleManagerRef = preload("res://scripts/battle/ghost_battle_manager.gd")
const ChronicleGeneratorRef = preload("res://scripts/battle/chronicle_generator.gd")
const ChronicleEntryRef = preload("res://scripts/battle/chronicle_entry.gd")

var tests_run: int = 0
var tests_passed: int = 0
var tests_failed: int = 0
var _owned_nodes: Array[Node] = []
var _owned_refs: Array[RefCounted] = []

func _initialize() -> void:
	print("\n=== Ghost Battle Runner ===\n")
	run_tests()
	_cleanup_owned_nodes()
	print_results()
	quit(0 if tests_failed == 0 else 1)

func run_tests() -> void:
	test_ghost_formation_data()
	test_ghost_formation_extractor()
	test_extract_ghost_pattern_from_chronicle()
	test_ghost_formation_factory_from_chronicle()
	test_ghost_battle_manager()
	test_ghost_battle_registry_count()
	test_get_ghosts_by_chapter()
	test_champion_board_ranking()
	test_anonymous_vs_named_ghost()

func verify(condition: bool, test_name: String, detail: String = "") -> void:
	tests_run += 1
	if condition:
		tests_passed += 1
		print("[%s] %s" % [PASS, test_name])
		if not detail.is_empty():
			print("       └─ %s" % detail)
	else:
		tests_failed += 1
		print("[%s] %s" % [FAIL, test_name])
		if not detail.is_empty():
			print("       └─ %s" % detail)

func test_ghost_formation_data() -> void:
	if GhostFormationDataRef == null:
		tests_failed += 1
		print("[%s] GhostFormationData class failed to load" % FAIL)
		return
	verify(true, "GhostFormationData class loads")

	var ghost: GhostFormationDataRef = GhostFormationDataRef.new()
	verify(ghost != null, "GhostFormationData instantiates")
	verify(ghost.ghost_id == &"", "Default ghost_id is empty")
	verify(ghost.is_anonymous == true, "is_anonymous defaults to true")
	verify(ghost.avg_turns == 0.0, "Default avg_turns is 0.0")
	verify(ghost.difficulty_rating == 1, "Default difficulty_rating is 1")

	ghost.is_anonymous = true
	ghost.player_tag = "TestPlayer"
	verify(ghost.get_display_name() == "Unknown Commander's Strategy", "Anonymous ghost returns unknown name")

	ghost.is_anonymous = false
	ghost.player_tag = "Serin"
	verify(ghost.get_display_name() == "Serin's Strategy", "Named ghost returns player name")

	ghost.avg_turns = 12.0
	verify(ghost.get_turns_display() == "12 turns", "get_turns_display() returns turns")

	ghost.difficulty_rating = 3
	verify(ghost.get_difficulty_stars() == "★★★☆☆", "get_difficulty_stars() returns 3 stars")

	ghost.difficulty_rating = 5
	verify(ghost.get_difficulty_stars() == "★★★★★", "get_difficulty_stars() returns 5 stars")

	ghost.difficulty_rating = 1
	verify(ghost.get_difficulty_stars() == "★☆☆☆☆", "get_difficulty_stars() returns 1 star")

	ghost.difficulty_rating = 0
	verify(ghost.get_difficulty_stars() == "☆☆☆☆☆", "get_difficulty_stars() returns 0 stars for 0")

	print("  └─ GhostFormationData: OK")

func test_ghost_formation_extractor() -> void:
	if GhostFormationExtractorRef == null:
		tests_failed += 1
		print("[%s] GhostFormationExtractor class failed to load" % FAIL)
		return
	verify(true, "GhostFormationExtractor class loads")

	var battle_log: Array = [
		{"turn_count": 15, "enemy_count": 5, "enemies_defeated": ["vanguard_1", "skirmisher_1"]}
	]
	var ghost: GhostFormationDataRef = GhostFormationExtractorRef.extract_from_battle_log(battle_log, "TestPlayer", "CH01", true)
	verify(ghost != null, "extract_from_battle_log returns GhostFormationData")
	verify(not ghost.ghost_id.is_empty(), "Ghost has non-empty ghost_id")
	verify(ghost.chapter_id == "CH01", "Ghost chapter_id set correctly")
	verify(ghost.player_tag == "TestPlayer", "Ghost player_tag set correctly")
	verify(ghost.is_anonymous == true, "Ghost is_anonymous flag set correctly")

	var ghost_named: GhostFormationDataRef = GhostFormationExtractorRef.extract_from_battle_log(battle_log, "Commander", "CH02", false)
	verify(ghost_named.is_anonymous == false, "Named ghost has is_anonymous=false")
	verify(ghost_named.get_display_name() == "Commander's Strategy", "Named ghost display name correct")

	# Test strategy detection
	var aggressive_narrative := "The line broke under our assault and the enemy units scattered before our charge."
	var defensive_narrative := "Our position was held against the onslaught; the enemy weathered several waves before yielding."
	var calculated_narrative := "Patient tactics wore down the opposition through quiet attrition."

	# Test terrain detection via extractor
	var terrain_ghost: GhostFormationDataRef = GhostFormationExtractorRef.extract_from_battle_log([{"terrain": "hills"}], "P", "CH03", true)
	verify(terrain_ghost.preferred_terrain == "hills", "Terrain extraction from battle log works")

	print("  └─ GhostFormationExtractor: OK")

func test_extract_ghost_pattern_from_chronicle() -> void:
	verify(ChronicleGeneratorRef != null, "ChronicleGenerator class loads")
	var chronicle: ChronicleGeneratorRef = ChronicleGeneratorRef.new()
	var entry := _build_mock_chronicle_entry(
		"CH06",
		"The ridge was held after 14 turns while thunder broke the enemy line.",
		ChronicleEntryRef.ChronicleStyle.BATTLE,
		["weather_master", "quiet_strategy"]
	)
	var ghost: GhostFormationDataRef = chronicle.extract_ghost_pattern(entry, "Archivist", true)
	verify(ghost != null, "extract_ghost_pattern() returns GhostFormationData")
	verify(ghost.chapter_id == "CH06", "extract_ghost_pattern() preserves chapter_id")
	verify(is_equal_approx(ghost.avg_turns, 14.0), "extract_ghost_pattern() sets avg_turns from chronicle text")
	verify(ghost.preferred_terrain == "hills", "extract_ghost_pattern() detects terrain from chronicle text")
	verify(ghost.unique_tactics.has("Weather Manipulation"), "extract_ghost_pattern() keeps chronicle trigger tactics")

func test_ghost_formation_factory_from_chronicle() -> void:
	var entry := _build_mock_chronicle_entry(
		"CH07",
		"The fortress gates held after 11 turns as patient tactics wore the enemy down.",
		ChronicleEntryRef.ChronicleStyle.CONCISE,
		["quiet_strategy"]
	)
	var ghost: GhostFormationDataRef = GhostFormationDataRef.create_from_chronicle(entry, "Marshal", false)
	verify(ghost != null, "GhostFormationData.create_from_chronicle() returns GhostFormationData")
	verify(ghost.player_tag == "Marshal", "create_from_chronicle() preserves player_tag")
	verify(ghost.is_anonymous == false, "create_from_chronicle() preserves anonymity flag")
	verify(ghost.get_display_name() == "Marshal's Strategy", "create_from_chronicle() builds named display text")

func test_ghost_battle_manager() -> void:
	if GhostBattleManagerRef == null:
		tests_failed += 1
		print("[%s] GhostBattleManager class failed to load" % FAIL)
		return
	verify(true, "GhostBattleManager class loads")

	var manager: GhostBattleManagerRef = GhostBattleManagerRef.new()
	root.add_child(manager)

	var battle_log: Array = [
		{"turn_count": 12, "enemy_count": 4, "enemies_defeated": ["e1", "e2", "e3"]}
	]
	var ghost_data: GhostFormationDataRef = manager.register_ghost_from_battle_log(battle_log, "RDK", "CH05", false)
	var ghost_id: StringName = ghost_data.ghost_id
	verify(ghost_data != null, "register_ghost_from_battle_log returns GhostFormationData")
	verify(manager.has_ghost(ghost_id) == true, "has_ghost() returns true for registered ghost")

	var all_ghosts: Array = manager.get_all_ghosts()
	verify(all_ghosts.size() == 1, "get_all_ghosts() returns array with 1 entry")

	var start_ok: bool = manager.start_ghost_battle(ghost_id)
	verify(start_ok == true, "start_ghost_battle() returns true")

	var active: GhostFormationDataRef = manager.get_active_ghost()
	verify(active != null, "get_active_ghost() returns ghost after start")
	verify(active.ghost_id == ghost_id, "Active ghost matches started ghost")

	var defeat_ok: bool = manager.defeat_active_ghost()
	verify(defeat_ok == true, "defeat_active_ghost() returns true")
	verify(manager.is_ghost_defeated(ghost_id) == true, "is_ghost_defeated() returns true after defeat")
	verify(manager.get_defeated_count() == 1, "get_defeated_count() returns 1")

	var champion: Array = manager.get_champion_board()
	verify(champion.size() == 1, "get_champion_board() returns 1 entry")
	if champion.size() > 0:
		verify(champion[0].has("name") == true, "Champion entry has name field")
		verify(champion[0].has("difficulty") == true, "Champion entry has difficulty field")

	manager.clear_all_ghosts()
	verify(manager.has_ghost(ghost_id) == false, "has_ghost() returns false after clear")
	verify(manager.get_defeated_count() == 0, "get_defeated_count() returns 0 after clear")

	print("  └─ GhostBattleManager: OK")
	manager.free()

func test_ghost_battle_registry_count() -> void:
	var manager := _create_clean_manager()
	var first_ghost: GhostFormationDataRef = manager.register_ghost_from_battle_log([
		{"turn_count": 8, "enemy_count": 3, "enemies_defeated": ["e1"]}
	], "Rook", "CH06", true)
	var second_ghost: GhostFormationDataRef = manager.register_ghost_from_battle_log([
		{"turn_count": 10, "enemy_count": 4, "enemies_defeated": ["e2", "e3"]}
	], "Vera", "CH07", false)
	verify(manager.get_total_ghost_count() == 2, "ghost_registry tracks total registered entries")
	verify(manager.get_all_ghosts().size() == 2, "get_all_ghosts() reflects registry size")
	verify(manager.has_ghost(first_ghost.ghost_id), "registry contains first registered ghost")
	verify(manager.has_ghost(second_ghost.ghost_id), "registry contains second registered ghost")
	_cleanup_manager(manager)

func test_get_ghosts_by_chapter() -> void:
	var manager := _create_clean_manager()
	manager.register_ghost_from_battle_log([{"turn_count": 9, "enemy_count": 2}], "Lena", "CH06", true)
	manager.register_ghost_from_battle_log([{"turn_count": 7, "enemy_count": 2}], "Ivo", "CH06", true)
	manager.register_ghost_from_battle_log([{"turn_count": 12, "enemy_count": 5}], "Sia", "CH08", false)
	var chapter_ghosts: Array = manager.get_ghosts_by_chapter("CH06")
	verify(chapter_ghosts.size() == 2, "get_ghosts_by_chapter() filters matching entries")
	verify(chapter_ghosts[0].chapter_id == "CH06", "get_ghosts_by_chapter() keeps first matching chapter")
	verify(chapter_ghosts[1].chapter_id == "CH06", "get_ghosts_by_chapter() keeps second matching chapter")
	_cleanup_manager(manager)

func test_champion_board_ranking() -> void:
	var manager := _create_clean_manager()
	var steady: GhostFormationDataRef = manager.register_ghost_from_battle_log([{"turn_count": 16, "enemy_count": 4}], "Steady", "CH06", true)
	steady.difficulty_rating = 2
	steady.avg_turns = 16.0
	var swift: GhostFormationDataRef = manager.register_ghost_from_battle_log([{"turn_count": 9, "enemy_count": 4}], "Swift", "CH06", false)
	swift.difficulty_rating = 2
	swift.avg_turns = 9.0
	var legend: GhostFormationDataRef = manager.register_ghost_from_battle_log([{"turn_count": 13, "enemy_count": 6}], "Legend", "CH08", false)
	legend.difficulty_rating = 4
	legend.avg_turns = 13.0
	var board: Array = manager.get_champion_board()
	verify(board.size() == 2, "Champion board collapses to one entry per difficulty tier")
	verify(int(board[0].get("difficulty", -1)) == 2, "Champion board is sorted by difficulty tier")
	verify(is_equal_approx(float(board[0].get("turns", -1.0)), 9.0), "Champion board keeps the fastest ghost in a tier")
	verify(int(board[1].get("rank", -1)) == 2, "Champion board assigns sequential ranks")
	_cleanup_manager(manager)

func test_anonymous_vs_named_ghost() -> void:
	var chronicle: ChronicleGeneratorRef = _own(ChronicleGeneratorRef.new()) as ChronicleGeneratorRef
	var entry := _own_ref(_build_mock_chronicle_entry(
		"CH08",
		"The open field was cleared after 6 turns under a swift charge.",
		ChronicleEntryRef.ChronicleStyle.CONCISE,
		["overwhelming_force"]
	))
	var anonymous_ghost: GhostFormationDataRef = chronicle.extract_ghost_pattern(entry, "Hidden", true)
	var named_ghost: GhostFormationDataRef = chronicle.extract_ghost_pattern(entry, "Visible", false)
	verify(anonymous_ghost.is_anonymous == true, "Anonymous chronicle ghost keeps anonymity flag")
	verify(named_ghost.is_anonymous == false, "Named chronicle ghost disables anonymity flag")
	verify(anonymous_ghost.get_display_name() == "Unknown Commander's Strategy", "Anonymous chronicle ghost uses anonymous display name")
	verify(named_ghost.get_display_name() == "Visible's Strategy", "Named chronicle ghost uses player tag display name")

func _build_mock_chronicle_entry(chapter_id: String, narrative_text: String, style: int, trigger_events: Array[String]) -> ChronicleEntryRef:
	var entry: ChronicleEntryRef = ChronicleEntryRef.new()
	entry.chapter_id = chapter_id
	entry.chapter_title = chapter_id
	entry.entry_date = "2026-04-20"
	entry.narrative_text = narrative_text
	entry.style = style
	entry.trigger_events = trigger_events.duplicate()
	return entry

func _create_clean_manager() -> GhostBattleManagerRef:
	var manager: GhostBattleManagerRef = _own(GhostBattleManagerRef.new()) as GhostBattleManagerRef
	root.add_child(manager)
	manager.clear_all_ghosts()
	return manager

func _cleanup_manager(manager: GhostBattleManagerRef) -> void:
	if manager == null:
		return
	manager.clear_all_ghosts()
	manager.free()


func _own(node: Node) -> Node:
	_owned_nodes.append(node)
	return node


func _own_ref(ref: RefCounted) -> RefCounted:
	_owned_refs.append(ref)
	return ref


func _cleanup_owned_nodes() -> void:
	for index in range(_owned_nodes.size() - 1, -1, -1):
		var node := _owned_nodes[index]
		if is_instance_valid(node):
			node.free()
	_owned_nodes.clear()
	for index in range(_owned_refs.size() - 1, -1, -1):
		var ref: RefCounted = _owned_refs[index]
		_owned_refs[index] = null
	_owned_refs.clear()

func print_results() -> void:
	print("\n=== Results ===")
	print("Tests run:    %d" % tests_run)
	print("Tests passed: %d" % tests_passed)
	print("Tests failed: %d" % tests_failed)
	if tests_failed == 0:
		print("\n✅ All Ghost Battle tests PASSED")
	else:
		print("\n❌ %d test(s) FAILED" % tests_failed)
