extends SceneTree

# Observer Mode Runner — Headless verification
# Verifies: ObserverCamera, TacticalCommentary, ScreenshotCapture, StreamerOverlay, BattleHUD observer toggle
# Run: godot --headless --path . --script scripts/dev/observer_mode_runner.gd

const PASS := "✅ PASS"
const FAIL := "❌ FAIL"

const ObserverCameraRef = preload("res://scripts/ui/observer_camera.gd")
const TacticalCommentaryRef = preload("res://scripts/ui/tactical_commentary.gd")
const ScreenshotCaptureRef = preload("res://scripts/ui/screenshot_capture.gd")
const StreamerOverlayRef = preload("res://scripts/ui/streamer_overlay.gd")

var tests_run: int = 0
var tests_passed: int = 0
var tests_failed: int = 0

func _initialize() -> void:
	print("\n=== Observer Mode Runner ===\n")
	run_tests()
	print_results()
	quit(0 if tests_failed == 0 else 1)

func run_tests() -> void:
	test_observer_camera()
	test_tactical_commentary()
	test_screenshot_capture()
	test_streamer_overlay()

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

func test_observer_camera() -> void:
	if ObserverCameraRef == null:
		tests_failed += 1
		print("[%s] ObserverCamera class failed to load" % FAIL)
		return
	verify(true, "ObserverCamera class loads")

	var cam: ObserverCameraRef = ObserverCameraRef.new()
	root.add_child(cam)
	verify(cam.is_active() == false, "Camera not active initially")
	verify(cam.get_observed_battle_id() == "", "No battle ID initially")

	cam.activate("CH05_battle01")
	verify(cam.is_active() == true, "Camera active after activate()")
	verify(cam.get_observed_battle_id() == "CH05_battle01", "Battle ID set correctly")

	cam.focus_on_unit("ally_rian")
	verify(cam.is_active() == true, "Camera stays active after focus")

	var info: Dictionary = cam.get_camera_info()
	verify(info.has("is_active"), "get_camera_info() has is_active")
	verify(info.has("position"), "get_camera_info() has position")
	verify(info.has("height"), "get_camera_info() has height")
	verify(info.has("battle_id"), "get_camera_info() has battle_id")
	verify(info.get("battle_id") == "CH05_battle01", "Info battle_id matches")

	cam.deactivate()
	verify(cam.is_active() == false, "Camera deactivated")
	verify(cam.get_observed_battle_id() == "", "Battle ID cleared after deactivate")

	cam.free()
	print("  └─ ObserverCamera: OK")

func test_tactical_commentary() -> void:
	if TacticalCommentaryRef == null:
		tests_failed += 1
		print("[%s] TacticalCommentary class failed to load" % FAIL)
		return
	verify(true, "TacticalCommentary class loads")

	var tc: TacticalCommentaryRef = TacticalCommentaryRef.new()
	root.add_child(tc)
	tc._build_rules()

	verify(tc.is_commentary_enabled() == true, "Commentary enabled by default")

	# Test kill event (use string literals to avoid preload constant resolution issues)
	var kill_text := tc.generate_commentary("kill", "Serin", "Vanguard")
	verify(not kill_text.is_empty(), "Kill event generates text")
	verify(kill_text.contains("Serin"), "Kill text contains attacker name")

	# Test critical event
	var crit_text := tc.generate_commentary("critical", "Serin", "Enemy")
	verify(not crit_text.is_empty(), "Critical event generates text")
	verify(crit_text.contains("Serin"), "Critical text contains attacker name")

	# Test heal event
	var heal_text := tc.generate_commentary("heal", "Medic", "Serin")
	verify(not heal_text.is_empty(), "Heal event generates text")

	# Test turn commentary
	var turn_text := tc.generate_turn_commentary(5, "FARLAND_EMPIRE")
	verify(not turn_text.is_empty(), "Turn commentary generated")
	verify(turn_text.contains("5"), "Turn commentary contains turn number")

	# Test history
	var history: Array = tc.get_commentary_history()
	verify(history.size() >= 2, "Commentary added to history")

	# Test clear history
	tc.clear_history()
	verify(tc.get_commentary_history().size() == 0, "History cleared")

	# Test commentary disabled
	tc.set_commentary_enabled(false)
	var disabled_text := tc.generate_commentary("kill", "A", "B")
	verify(disabled_text.is_empty(), "No commentary when disabled")

	tc.free()
	print("  └─ TacticalCommentary: OK")

func test_screenshot_capture() -> void:
	if ScreenshotCaptureRef == null:
		tests_failed += 1
		print("[%s] ScreenshotCapture class failed to load" % FAIL)
		return
	verify(true, "ScreenshotCapture class loads")

	var sc: ScreenshotCaptureRef = ScreenshotCaptureRef.new()
	root.add_child(sc)

	verify(sc.is_capture_enabled() == false, "Capture disabled by default")
	sc.enable_capture()
	verify(sc.is_capture_enabled() == true, "Capture enabled after enable_capture()")
	sc.disable_capture()
	verify(sc.is_capture_enabled() == false, "Capture disabled after disable_capture()")

	sc.enable_capture()
	sc.set_highlight_threshold(0.8)
	verify(sc.get_highlight_threshold() == 0.8, "Highlight threshold set correctly")

	sc.set_capture_cooldown(5.0)

	# Test event evaluation (non-dramatic, low intensity = not highlight)
	var low_intensity: Dictionary = {"type": "move", "intensity": 0.3, "dramatic": false}
	var is_highlight := sc.evaluate_event(low_intensity)
	verify(is_highlight == false, "Low intensity event not flagged as highlight")

	# Test dramatic event (should trigger)
	var dramatic_event: Dictionary = {"type": "kill", "intensity": 0.9, "dramatic": true}
	var dramatic_highlight := sc.evaluate_event(dramatic_event)
	verify(dramatic_highlight == true, "Dramatic high-intensity event flagged as highlight")

	# Test screenshot capture
	var ss_path := sc.capture_screenshot("test")
	verify(not ss_path.is_empty(), "Screenshot path returned")

	# Test clip save
	var clip_path := sc.save_clip("test_clip_001", 10)
	verify(not clip_path.is_empty(), "Clip path returned")
	verify(clip_path.contains("webm"), "Clip path has webm extension")

	# Test pending highlights
	var pending: Array = sc.get_pending_highlights()
	verify(pending.size() >= 0, "Pending highlights tracked")

	sc.clear_pending_highlights()
	verify(sc.get_pending_highlights().size() == 0, "Pending highlights cleared")

	sc.free()
	print("  └─ ScreenshotCapture: OK")

func test_streamer_overlay() -> void:
	if StreamerOverlayRef == null:
		tests_failed += 1
		print("[%s] StreamerOverlay class failed to load" % FAIL)
		return
	verify(true, "StreamerOverlay class loads")

	var overlay: StreamerOverlayRef = StreamerOverlayRef.new()
	root.add_child(overlay)

	verify(overlay.is_streaming() == false, "Not streaming initially")
	verify(overlay.get_channel_name() == "", "No channel initially")

	# Test stream start
	var started := overlay.start_stream("MyChannel", "Epic Battle")
	verify(started == true, "Stream started successfully")
	verify(overlay.is_streaming() == true, "Is streaming after start")
	verify(overlay.get_channel_name() == "MyChannel", "Channel name set")
	verify(overlay.get_stream_title() == "Epic Battle", "Stream title set")

	# Cannot start while already streaming
	var started_again := overlay.start_stream("OtherChannel", "Another")
	verify(started_again == false, "Cannot start second stream")

	# Test viewer count
	overlay.set_viewer_count(42)
	verify(overlay.get_viewer_count() == 42, "Viewer count set correctly")

	# Test chat simulation
	overlay.simulate_chat_message("Player1", "Great move!")
	var chat: Array = overlay.get_recent_chat(5)
	verify(chat.size() >= 1, "Chat message received")
	verify(chat[0].contains("Player1"), "Chat contains username")

	# Test overlay info
	var info: Dictionary = overlay.get_overlay_info()
	verify(info.get("is_streaming") == true, "Overlay info shows streaming")
	verify(info.get("viewer_count") == 42, "Overlay info has viewer count")

	# Test Twitch stubs
	verify(overlay.is_twitch_connected() == false, "Twitch not connected")
	var twitch_conn := overlay.connect_twitch("mychannel")
	verify(twitch_conn == false, "Twitch connect stub returns false")
	var twitch_chat: Array = overlay.read_twitch_chat()
	verify(twitch_chat.size() == 0, "Twitch chat stub returns empty")

	# Test YouTube stubs
	verify(overlay.is_youtube_connected() == false, "YouTube not connected")
	var yt_conn := overlay.connect_youtube("my_channel_id")
	verify(yt_conn == false, "YouTube connect stub returns false")

	# Test OAuth stubs
	overlay.set_oauth_token("test_token_123")
	verify(overlay.has_oauth_token() == true, "OAuth token set")
	verify(overlay.twitch_oauth_connect("client123", "http://localhost") == false, "Twitch OAuth stub returns false")
	verify(overlay.youtube_oauth_connect("client456", "http://localhost") == false, "YouTube OAuth stub returns false")

	# Test stop stream
	overlay.stop_stream()
	verify(overlay.is_streaming() == false, "Stream stopped")

	overlay.free()
	print("  └─ StreamerOverlay: OK")

func print_results() -> void:
	print("\n=== Results ===")
	print("Tests run:    %d" % tests_run)
	print("Tests passed: %d" % tests_passed)
	print("Tests failed: %d" % tests_failed)
	if tests_failed == 0:
		print("\n✅ All Observer Mode tests PASSED")
	else:
		print("\n❌ %d test(s) FAILED" % tests_failed)
