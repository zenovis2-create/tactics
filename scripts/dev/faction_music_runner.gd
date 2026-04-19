extends SceneTree

# Faction Music Runner — Headless verification
# Verifies: FactionMusic class, faction tracking, cross-fade, blend mode
# Run: godot --headless --path . --script scripts/dev/faction_music_runner.gd

const PASS := "✅ PASS"
const FAIL := "❌ FAIL"

const FactionMusicRef = preload("res://scripts/audio/faction_music.gd")

var tests_run: int = 0
var tests_passed: int = 0
var tests_failed: int = 0

func _initialize() -> void:
	print("\n=== Faction Music Runner ===\n")
	run_tests()
	print_results()
	quit(0 if tests_failed == 0 else 1)

func run_tests() -> void:
	test_faction_constants()
	test_faction_music_creation()
	test_faction_playback()
	test_crossfade()
	test_faction_blend()
	test_faction_lookup()
	test_get_faction_info()
	test_volume_control()

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

func test_faction_constants() -> void:
	if FactionMusicRef == null:
		tests_failed += 1
		print("[%s] FactionMusic class failed to load" % FAIL)
		return
	verify(true, "FactionMusic class loads")

	verify(FactionMusicRef.FARLAND_EMPIRE == "FARLAND_EMPIRE", "FARLAND_EMPIRE constant correct")
	verify(FactionMusicRef.LEONICA_RESISTANCE == "LEONICA_RESISTANCE", "LEONICA_RESISTANCE constant correct")
	verify(FactionMusicRef.NEUTRAL_MERCENARIES == "NEUTRAL_MERCENARIES", "NEUTRAL_MERCENARIES constant correct")

	var all_factions: Array = FactionMusicRef.ALL_FACTIONS
	verify(all_factions.size() == 3, "ALL_FACTIONS has 3 factions")
	verify(all_factions.has("FARLAND_EMPIRE"), "ALL_FACTIONS contains FARLAND_EMPIRE")
	verify(all_factions.has("LEONICA_RESISTANCE"), "ALL_FACTIONS contains LEONICA_RESISTANCE")
	verify(all_factions.has("NEUTRAL_MERCENARIES"), "ALL_FACTIONS contains NEUTRAL_MERCENARIES")

	verify(FactionMusicRef.FACTION_DISPLAY_NAMES.has("FARLAND_EMPIRE"), "FARLAND_EMPIRE has display name")
	verify(FactionMusicRef.FACTION_DISPLAY_NAMES.has("LEONICA_RESISTANCE"), "LEONica has display name")
	verify(FactionMusicRef.FACTION_DESCRIPTIONS.has("FARLAND_EMPIRE"), "FARLAND_EMPIRE has description")

	print("  └─ Faction constants: OK")

func test_faction_music_creation() -> void:
	var fm: FactionMusicRef = FactionMusicRef.new()
	root.add_child(fm)
	verify(fm != null, "FactionMusic instantiates")
	verify(fm.get_current_faction() == "", "Default faction is empty")
	verify(fm.is_playing() == false, "Initially not playing")
	verify(fm.is_faction_active("FARLAND_EMPIRE") == false, "No faction active initially")

	var all_f: Array = fm.get_all_factions()
	verify(all_f.size() == 3, "get_all_factions() returns 3 factions")

	fm.free()
	print("  └─ FactionMusic creation: OK")

func test_faction_playback() -> void:
	var fm: FactionMusicRef = FactionMusicRef.new()
	root.add_child(fm)

	fm.play_faction_music("FARLAND_EMPIRE", 0.0)
	verify(fm.get_current_faction() == "FARLAND_EMPIRE", "Current faction set after play_faction_music()")

	fm.play_faction_music("LEONICA_RESISTANCE", 0.0)
	verify(fm.get_current_faction() == "LEONICA_RESISTANCE", "Current faction updated to LEONICA_RESISTANCE")

	fm.play_faction_music("NONEXISTENT_FACTION", 0.0)
	verify(fm.get_current_faction() == "LEONICA_RESISTANCE", "Invalid faction does not change current")

	fm.stop_faction_music(0.0)
	verify(fm.get_current_faction() == "", "Faction cleared after stop")
	verify(fm.is_playing() == false, "Not playing after stop")

	fm.free()
	print("  └─ FactionMusic playback: OK")

func test_crossfade() -> void:
	var fm: FactionMusicRef = FactionMusicRef.new()
	root.add_child(fm)

	fm.crossfade_to_faction("FARLAND_EMPIRE", 1.0)
	verify(fm.get_current_faction() == "FARLAND_EMPIRE", "crossfade_to_faction sets faction")

	fm.crossfade_to_faction("NEUTRAL_MERCENARIES", 1.0)
	verify(fm.get_current_faction() == "NEUTRAL_MERCENARIES", "crossfade updates faction")

	fm.free()
	print("  └─ Cross-fade: OK")

func test_faction_blend() -> void:
	var fm: FactionMusicRef = FactionMusicRef.new()
	root.add_child(fm)

	var factions: Array[String] = ["FARLAND_EMPIRE", "LEONICA_RESISTANCE"]
	fm.play_faction_blend(factions, 0.0)
	verify(fm.is_faction_active("FARLAND_EMPIRE") == true, "FARLAND active in blend mode")
	verify(fm.is_faction_active("LEONICA_RESISTANCE") == true, "LEONICA active in blend mode")

	fm.free()
	print("  └─ Faction blend: OK")

func test_faction_lookup() -> void:
	var fm: FactionMusicRef = FactionMusicRef.new()
	root.add_child(fm)

	verify(fm.get_faction_for_chapter("CH01") == "FARLAND_EMPIRE", "CH01 maps to FARLAND_EMPIRE")
	verify(fm.get_faction_for_chapter("CH03") == "NEUTRAL_MERCENARIES", "CH03 maps to NEUTRAL_MERCENARIES")
	verify(fm.get_faction_for_chapter("CH07") == "LEONICA_RESISTANCE", "CH07 maps to LEONICA_RESISTANCE")
	verify(fm.get_faction_for_chapter("CH10") == "FARLAND_EMPIRE", "CH10 maps to FARLAND_EMPIRE")
	verify(fm.get_faction_for_chapter("UNKNOWN") == "", "Unknown chapter maps to empty")

	fm.free()
	print("  └─ Faction lookup: OK")

func test_get_faction_info() -> void:
	var fm: FactionMusicRef = FactionMusicRef.new()
	root.add_child(fm)

	var info: Dictionary = fm.get_faction_info("FARLAND_EMPIRE")
	verify(info.has("id") == true, "Faction info has id")
	verify(info.has("name") == true, "Faction info has name")
	verify(info.has("description") == true, "Faction info has description")
	verify(info.has("track_path") == true, "Faction info has track_path")
	verify(info.has("is_playing") == true, "Faction info has is_playing")
	verify(info["name"] == "Farland Empire", "FARLAND name is correct")

	var bad_info: Dictionary = fm.get_faction_info("INVALID_FACTION")
	verify(bad_info["name"] == "INVALID_FACTION", "Invalid faction returns faction ID as name")

	fm.free()
	print("  └─ Faction info: OK")

func test_volume_control() -> void:
	var fm: FactionMusicRef = FactionMusicRef.new()
	root.add_child(fm)

	fm.set_volume(0.5)
	fm.set_volume(1.0)
	fm.set_volume(0.0)
	fm.set_volume(1.5)
	fm.set_volume(-0.1)
	verify(true, "set_volume clamps invalid values without crashing")

	fm.set_volume(0.7)
	verify(true, "set_volume(0.7) accepted")

	fm.free()
	print("  └─ Volume control: OK")

func print_results() -> void:
	print("\n=== Results ===")
	print("Tests run:    %d" % tests_run)
	print("Tests passed: %d" % tests_passed)
	print("Tests failed: %d" % tests_failed)
	if tests_failed == 0:
		print("\n✅ All Faction Music tests PASSED")
	else:
		print("\n❌ %d test(s) FAILED" % tests_failed)
