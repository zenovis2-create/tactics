extends SceneTree

const CampaignPanelScene: PackedScene = preload("res://scenes/campaign/CampaignPanel.tscn")
const BondService = preload("res://scripts/battle/bond_service.gd")
const ProgressionData = preload("res://scripts/data/progression_data.gd")
const SupportConversations = preload("res://scripts/data/support_conversations.gd")

const SUPPORT_OPTION_A := "support_context_A"
const SUPPORT_OPTION_B := "support_context_B"
const SUPPORT_OPTION_C := "support_context_C"
const SUPPORT_PENDING_BONUS := 2
const SUPPORT_PAIR_ID := "ally_rian:ally_serin"

var _failed: bool = false
var _pass_count: int = 0
var _fail_count: int = 0

class SupportHarness:
	extends Node

	var bond_service: BondService
	var progression: ProgressionData
	var panel
	var active_support_conversation: Dictionary = {}
	var current_camp_title: String = ""
	var current_camp_body: String = ""

	func _init(bound_panel) -> void:
		panel = bound_panel
		bond_service = BondService.new()
		progression = ProgressionData.new()
		add_child(bond_service)
		panel.advance_requested.connect(_on_advance_requested)
		panel.choice_selected.connect(_on_choice_selected)
		reset_state()

	func reset_state() -> void:
		progression.reset_for_new_campaign()
		bond_service.setup_progression(progression)
		bond_service.reset()
		active_support_conversation.clear()
		current_camp_title = ""
		current_camp_body = ""

	func seed_support_progress(chapter_id: String, stage_id: String, battle_count: int) -> void:
		for _i in range(battle_count):
			var entry := bond_service.register_support_progress(&"ally_rian", &"ally_serin", StringName(chapter_id), StringName(stage_id))
			var milestone_rank: int = int(entry.get("milestone_rank_after", 0))
			if milestone_rank >= 3:
				progression.mark_support_conversation_available(SUPPORT_PAIR_ID, milestone_rank)
				progression.record_support_history({
					"pair": SUPPORT_PAIR_ID,
					"rank": milestone_rank,
					"chapter": chapter_id,
					"stage_id": stage_id,
					"timestamp": Time.get_unix_time_from_system(),
					"topic": SupportConversations.get_support_conversation_entry(SUPPORT_PAIR_ID, milestone_rank).get("topic", ""),
					"viewed": false,
					"consume_available": false
				})

	func show_camp(title_text: String, body_text: String) -> void:
		current_camp_title = title_text
		current_camp_body = body_text
		panel.show_state("camp", title_text, body_text, _resolve_camp_button_text())

	func _resolve_camp_button_text() -> String:
		if not progression.available_support_conversations.is_empty():
			return "View Support Conversation"
		return "Next Battle"

	func _on_advance_requested() -> void:
		if progression.available_support_conversations.is_empty():
			return
		_show_support_conversation()

	func _show_support_conversation() -> void:
		var conversation_key := String(progression.available_support_conversations[0]).strip_edges()
		var parts := conversation_key.rsplit(":", true, 1)
		var pair_id := SupportConversations.normalize_pair_id(parts[0])
		var support_rank := int(parts[1])
		var entry := SupportConversations.get_support_conversation_entry(pair_id, support_rank)
		var pending_bonus := bond_service.get_pending_support_bonus(pair_id)
		var prompt := String(entry.get("topic", "")).strip_edges()
		if pending_bonus > 0:
			prompt += "\n\nDeep trust lingers from the last silence: next support rank change gains +%d." % pending_bonus
		active_support_conversation = {
			"pair": pair_id,
			"rank": support_rank,
			"topic": String(entry.get("topic", "")).strip_edges(),
			"options": [
				{"id": SUPPORT_OPTION_A, "label": String(entry.get("context_A", "")).strip_edges(), "hint": "응원의 말 · Support Rank +1"},
				{"id": SUPPORT_OPTION_B, "label": String(entry.get("context_B", "")).strip_edges(), "hint": "솔직한 느낌 · Support Rank unchanged"},
				{"id": SUPPORT_OPTION_C, "label": String(entry.get("context_C", "")).strip_edges(), "hint": "조용히 듣기 · Support Rank -1 now, +2 next conversation"}
			],
			"pending_bonus": pending_bonus
		}
		panel.show_state(
			"choice",
			"Support Conversation — Rian / Serin",
			String(entry.get("topic", "")).strip_edges(),
			"",
			{
				"choice_stage_id": "support_conversation",
				"choice_prompt": prompt,
				"choice_options": active_support_conversation.get("options", []),
				"dialogue_entries": [
					"Serin: %s" % String(entry.get("topic", "")).strip_edges(),
					"Rian: The answer will change what this bond becomes next."
				]
			}
		)

	func _on_choice_selected(option_id: String) -> void:
		if active_support_conversation.is_empty():
			return
		var pair_id := String(active_support_conversation.get("pair", "")).strip_edges()
		var support_rank := int(active_support_conversation.get("rank", 0))
		var base_delta := 0
		match option_id:
			SUPPORT_OPTION_A:
				base_delta = 1
			SUPPORT_OPTION_B:
				base_delta = 0
			SUPPORT_OPTION_C:
				base_delta = -1
			_:
				return
		var bonus_applied := bond_service.consume_pending_support_bonus(pair_id)
		var rank_after := bond_service.modify_support_rank(pair_id, base_delta + bonus_applied)
		if option_id == SUPPORT_OPTION_C:
			bond_service.queue_next_support_bonus(pair_id, SUPPORT_PENDING_BONUS)
		progression.record_support_history({
			"pair": pair_id,
			"rank": support_rank,
			"chapter": "runner",
			"stage_id": "support_interactive_runner",
			"timestamp": Time.get_unix_time_from_system(),
			"topic": String(active_support_conversation.get("topic", "")).strip_edges(),
			"selected_option": option_id,
			"selected_text": _resolve_selected_text(option_id),
			"base_delta": base_delta,
			"bonus_applied": bonus_applied,
			"rank_after": rank_after,
			"viewed": true,
			"consume_available": true
		})
		active_support_conversation.clear()
		show_camp(current_camp_title, current_camp_body)

	func _resolve_selected_text(option_id: String) -> String:
		for option_variant in active_support_conversation.get("options", []):
			if typeof(option_variant) != TYPE_DICTIONARY:
				continue
			var option := option_variant as Dictionary
			if String(option.get("id", "")).strip_edges() == option_id.strip_edges():
				return String(option.get("label", "")).strip_edges()
		return option_id.strip_edges()

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	await _test_support_conversation_requires_manual_entry()
	await _test_quiet_listen_lowers_rank_and_queues_bonus()
	await _test_next_support_conversation_consumes_bonus()
	_finalize()

func _test_support_conversation_requires_manual_entry() -> void:
	var panel = CampaignPanelScene.instantiate()
	root.add_child(panel)
	await process_frame
	var harness := SupportHarness.new(panel)
	root.add_child(harness)
	await process_frame
	harness.seed_support_progress("CH04", "CH04_05", 3)
	harness.show_camp("CH04 Monastery Interlude", "Camp review before the next battle.")
	await process_frame
	var camp_snapshot: Dictionary = panel.get_snapshot()
	var advance_button: Button = panel.get_node("Panel/Margin/Content/FooterRow/AdvanceButton")
	_assert(String(camp_snapshot.get("mode", "")) == "camp", "Support unlock leaves the panel in camp mode until the player opens it")
	_assert(advance_button.text == "View Support Conversation", "Camp panel advertises a manual support-conversation trigger")
	panel.advance_requested.emit()
	await process_frame
	await process_frame
	var choice_snapshot: Dictionary = panel.get_snapshot()
	var options: Array = choice_snapshot.get("choice_options", [])
	var expected_entry := SupportConversations.get_support_conversation_entry(SUPPORT_PAIR_ID, 3)
	_assert(String(choice_snapshot.get("mode", "")) == "choice", "Manual camp trigger opens the support choice panel")
	_assert(String(choice_snapshot.get("choice_stage_id", "")) == "support_conversation", "Support panel marks its snapshot as a support conversation")
	_assert(options.size() == 3, "Support conversation shows exactly three choices")
	_assert(String(options[0].get("label", "")) == String(expected_entry.get("context_A", "")), "The panel uses the topic-specific option phrasing from SupportConversations")
	panel.choice_selected.emit(SUPPORT_OPTION_A)
	await process_frame
	await process_frame
	_assert(harness.bond_service.get_support_rank(&"ally_rian", &"ally_serin") == 4, "Choosing the encouraging response increases support rank by 1")
	_assert(harness.progression.available_support_conversations.is_empty(), "Resolving the support conversation consumes the pending queue entry")
	var history: Array[Dictionary] = harness.progression.get_support_history_for_pair(SUPPORT_PAIR_ID)
	_assert(history.size() == 1, "Support history keeps one merged entry for the viewed conversation")
	_assert(bool(history[0].get("viewed", false)), "Support history marks the viewed conversation")
	panel.queue_free()
	harness.queue_free()
	await process_frame

func _test_quiet_listen_lowers_rank_and_queues_bonus() -> void:
	var panel = CampaignPanelScene.instantiate()
	root.add_child(panel)
	await process_frame
	var harness := SupportHarness.new(panel)
	root.add_child(harness)
	await process_frame
	harness.seed_support_progress("CH04", "CH04_05", 3)
	harness.show_camp("CH04 Monastery Interlude", "Camp review before the next battle.")
	await process_frame
	panel.advance_requested.emit()
	await process_frame
	await process_frame
	var before_rank: int = harness.bond_service.get_support_rank(&"ally_rian", &"ally_serin")
	panel.choice_selected.emit(SUPPORT_OPTION_C)
	await process_frame
	await process_frame
	var after_rank: int = harness.bond_service.get_support_rank(&"ally_rian", &"ally_serin")
	_assert(after_rank == before_rank - 1, "Quiet listening lowers support rank by 1 immediately")
	_assert(harness.bond_service.get_pending_support_bonus(SUPPORT_PAIR_ID) == 2, "Quiet listening stores a +2 trust bonus for the next support talk")
	panel.queue_free()
	harness.queue_free()
	await process_frame

func _test_next_support_conversation_consumes_bonus() -> void:
	var panel = CampaignPanelScene.instantiate()
	root.add_child(panel)
	await process_frame
	var harness := SupportHarness.new(panel)
	root.add_child(harness)
	await process_frame
	harness.seed_support_progress("CH04", "CH04_05", 3)
	harness.show_camp("CH04 Monastery Interlude", "Camp review before the next battle.")
	await process_frame
	panel.advance_requested.emit()
	await process_frame
	await process_frame
	panel.choice_selected.emit(SUPPORT_OPTION_C)
	await process_frame
	await process_frame
	harness.seed_support_progress("CH06", "CH06_05", 3)
	harness.show_camp("CH06 Valtor Interlude", "Another support conversation is waiting in camp.")
	await process_frame
	_assert(harness.progression.available_support_conversations.has("%s:4" % SUPPORT_PAIR_ID), "The next shared-battle milestone still unlocks after the quiet-listen penalty")
	panel.advance_requested.emit()
	await process_frame
	await process_frame
	var before_rank: int = harness.bond_service.get_support_rank(&"ally_rian", &"ally_serin")
	panel.choice_selected.emit(SUPPORT_OPTION_B)
	await process_frame
	await process_frame
	var after_rank: int = harness.bond_service.get_support_rank(&"ally_rian", &"ally_serin")
	_assert(after_rank == before_rank + 2, "The queued +2 trust bonus applies during the next support conversation")
	_assert(harness.bond_service.get_pending_support_bonus(SUPPORT_PAIR_ID) == 0, "The deferred support bonus is consumed once the next support talk resolves")
	panel.queue_free()
	harness.queue_free()
	await process_frame

func _assert(condition: bool, description: String) -> void:
	if condition:
		_pass_count += 1
		print("[PASS] %s" % description)
		return
	_fail(description)

func _fail(message: String) -> void:
	_fail_count += 1
	_failed = true
	push_error(message)

func _finalize() -> void:
	if _failed:
		push_error("support_interactive_runner: %d passed, %d failed" % [_pass_count, _fail_count])
		quit(1)
		return
	print("[PASS] support_interactive_runner: all %d assertions passed." % _pass_count)
	quit(0)
