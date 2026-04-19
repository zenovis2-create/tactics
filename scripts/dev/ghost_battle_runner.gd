extends SceneTree

# Ghost Battle Runner — Headless verification
# Verifies: GhostFormationData, GhostFormationExtractor, GhostBattleManager
# Run: godot --headless --path . --script scripts/dev/ghost_battle_runner.gd

const PASS := "✅ PASS"
const FAIL := "❌ FAIL"

const GhostFormationDataRef = preload("res://scripts/data/ghost_formation_data.gd")
const GhostFormationExtractorRef = preload("res://scripts/battle/ghost_formation_extractor.gd")
const GhostBattleManagerRef = preload("res://scripts/battle/ghost_battle_manager.gd")

var tests_run: int = 0
var tests_passed: int = 0
var tests_failed: int = 0

func _initialize() -> void:
	print("\n=== Ghost Battle Runner ===\n")
	run_tests()
	print_results()
	quit(0 if tests_failed == 0 else 1)

func run_tests() -> void:
	test_ghost_formation_data()
	test_ghost_formation_extractor()
	test_ghost_battle_manager()

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

func print_results() -> void:
	print("\n=== Results ===")
	print("Tests run:    %d" % tests_run)
	print("Tests passed: %d" % tests_passed)
	print("Tests failed: %d" % tests_failed)
	if tests_failed == 0:
		print("\n✅ All Ghost Battle tests PASSED")
	else:
		print("\n❌ %d test(s) FAILED" % tests_failed)
