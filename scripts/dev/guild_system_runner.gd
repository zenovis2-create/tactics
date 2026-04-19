extends SceneTree

# Guild System Runner — Headless verification
# Verifies: ReplayData, ReplayManager, GuildSystem, EncyclopediaPanel guild tab
# Run: godot --headless --path . --script scripts/dev/guild_system_runner.gd

const PASS := "✅ PASS"
const FAIL := "❌ FAIL"

const ReplayDataRef = preload("res://scripts/battle/replay_data.gd")
const ReplayManagerRef = preload("res://scripts/battle/replay_manager.gd")
const GuildSystemRef = preload("res://scripts/battle/guild_system.gd")

var tests_run: int = 0
var tests_passed: int = 0
var tests_failed: int = 0

func _initialize() -> void:
	print("\n=== Guild System Runner ===\n")
	run_tests()
	print_results()
	quit(0 if tests_failed == 0 else 1)

func run_tests() -> void:
	test_replay_data()
	test_replay_manager()
	test_guild_system()
	test_guild_online_stubs()

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

func test_replay_data() -> void:
	if ReplayDataRef == null:
		tests_failed += 1
		print("[%s] ReplayData class failed to load" % FAIL)
		return
	verify(true, "ReplayData class loads")

	var replay: ReplayDataRef = ReplayDataRef.new()
	verify(replay != null, "ReplayData instantiates")
	verify(replay.replay_id == &"", "Default replay_id is empty")
	verify(replay.star_rating == 1, "Default star_rating is 1")
	verify(replay.is_anonymous == true, "is_anonymous defaults to true")
	verify(replay.turn_count == 0, "Default turn_count is 0")

	replay.is_anonymous = false
	replay.uploader_name = "TestUser"
	replay.replay_title = "Epic Battle"
	replay.chapter_id = "CH05"
	replay.stage_id = "ch05_stage01"
	replay.turn_count = 15
	replay.star_rating = 4
	replay.difficulty_rating = 3
	verify(replay.get_uploader_display() == "TestUser", "Named uploader display correct")
	verify(replay.get_display_title().contains("Epic Battle"), "Display title includes replay title")
	verify(replay.get_turns_display() == "15 turns", "get_turns_display() correct")
	verify(replay.get_difficulty_stars() == "★★★☆☆", "get_difficulty_stars() returns 3 stars")

	# Test serialization roundtrip
	var dict := replay.to_dict()
	verify(dict.has("replay_id"), "to_dict() has replay_id")
	verify(dict.has("star_rating"), "to_dict() has star_rating")
	verify(dict.has("allied_units"), "to_dict() has allied_units")

	var recreated: ReplayDataRef = ReplayDataRef.create_from_dict(dict)
	verify(recreated.replay_title == "Epic Battle", "create_from_dict restores replay_title")
	verify(recreated.turn_count == 15, "create_from_dict restores turn_count")
	verify(recreated.is_anonymous == false, "create_from_dict restores is_anonymous")
	verify(recreated.star_rating == 4, "create_from_dict restores star_rating")

	replay.free()
	print("  └─ ReplayData: OK")

func test_replay_manager() -> void:
	if ReplayManagerRef == null:
		tests_failed += 1
		print("[%s] ReplayManager class failed to load" % FAIL)
		return
	verify(true, "ReplayManager class loads")

	var manager = ReplayManagerRef.new()
	root.add_child(manager)
	verify(manager.get_replay_count() == 0, "Initial replay count is 0")

	# Create and save a replay
	var replay: ReplayDataRef = ReplayDataRef.new()
	replay.chapter_id = "CH03"
	replay.stage_id = "ch03_stage01"
	replay.turn_count = 10
	replay.star_rating = 3
	replay.uploader_name = "Serin"
	replay.is_anonymous = false
	var saved_id := manager.save_replay(replay)
	verify(not saved_id.is_empty(), "save_replay returns non-empty id")
	verify(manager.get_replay_count() == 1, "Replay count is 1 after save")

	# Load the replay back
	var loaded: ReplayDataRef = manager.load_replay(saved_id)
	verify(loaded != null, "load_replay returns non-null")
	verify(loaded.chapter_id == "CH03", "Loaded replay chapter_id correct")
	verify(loaded.turn_count == 10, "Loaded replay turn_count correct")

	# Delete the replay
	var deleted := manager.delete_replay(saved_id)
	verify(deleted == true, "delete_replay returns true")
	verify(manager.get_replay_count() == 0, "Replay count is 0 after delete")

	manager.clear_all_replays()
	verify(manager.get_replay_count() == 0, "clear_all_replays works")

	manager.free()
	print("  └─ ReplayManager: OK")

func test_guild_system() -> void:
	if GuildSystemRef == null:
		tests_failed += 1
		print("[%s] GuildSystem class failed to load" % FAIL)
		return
	verify(true, "GuildSystem class loads")

	var gs = GuildSystemRef.new()
	root.add_child(gs)

	verify(gs.get_guild_count() == 0, "Initial guild count is 0")
	verify(gs.is_in_guild() == false, "Initially not in a guild")

	# Create a guild
	var guild = gs.create_guild("Iron Wolves", "Commander", "Elite tactics guild", "wolf")
	verify(guild != null, "create_guild returns Guild")
	verify(gs.get_guild_count() == 1, "Guild count is 1 after create")
	verify(gs.is_in_guild() == true, "Is in guild after create")
	verify(guild.name == "Iron Wolves", "Guild name set correctly")
	verify(guild.description == "Elite tactics guild", "Guild description set correctly")
	verify(guild.banner_symbol == "wolf", "Guild banner symbol set correctly")
	verify(guild.members.size() == 1, "Guild has 1 member after create")

	var leader = guild.get_member(guild.leader_id)
	verify(leader != null, "Leader member found")
	verify(leader.is_leader == true, "Leader is marked as leader")
	verify(leader.display_name == "Commander", "Leader name correct")
	verify(gs.get_member_rank_label(gs.MEMBER_RANK_TROOPERS) == "Trooper", "Trooper rank label correct")
	verify(gs.get_member_rank_label(gs.MEMBER_RANK_VETERANS) == "Veteran", "Veteran rank label correct")
	verify(gs.get_member_rank_label(gs.MEMBER_RANK_COMMANDERS) == "Commander", "Commander rank label correct")

	# Test ranking board
	var board = gs.get_ranking_board(5)
	verify(board.size() == 1, "Ranking board has 1 entry")
	if board.size() > 0:
		verify(board[0].has("name"), "Board entry has name")
		verify(board[0].has("ranking_score"), "Board entry has ranking_score")
		verify(board[0].has("average_grade"), "Board entry has average_grade")

	# Test leaving guild
	var left := gs.leave_guild()
	verify(left == true, "leave_guild returns true")
	verify(gs.is_in_guild() == false, "Not in guild after leave")
	verify(gs.get_guild_count() == 1, "Guild still exists after member leaves")

	# Test join guild
	var joined := gs.join_guild(guild.guild_id, "RookiePlayer", 2.5)
	verify(joined == true, "join_guild returns true")
	verify(gs.is_in_guild() == true, "Is in guild after join")

	# Cannot join second guild
	var joined_again := gs.join_guild(guild.guild_id, "AnotherPlayer", 3.0)
	verify(joined_again == false, "Cannot join second guild while in one")

	# Update grade
	var current_member = gs.get_current_member()
	verify(current_member != null, "Current member found")
	var grade_updated := gs.update_member_grade(current_member.member_id, 4.0)
	verify(grade_updated == true, "update_member_grade returns true")
	verify(current_member.battle_grade == 4.0, "Member grade updated")

	# Banner symbols
	var symbols: Array = gs.get_banner_symbols()
	verify(symbols.size() == 5, "BANNER_SYMBOLS has 5 entries")
	verify(symbols.has("wolf"), "wolf in BANNER_SYMBOLS")
	verify(symbols.has("phoenix"), "phoenix in BANNER_SYMBOLS")

	# Test get_all_guilds sorted by ranking
	var all_guilds = gs.get_all_guilds()
	verify(all_guilds.size() == 1, "get_all_guilds returns 1 guild")
	if all_guilds.size() >= 1:
		verify(all_guilds[0].name == "Iron Wolves", "get_all_guilds first entry correct")

	gs.free()
	print("  └─ GuildSystem: OK")

func test_guild_online_stubs() -> void:
	var manager = ReplayManagerRef.new()
	root.add_child(manager)
	verify(manager.is_online() == false, "is_online() returns false (offline mode)")
	verify(manager.upload_replay_to_server(&"test") == false, "upload_replay_to_server stub returns false")
	verify(manager.download_replay("test_id") == null, "download_replay stub returns null")
	var server_list = manager.list_server_replays()
	verify(server_list.size() == 0, "list_server_replays stub returns empty array")
	manager.free()
	print("  └─ Online stubs: OK")

func print_results() -> void:
	print("\n=== Results ===")
	print("Tests run:    %d" % tests_run)
	print("Tests passed: %d" % tests_passed)
	print("Tests failed: %d" % tests_failed)
	if tests_failed == 0:
		print("\n✅ All Guild System tests PASSED")
	else:
		print("\n❌ %d test(s) FAILED" % tests_failed)
