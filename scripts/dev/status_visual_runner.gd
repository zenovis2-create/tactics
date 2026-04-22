extends SceneTree

const SkillData = preload("res://scripts/data/skill_data.gd")
const UnitActor = preload("res://scripts/battle/unit_actor.gd")
const UnitData = preload("res://scripts/data/unit_data.gd")

var _failed: bool = false

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	if not _assert_skill_status_contract():
		return
	if not _assert_oblivion_visual_state():
		return
	if not _assert_fear_charm_dot_priority():
		return
	if not _assert_mark_visibility_and_priority():
		return
	if not _assert_status_badge_surface():
		return
	print("[PASS] status_visual_runner: all assertions passed.")
	quit(0)

func _build_actor(unit_id: StringName = &"status_visual_test") -> UnitActor:
	var actor := UnitActor.new()
	var data := UnitData.new()
	data.unit_id = unit_id
	data.display_name = "Status Visual Test"
	data.max_hp = 12
	data.attack = 4
	data.defense = 2
	actor.setup_from_data(data)
	return actor

func _assert_skill_status_contract() -> bool:
	var command_marker: SkillData = load("res://data/skills/command_marker.tres")
	var charm_gaze: SkillData = load("res://data/skills/charm_gaze.tres")
	var poison_mist: SkillData = load("res://data/skills/poison_mist.tres")
	if command_marker == null or charm_gaze == null or poison_mist == null:
		return _fail("status skill resources should load for visual contract checks")
	if not command_marker.applies_status() or command_marker.get_status_type() != &"mark":
		return _fail("command_marker should expose mark status metadata through SkillData")
	if charm_gaze.get_status_type() != &"charm":
		return _fail("charm_gaze should expose charm status metadata through SkillData")
	if poison_mist.get_status_type() != &"dot":
		return _fail("poison_mist should expose dot status metadata through SkillData")
	return true

func _assert_oblivion_visual_state() -> bool:
	var actor := _build_actor()
	actor.set_status_visual_state({"oblivion_stack": 2})
	var snapshot: Dictionary = actor.get_status_visual_snapshot()
	if String(snapshot.get("primary_status", "")) != "oblivion":
		return _fail("oblivion stack should promote oblivion as the primary status surface")
	if String(snapshot.get("telegraph_text", "")) != "망각 2":
		return _fail("oblivion visual text should expose the current stack count")
	if not bool(snapshot.get("nameplate_visible", false)):
		return _fail("status visuals should keep the nameplate visible for readability")
	actor.free()
	return true

func _assert_fear_charm_dot_priority() -> bool:
	var actor := _build_actor(&"status_priority_test")
	actor.set_status_visual_state({"fear_turns": 1, "dot_turns": 2})
	var snapshot: Dictionary = actor.get_status_visual_snapshot()
	if String(snapshot.get("primary_status", "")) != "fear":
		return _fail("fear should outrank dot in the actor status surface priority")
	if String(snapshot.get("telegraph_text", "")) != "공포 1T":
		return _fail("fear should expose a direct 공포 countdown label")
	if not bool(snapshot.get("status_pulse_active", false)):
		return _fail("fear activation should trigger a short status pulse animation.")
	if String(snapshot.get("status_pulse_profile", "")) != "fear":
		return _fail("fear activation should use the fear-specific pulse profile.")
	if bool(snapshot.get("status_idle_active", false)):
		return _fail("fear should rely on shake instead of a separate idle profile.")
	if bool(snapshot.get("status_accent_active", false)):
		return _fail("fear should keep relying on shake and skip the sustained accent layer.")
	actor.set_status_visual_state({"fear_turns": 0, "charm_turns": 2, "dot_turns": 2})
	snapshot = actor.get_status_visual_snapshot()
	if String(snapshot.get("primary_status", "")) != "charm":
		return _fail("charm should outrank dot in the actor status surface priority")
	if String(snapshot.get("telegraph_text", "")) != "유혹 2T":
		return _fail("charm should expose a direct 유혹 countdown label")
	if not bool(snapshot.get("status_pulse_active", false)):
		return _fail("charm activation should trigger a short status pulse animation.")
	if String(snapshot.get("status_pulse_profile", "")) != "charm":
		return _fail("charm activation should use the charm-specific pulse profile.")
	if not bool(snapshot.get("status_idle_active", false)) or String(snapshot.get("status_idle_profile", "")) != "charm":
		return _fail("charm should sustain a dedicated idle animation profile while active.")
	if not bool(snapshot.get("status_accent_active", false)) or String(snapshot.get("status_accent_profile", "")) != "charm":
		return _fail("charm should sustain a dedicated accent profile while active.")
	if not bool(snapshot.get("status_text_active", false)) or String(snapshot.get("status_text_profile", "")) != "charm":
		return _fail("charm should sustain a dedicated telegraph-text shimmer profile while active.")
	if not bool(snapshot.get("status_nameplate_active", false)) or String(snapshot.get("status_nameplate_profile", "")) != "charm":
		return _fail("charm should sustain a dedicated nameplate drift profile while active.")
	if not bool(snapshot.get("status_icon_active", false)) or String(snapshot.get("status_icon_profile", "")) != "charm":
		return _fail("charm should sustain a dedicated telegraph-icon drift profile while active.")
	if not bool(snapshot.get("status_badge_text_active", false)) or String(snapshot.get("status_badge_text_profile", "")) != "charm":
		return _fail("charm should sustain a dedicated badge-text shimmer profile while active.")
	if not _motion_stack_has(snapshot, "badge_text:charm"):
		return _fail("charm motion stack should summarize its badge-text shimmer profile.")
	if String(snapshot.get("status_motion_signature", "")).find("charm") == -1:
		return _fail("charm should expose a compact motion signature string.")
	actor.set_status_visual_state({})
	snapshot = actor.get_status_visual_snapshot()
	if String(snapshot.get("primary_status", "")) != "":
		return _fail("clearing charm should also clear the primary status surface.")
	if not bool(snapshot.get("status_release_active", false)) or String(snapshot.get("status_release_profile", "")) != "charm":
		return _fail("clearing charm should trigger the charm-specific release profile.")
	if not bool(snapshot.get("status_afterglow_active", false)) or String(snapshot.get("status_afterglow_profile", "")) != "charm":
		return _fail("clearing charm should leave a short charm-specific afterglow profile.")
	if not _motion_stack_has(snapshot, "afterglow:charm"):
		return _fail("clearing charm should add its afterglow profile into the motion stack.")
	actor.free()
	return true

func _assert_mark_visibility_and_priority() -> bool:
	var actor := _build_actor(&"status_mark_test")
	actor.set_status_visual_state({"mark_turns": 2})
	var snapshot: Dictionary = actor.get_status_visual_snapshot()
	if String(snapshot.get("primary_status", "")) != "mark":
		return _fail("mark turns should expose mark as the primary status")
	if String(snapshot.get("telegraph_text", "")) != "표식 2T":
		return _fail("mark turns should surface a visible 2T countdown")
	if not bool(snapshot.get("crosshair_visible", false)):
		return _fail("mark status should reuse the crosshair visibility surface")
	actor.set_boss_marked(true)
	snapshot = actor.get_status_visual_snapshot()
	if String(snapshot.get("primary_status", "")) != "boss_mark":
		return _fail("boss mark should outrank normal mark in the actor status surface priority")
	if String(snapshot.get("telegraph_text", "")) != "MARK":
		return _fail("boss mark should keep the explicit MARK label")
	actor.free()
	return true

func _assert_status_badge_surface() -> bool:
	var actor := _build_actor(&"status_badge_test")
	actor.set_status_visual_state({"oblivion_stack": 2})
	var snapshot: Dictionary = actor.get_status_visual_snapshot()
	if not bool(snapshot.get("status_badge_visible", false)):
		return _fail("status badge should be visible when a primary status exists")
	if String(snapshot.get("status_badge_text", "")) != "망":
		return _fail("oblivion badge should expose 망 as its compact status code")
	if not bool(snapshot.get("status_badge_icon_visible", false)):
		return _fail("status badge should expose a dedicated icon texture when a primary status exists")
	if String(snapshot.get("status_badge_icon_kind", "")) != "status_oblivion":
		return _fail("oblivion badge should expose the status_oblivion icon kind")
	if String(snapshot.get("status_pulse_profile", "")) != "oblivion":
		return _fail("oblivion activation should use the oblivion-specific pulse profile.")
	if not bool(snapshot.get("status_idle_active", false)) or String(snapshot.get("status_idle_profile", "")) != "oblivion":
		return _fail("oblivion should sustain a dedicated idle animation profile while active.")
	if not bool(snapshot.get("status_accent_active", false)) or String(snapshot.get("status_accent_profile", "")) != "oblivion":
		return _fail("oblivion should sustain a dedicated accent profile while active.")
	if not bool(snapshot.get("status_text_active", false)) or String(snapshot.get("status_text_profile", "")) != "oblivion":
		return _fail("oblivion should sustain a dedicated telegraph-text shimmer profile while active.")
	if not bool(snapshot.get("status_nameplate_active", false)) or String(snapshot.get("status_nameplate_profile", "")) != "oblivion":
		return _fail("oblivion should sustain a dedicated nameplate drift profile while active.")
	if not bool(snapshot.get("status_icon_active", false)) or String(snapshot.get("status_icon_profile", "")) != "oblivion":
		return _fail("oblivion should sustain a dedicated telegraph-icon drift profile while active.")
	if not bool(snapshot.get("status_badge_text_active", false)) or String(snapshot.get("status_badge_text_profile", "")) != "oblivion":
		return _fail("oblivion should sustain a dedicated badge-text shimmer profile while active.")
	if not _motion_stack_has(snapshot, "icon:oblivion"):
		return _fail("oblivion motion stack should summarize its icon drift profile.")
	if String(snapshot.get("status_motion_signature", "")).find("oblivion") == -1:
		return _fail("oblivion should expose a compact motion signature string.")
	actor.set_status_visual_state({"fear_turns": 1})
	snapshot = actor.get_status_visual_snapshot()
	if String(snapshot.get("status_badge_text", "")) != "공1":
		return _fail("fear badge should append its remaining turn count")
	if String(snapshot.get("telegraph_text", "")) != "공포 1T":
		return _fail("fear telegraph should append its remaining turn countdown")
	if String(snapshot.get("status_badge_icon_kind", "")) != "status_fear":
		return _fail("fear badge should expose the status_fear icon kind")
	actor.set_status_visual_state({"charm_turns": 3})
	snapshot = actor.get_status_visual_snapshot()
	if String(snapshot.get("status_badge_text", "")) != "유3":
		return _fail("charm badge should append its remaining turn count")
	if String(snapshot.get("telegraph_text", "")) != "유혹 3T":
		return _fail("charm telegraph should append its remaining turn countdown")
	actor.set_status_visual_state({"dot_turns": 4})
	snapshot = actor.get_status_visual_snapshot()
	if String(snapshot.get("status_badge_text", "")) != "지4":
		return _fail("dot badge should append its remaining turn count")
	if String(snapshot.get("telegraph_text", "")) != "지속 4T":
		return _fail("dot telegraph should append its remaining turn countdown")
	actor.set_status_visual_state({"mark_turns": 2})
	snapshot = actor.get_status_visual_snapshot()
	if String(snapshot.get("status_badge_text", "")) != "표2":
		return _fail("mark badge should append its remaining turn count")
	if String(snapshot.get("telegraph_text", "")) != "표식 2T":
		return _fail("mark telegraph should append its remaining turn countdown")
	if String(snapshot.get("status_badge_icon_kind", "")) != "status_mark":
		return _fail("mark badge should expose the status_mark icon kind")
	if String(snapshot.get("status_pulse_profile", "")) != "mark":
		return _fail("mark activation should use the mark-specific pulse profile.")
	if not bool(snapshot.get("status_idle_active", false)) or String(snapshot.get("status_idle_profile", "")) != "mark":
		return _fail("mark should sustain a dedicated idle animation profile while active.")
	if not bool(snapshot.get("status_accent_active", false)) or String(snapshot.get("status_accent_profile", "")) != "mark":
		return _fail("mark should sustain a dedicated accent profile while active.")
	if not bool(snapshot.get("status_text_active", false)) or String(snapshot.get("status_text_profile", "")) != "mark":
		return _fail("mark should sustain a dedicated telegraph-text shimmer profile while active.")
	if not bool(snapshot.get("status_nameplate_active", false)) or String(snapshot.get("status_nameplate_profile", "")) != "mark":
		return _fail("mark should sustain a dedicated nameplate drift profile while active.")
	if not bool(snapshot.get("status_icon_active", false)) or String(snapshot.get("status_icon_profile", "")) != "mark":
		return _fail("mark should sustain a dedicated telegraph-icon drift profile while active.")
	if not bool(snapshot.get("status_badge_text_active", false)) or String(snapshot.get("status_badge_text_profile", "")) != "mark":
		return _fail("mark should sustain a dedicated badge-text shimmer profile while active.")
	if not _motion_stack_has(snapshot, "nameplate:mark"):
		return _fail("mark motion stack should summarize its nameplate drift profile.")
	if String(snapshot.get("status_motion_signature", "")).find("mark") == -1:
		return _fail("mark should expose a compact motion signature string.")
	actor.set_boss_marked(true)
	snapshot = actor.get_status_visual_snapshot()
	if String(snapshot.get("status_badge_text", "")) != "MK":
		return _fail("boss mark badge should outrank normal mark and expose MK")
	if String(snapshot.get("status_badge_icon_kind", "")) != "status_boss_mark":
		return _fail("boss mark badge should expose the status_boss_mark icon kind")
	if String(snapshot.get("status_pulse_profile", "")) != "boss_mark":
		return _fail("boss mark activation should use the boss-mark-specific pulse profile.")
	if not bool(snapshot.get("status_idle_active", false)) or String(snapshot.get("status_idle_profile", "")) != "boss_mark":
		return _fail("boss mark should sustain a dedicated idle animation profile while active.")
	if not bool(snapshot.get("status_accent_active", false)) or String(snapshot.get("status_accent_profile", "")) != "boss_mark":
		return _fail("boss mark should sustain a dedicated accent profile while active.")
	if not bool(snapshot.get("status_text_active", false)) or String(snapshot.get("status_text_profile", "")) != "boss_mark":
		return _fail("boss mark should sustain a dedicated telegraph-text shimmer profile while active.")
	if not bool(snapshot.get("status_nameplate_active", false)) or String(snapshot.get("status_nameplate_profile", "")) != "boss_mark":
		return _fail("boss mark should sustain a dedicated nameplate drift profile while active.")
	if not bool(snapshot.get("status_icon_active", false)) or String(snapshot.get("status_icon_profile", "")) != "boss_mark":
		return _fail("boss mark should sustain a dedicated telegraph-icon drift profile while active.")
	if not bool(snapshot.get("status_badge_text_active", false)) or String(snapshot.get("status_badge_text_profile", "")) != "boss_mark":
		return _fail("boss mark should sustain a dedicated badge-text shimmer profile while active.")
	if not _motion_stack_has(snapshot, "badge_text:boss_mark"):
		return _fail("boss mark motion stack should summarize its badge-text shimmer profile.")
	if String(snapshot.get("status_motion_signature", "")).find("boss_mark") == -1:
		return _fail("boss mark should expose a compact motion signature string.")
	actor.set_status_visual_state({})
	actor.set_boss_marked(false)
	snapshot = actor.get_status_visual_snapshot()
	if String(snapshot.get("primary_status", "")) != "":
		return _fail("clearing boss mark should clear the primary status surface.")
	if not bool(snapshot.get("status_release_active", false)) or String(snapshot.get("status_release_profile", "")) != "boss_mark":
		return _fail("clearing boss mark should trigger the boss-mark-specific release profile.")
	if not bool(snapshot.get("status_afterglow_active", false)) or String(snapshot.get("status_afterglow_profile", "")) != "boss_mark":
		return _fail("clearing boss mark should leave a short boss-mark-specific afterglow profile.")
	if not _motion_stack_has(snapshot, "afterglow:boss_mark"):
		return _fail("clearing boss mark should add its afterglow profile into the motion stack.")
	actor.free()
	return true

func _fail(message: String) -> bool:
	print("[FAIL] %s" % message)
	_failed = true
	quit(1)
	return false

func _motion_stack_has(snapshot: Dictionary, needle: String) -> bool:
	for entry in snapshot.get("status_motion_stack", []):
		if String(entry).find(needle) != -1:
			return true
	return false
