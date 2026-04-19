extends SceneTree

const PASS := "✅ PASS"
const FAIL := "❌ FAIL"
const LAYERED_MUSIC_SCRIPT := preload("res://scripts/audio/layered_music.gd")
const EMOTIONAL_LAYER_CONTROLLER_SCRIPT := preload("res://scripts/audio/emotional_layer_controller.gd")

class FakeCampaignController:
	extends Node

	signal spotlight_triggered(spotlight_type: String)
	signal bond_death_started(unit_id: String)


class SignalRecorder:
	extends RefCounted

	var spotlight_calls: Array[String] = []
	var bond_calls: Array[String] = []

	func record_spotlight(spotlight_type: String) -> void:
		spotlight_calls.append(spotlight_type)

	func record_bond(unit_id: String) -> void:
		bond_calls.append(unit_id)


var tests_run: int = 0
var tests_passed: int = 0
var tests_failed: int = 0


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	print("\n=== Living Soundtrack Runner ===\n")
	await process_frame
	await process_frame

	test_script_loads()

	var music: Node = _resolve_music_under_test()
	var controller: Node = _resolve_controller_under_test()

	await process_frame
	test_autoload_contracts()
	await test_layered_music_contract(music)
	await test_emotional_layer_controller_contract(controller, music)

	print_results()
	quit(0 if tests_failed == 0 else 1)


func test_script_loads() -> void:
	verify(LAYERED_MUSIC_SCRIPT != null, "LayeredMusic script loads")
	verify(EMOTIONAL_LAYER_CONTROLLER_SCRIPT != null, "EmotionalLayerController script loads")


func test_autoload_contracts() -> void:
	var layered_music := root.get_node_or_null("LayeredMusic")
	var emotional_controller := root.get_node_or_null("EmotionalLayerController")

	verify(layered_music != null, "LayeredMusic autoload exists at /root/LayeredMusic")
	verify(emotional_controller != null, "EmotionalLayerController autoload exists at /root/EmotionalLayerController")

	if layered_music != null:
		verify(String(layered_music.get_script().resource_path) == "res://scripts/audio/layered_music.gd", "LayeredMusic autoload points to layered_music.gd")
	if emotional_controller != null:
		verify(String(emotional_controller.get_script().resource_path) == "res://scripts/audio/emotional_layer_controller.gd", "EmotionalLayerController autoload points to emotional_layer_controller.gd")


func test_layered_music_contract(music: Node) -> void:
	verify(music != null, "LayeredMusic instance available for contract tests")
	if music == null:
		return

	verify(music.has_method("play_cue"), "LayeredMusic exposes play_cue()")
	verify(music.has_method("activate_layer"), "LayeredMusic exposes activate_layer()")
	verify(music.has_method("deactivate_layer"), "LayeredMusic exposes deactivate_layer()")
	verify(music.has_method("trigger_spotlight_music"), "LayeredMusic exposes trigger_spotlight_music()")
	verify(music.has_method("crossfade_to_cue"), "LayeredMusic exposes crossfade_to_cue()")
	verify(music.has_method("stop_all"), "LayeredMusic exposes stop_all()")
	verify(music.has_method("is_layer_active"), "LayeredMusic exposes is_layer_active()")
	verify(music.has_method("get_active_layers"), "LayeredMusic exposes get_active_layers()")

	await process_frame

	var players: Dictionary = music.get("_players")
	verify(players.size() == 6, "LayeredMusic creates six managed players")
	verify(players.has("base"), "LayeredMusic registers the base layer")
	verify(players.has("drums"), "LayeredMusic registers the drums layer")
	verify(players.has("strings"), "LayeredMusic registers the strings layer")
	verify(players.has("vocal"), "LayeredMusic registers the vocal layer")
	verify(players.has("ambience"), "LayeredMusic registers the ambience layer")
	verify(players.has("spotlight"), "LayeredMusic registers the spotlight layer")
	for layer_name in ["base", "drums", "strings", "vocal", "ambience", "spotlight"]:
		var player := players.get(layer_name, null) as AudioStreamPlayer
		verify(player != null, "%s player is an AudioStreamPlayer" % layer_name)
		if player != null:
			verify(player.bus == &"Master", "%s player uses the Master bus" % layer_name)

	var initial_layers: Variant = music.call("get_active_layers")
	verify(initial_layers is Array, "get_active_layers() returns an Array")
	verify((initial_layers as Array).is_empty(), "LayeredMusic starts with no active layers")
	verify(not music.call("is_layer_active", "base"), "Base layer starts inactive")
	verify(not music.call("is_layer_active", "drums"), "Drums layer starts inactive")

	music.call("play_cue", "bgm_battle_default", true)
	await process_frame
	verify(String(music.get("_current_cue_id")) == "bgm_battle_default", "play_cue() stores the current cue id")
	verify(music.call("is_layer_active", "base"), "play_cue() activates the base layer")
	verify(((players.get("base") as AudioStreamPlayer).stream) != null, "play_cue() assigns a base stream from the manifest")
	verify(((music.call("get_active_layers") as Array).has("base")), "Active layers include base after play_cue()")

	music.call("activate_layer", "drums", 0.0)
	await process_frame
	verify(music.call("is_layer_active", "drums"), "activate_layer() marks drums active")
	verify((music.call("get_active_layers") as Array).has("drums"), "get_active_layers() includes drums after activation")
	verify(((players.get("drums") as AudioStreamPlayer).stream) != null, "activate_layer() assigns a stub stream to drums")

	music.call("deactivate_layer", "drums", 0.0)
	await process_frame
	verify(not music.call("is_layer_active", "drums"), "deactivate_layer() clears drums activity")
	verify(not (music.call("get_active_layers") as Array).has("drums"), "get_active_layers() removes drums after deactivation")

	music.call("activate_layer", "strings", 0.0)
	music.call("activate_layer", "vocal", 0.0)
	music.call("activate_layer", "ambience", 0.0)
	await process_frame
	verify(music.call("is_layer_active", "strings"), "Strings layer activates without errors")
	verify(music.call("is_layer_active", "vocal"), "Vocal layer activates without errors")
	verify(music.call("is_layer_active", "ambience"), "Ambience layer activates without errors")

	music.call("stop_all", 0.0)
	await process_frame
	verify((music.call("get_active_layers") as Array).is_empty(), "stop_all() clears active layers immediately with fade_time 0")
	verify(not music.call("is_layer_active", "strings"), "stop_all() deactivates strings")
	verify(not music.call("is_layer_active", "vocal"), "stop_all() deactivates vocal")
	verify(not music.call("is_layer_active", "ambience"), "stop_all() deactivates ambience")

	music.call("trigger_spotlight_music", "bond_death", 0.0)
	await process_frame
	verify(music.call("is_layer_active", "spotlight"), "bond_death spotlight activates the spotlight layer")
	verify(music.call("is_layer_active", "vocal"), "bond_death spotlight activates the vocal layer")

	music.call("stop_all", 0.0)
	music.call("trigger_spotlight_music", "boss", 0.0)
	await process_frame
	verify(music.call("is_layer_active", "spotlight"), "boss spotlight activates the spotlight layer")
	verify(music.call("is_layer_active", "drums"), "boss spotlight activates the drums layer")

	music.call("stop_all", 0.0)
	music.call("trigger_spotlight_music", "critical", 0.0)
	await process_frame
	verify(music.call("is_layer_active", "spotlight"), "critical spotlight activates the spotlight layer")
	verify(music.call("is_layer_active", "strings"), "critical spotlight activates the strings layer")

	music.call("stop_all", 0.0)
	music.call("trigger_spotlight_music", "victory", 0.0)
	await process_frame
	verify(music.call("is_layer_active", "spotlight"), "victory spotlight activates the spotlight layer")
	verify(music.call("is_layer_active", "ambience"), "victory spotlight activates the ambience layer")

	music.call("play_cue", "bgm_battle_default", true)
	music.call("crossfade_to_cue", "bgm_camp", 0.1)
	await process_frame
	var crossfade_tween: Variant = music.get("_base_crossfade_tween")
	var transition_player: AudioStreamPlayer = music.get("_base_transition_player")
	verify(String(music.get("_current_cue_id")) == "bgm_camp", "crossfade_to_cue() updates the current cue id")
	verify(crossfade_tween != null, "crossfade_to_cue() creates a tween")
	verify(transition_player != null, "crossfade_to_cue() creates a transition player")
	if transition_player != null:
		verify(transition_player.stream != null, "crossfade_to_cue() assigns a transition stream")
	await _wait_seconds(0.16)
	verify(((players.get("base") as AudioStreamPlayer).stream) != null, "Base player retains a stream after crossfade completion")

	music.call("activate_layer", "drums", 0.0)
	music.call("activate_layer", "spotlight", 0.0)
	await process_frame
	music.call("stop_all", 0.05)
	await _wait_seconds(0.08)
	verify((music.call("get_active_layers") as Array).is_empty(), "stop_all() clears all layers after a fade")
	verify(not music.call("is_layer_active", "spotlight"), "stop_all() deactivates spotlight")
	verify(not music.call("is_layer_active", "missing_layer"), "Unknown layers report inactive")

	var playback_disabled := bool(music.call("_should_skip_playback")) if music.has_method("_should_skip_playback") else DisplayServer.get_name() == "headless"
	verify(playback_disabled == (DisplayServer.get_name() == "headless" or OS.has_feature("standalone")), "Playback skip helper matches environment expectations")
	if DisplayServer.get_name() == "headless":
		verify(not (players.get("base") as AudioStreamPlayer).playing, "Headless mode skips base playback")
		verify(not (players.get("spotlight") as AudioStreamPlayer).playing, "Headless mode skips spotlight playback")

	var stream_cache: Dictionary = music.get("_stream_cache")
	verify(stream_cache.size() >= 1, "LayeredMusic caches loaded audio streams")


func test_emotional_layer_controller_contract(controller: Node, music: Node) -> void:
	verify(controller != null, "EmotionalLayerController instance available for contract tests")
	if controller == null:
		return

	verify(controller.has_signal("spotlight_triggered"), "EmotionalLayerController defines spotlight_triggered")
	verify(controller.has_signal("bond_death_started"), "EmotionalLayerController defines bond_death_started")
	verify(controller.has_method("emit_spotlight"), "EmotionalLayerController exposes emit_spotlight()")

	var recorder := SignalRecorder.new()
	controller.spotlight_triggered.connect(recorder.record_spotlight)
	controller.bond_death_started.connect(recorder.record_bond)

	if music != null:
		music.call("stop_all", 0.0)

	controller.call("emit_spotlight", "boss")
	await process_frame
	verify(recorder.spotlight_calls.size() == 1, "emit_spotlight() emits spotlight_triggered")
	verify(recorder.spotlight_calls[-1] == "boss", "emit_spotlight() preserves the spotlight type")
	if music != null:
		verify(music.call("is_layer_active", "spotlight"), "emit_spotlight(boss) routes into LayeredMusic")
		verify(music.call("is_layer_active", "drums"), "emit_spotlight(boss) activates the boss companion layer")

	if music != null:
		music.call("stop_all", 0.0)
	var fake_campaign := FakeCampaignController.new()
	fake_campaign.name = "CampaignController"
	root.add_child(fake_campaign)
	await process_frame
	await process_frame

	fake_campaign.spotlight_triggered.emit("bond_death")
	await process_frame
	verify(recorder.spotlight_calls.size() >= 2, "CampaignController spotlight signal reaches EmotionalLayerController")
	verify(recorder.spotlight_calls[-1] == "bond_death", "Campaign spotlight payload is forwarded")
	if music != null:
		verify(music.call("is_layer_active", "spotlight"), "Campaign spotlight event triggers spotlight music")
		verify(music.call("is_layer_active", "vocal"), "Campaign bond_death spotlight activates vocal layer")

	if music != null:
		music.call("stop_all", 0.0)
	fake_campaign.bond_death_started.emit("ally_serin")
	await process_frame
	verify(recorder.bond_calls.size() == 1, "Campaign bond_death_started signal reaches EmotionalLayerController")
	verify(recorder.bond_calls[-1] == "ally_serin", "Campaign bond_death_started forwards the unit id")
	if music != null:
		verify(music.call("is_layer_active", "spotlight"), "bond_death_started routes into spotlight music")
		verify(music.call("is_layer_active", "vocal"), "bond_death_started activates the bond-death layer mix")

	fake_campaign.queue_free()
	await process_frame


func _resolve_music_under_test() -> Node:
	var music := root.get_node_or_null("LayeredMusic")
	if music != null:
		return music
	if LAYERED_MUSIC_SCRIPT == null:
		return null
	music = LAYERED_MUSIC_SCRIPT.new()
	music.name = "LayeredMusicManual"
	root.add_child(music)
	return music


func _resolve_controller_under_test() -> Node:
	var controller := root.get_node_or_null("EmotionalLayerController")
	if controller != null:
		return controller
	if EMOTIONAL_LAYER_CONTROLLER_SCRIPT == null:
		return null
	controller = EMOTIONAL_LAYER_CONTROLLER_SCRIPT.new()
	controller.name = "EmotionalLayerControllerManual"
	root.add_child(controller)
	return controller


func _wait_seconds(duration: float) -> void:
	await create_timer(duration, false).timeout


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


func print_results() -> void:
	print("\n=== Results ===")
	print("Tests run:    %d" % tests_run)
	print("Tests passed: %d" % tests_passed)
	print("Tests failed: %d" % tests_failed)
	if tests_failed == 0:
		print("\n✅ All Living Soundtrack tests PASSED")
	else:
		print("\n❌ %d test(s) FAILED" % tests_failed)
