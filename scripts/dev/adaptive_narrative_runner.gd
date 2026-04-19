extends SceneTree

const SaveService = preload("res://scripts/battle/save_service.gd")
const ProgressionData = preload("res://scripts/data/progression_data.gd")
const ChronicleGenerator = preload("res://scripts/battle/chronicle_generator.gd")
const EthicsTracker = preload("res://scripts/battle/ethics_tracker.gd")
const MoralConsequenceService = preload("res://scripts/battle/moral_consequence_service.gd")
const NPCPersonalityTracker = preload("res://scripts/battle/npc_personality_tracker.gd")
const AdaptiveDialogueFilter = preload("res://scripts/battle/adaptive_dialogue_filter.gd")
const CampaignController = preload("res://scripts/campaign/campaign_controller.gd")
const CampaignShellDialogueCatalog = preload("res://scripts/campaign/campaign_shell_dialogue_catalog.gd")

var _failed: bool = false

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var save_service := SaveService.new()
	root.add_child(save_service)
	await process_frame
	save_service.delete_slot(11)

	var progression := ProgressionData.new()
	var save_error := save_service.save_progression(progression, 11)
	if save_error != OK:
		_fail("Expected fresh slot_11 save to succeed, got %s" % error_string(save_error))
		return
	progression = save_service.load_progression(11)
	if progression == null:
		_fail("Expected slot_11 load to return ProgressionData.")
		return

	var ethics: EthicsTracker = _resolve_ethics_tracker(progression)
	var moral_consequence: MoralConsequenceService = _resolve_moral_consequence(progression)
	var personality: Node = _resolve_personality_tracker(progression)
	var adaptive_filter: Node = _resolve_adaptive_filter()
	var chronicle: ChronicleGenerator = ChronicleGenerator.new()
	var campaign_controller: CampaignController = CampaignController.new()
	root.add_child(chronicle)
	root.add_child(campaign_controller)
	if ethics == null or moral_consequence == null or personality == null or adaptive_filter == null:
		_fail("Adaptive narrative dependencies should be available for verification.")
		return

	ethics.reset_tracking()
	ethics.record_decision("CH10", "burned_bridge", 0.0)
	ethics.record_decision("CH10", "left_unit_to_die", 0.0)
	ethics.record_decision("CH10", "ignored_warning", 0.0)
	if not _assert(ethics.get_ethics_bracket() == "ruthless", "EthicsTracker should classify the ruthless branch for adaptive dialogue."):
		return
	if not _assert(moral_consequence.get_boss_dialogue_variant_key("leonika", "ch10_final") == "_CH10_LEONIKA_RUTHLESS", "MoralConsequenceService should expose the ruthless Leonika key."):
		return

	var aggressive_context := chronicle.build_adaptive_dialogue_context("CH10", [{
		"turn_count": 5,
		"enemy_count": 7,
		"ally_count": 2,
		"key_moments": [
			{"type": "attack", "actor_id": "ally_rian", "target_id": "enemy_saria"},
			{"type": "attack", "actor_id": "ally_serin", "target_id": "enemy_guard"},
			{"type": "attack", "actor_id": "ally_noah", "target_id": "enemy_guard_2"}
		]
	}], progression.choices_made)
	if not _assert(String(aggressive_context.get("pattern", "")) == "aggressive", "ChronicleGenerator should classify rush records as aggressive."):
		return
	if not _assert(String(adaptive_filter.get_adapted_dialogue_key("leonika", "ch10_final", aggressive_context)) == "_CH10_LEONIKA_RUTHLESS", "AdaptiveDialogueFilter should resolve the ruthless Leonika key."):
		return
	var ruthless_lines: Array[String] = adaptive_filter.filter_dialogue_tree(CampaignShellDialogueCatalog.get_adaptive_dialogue_tree("leonika", "ch10_final"), "leonika", aggressive_context)
	if not _assert(ruthless_lines.size() == 1 and String(ruthless_lines[0]).find("돌진") != -1, "Ruthless dialogue tree should return the Leonika ruthless line."):
		return

	ethics.reset_tracking()
	var defensive_context := chronicle.build_adaptive_dialogue_context("CH10", [{
		"turn_count": 15,
		"enemy_count": 5,
		"ally_count": 4,
		"weather_events": ["storm", "fog", "rain"],
		"key_moments": [
			{"type": "weather", "actor_id": "ally_noah", "weather_effect_id": "storm_pressure"},
			{"type": "sacrifice_play", "actor_id": "ally_serin", "protected_unit_id": "ally_rian"}
		]
	}], progression.choices_made)
	if not _assert(String(defensive_context.get("pattern", "")) == "defensive", "ChronicleGenerator should classify stall records as defensive."):
		return
	if not _assert(String(adaptive_filter.get_expression_mood("leonika", defensive_context)) == "defensive", "Defensive chronicle context should switch Leonika to the defensive expression icon."):
		return

	ethics.reset_tracking()
	ethics.record_decision("CH10", "spared_enemy", 0.0)
	ethics.record_decision("CH10", "saved_supply_train", 0.0)
	ethics.record_decision("CH10", "recruited_hidden_unit", 0.0)
	ethics.record_decision("CH10", "saved_supply_train", 0.0)
	if not _assert(ethics.get_ethics_bracket() == "compassionate", "EthicsTracker should classify the compassionate branch for adaptive dialogue."):
		return
	if not _assert(moral_consequence.get_boss_dialogue_variant_key("leonika", "ch10_final") == "_CH10_LEONIKA_COMPASSIONATE", "MoralConsequenceService should expose the compassionate Leonika key."):
		return
	var merciful_context := chronicle.build_adaptive_dialogue_context("CH10", [{
		"turn_count": 11,
		"enemy_count": 3,
		"ally_count": 3,
		"key_moments": [
			{"type": "mercy_pause", "actor_id": "ally_rian", "boss_low_hp": true, "paused_attack": true, "boss_hp": 4, "boss_max_hp": 20}
		]
	}], ["spared_enemy"])
	if not _assert(String(merciful_context.get("pattern", "")) == "merciful", "ChronicleGenerator should classify low-HP mercy pauses as merciful."):
		return
	if not _assert(String(adaptive_filter.get_adapted_dialogue_key("leonika", "ch10_final", merciful_context)) == "_CH10_LEONIKA_COMPASSIONATE", "AdaptiveDialogueFilter should resolve the compassionate Leonika key."):
		return
	var compassionate_lines: Array[String] = adaptive_filter.filter_dialogue_tree(CampaignShellDialogueCatalog.get_adaptive_dialogue_tree("leonika", "ch10_final"), "leonika", merciful_context)
	if not _assert(compassionate_lines.size() == 1 and String(compassionate_lines[0]).find("다르게 끝낼 수 있어") != -1, "Compassionate dialogue tree should return the Leonika compassionate line."):
		return

	var chronicle_entry = chronicle.generate_entry("CH10", [{
		"turn_count": 11,
		"enemy_count": 3,
		"ally_count": 3,
		"weather_events": ["storm", "fog", "rain"],
		"key_moments": [
			{"type": "mercy_pause", "actor_id": "ally_rian", "boss_low_hp": true, "paused_attack": true, "boss_hp": 4, "boss_max_hp": 20},
			{"type": "weather", "actor_id": "ally_noah", "weather_effect_id": "storm_pressure"}
		]
	}], ["spared_enemy"])
	if chronicle_entry == null:
		_fail("ChronicleGenerator should create a chronicle entry for adaptive verification.")
		return
	var adapted_ch10_lines := campaign_controller.adapt_dialogue_by_chronicle(["Rian: The bell is within reach."], "ch10_final")
	if not _assert(adapted_ch10_lines.size() >= 2, "CampaignController should prepend adaptive CH10 Leonika dialogue."):
		return
	if not _assert(String(adapted_ch10_lines[0]).find("🕊️") != -1 and String(adapted_ch10_lines[0]).find("Leonika") != -1, "Adaptive CH10 line should include Leonika's compassionate icon and name."):
		return
	if not _assert(String(adapted_ch10_lines[1]).find("📜") != -1, "Chronicle reference should be injected ahead of the base CH10 dialogue."):
		return

	campaign_controller._on_s_rank_ally_died(&"ally_serin", "Serin", 5)
	var memorial_lines := campaign_controller.adapt_dialogue_by_chronicle(["Rian: We will carry Serin forward."], "")
	if not _assert(memorial_lines.size() >= 2, "Bond death should prepend an NPC mourning line."):
		return
	if not _assert(String(memorial_lines[0]).find("🕯️") != -1 and String(memorial_lines[0]).find("Serin") != -1, "Bond death mourning line should include the memorial icon and fallen name."):
		return
	if not _assert(String(CampaignShellDialogueCatalog.get_expression_icon("leonika", "defensive")) == "🛡️", "Dialogue catalog should expose the defensive expression icon."):
		return

	print("[PASS] adaptive_narrative_runner: chronicle patterns, Leonika ethics tracks, memorial mourning, and expression icons validated.")
	quit(0)

func _resolve_ethics_tracker(progression: ProgressionData) -> EthicsTracker:
	var tracker = root.get_node_or_null("Ethics")
	if tracker == null:
		tracker = EthicsTracker.new()
		tracker.name = "Ethics"
		root.add_child(tracker)
	tracker.bind_progression(progression)
	return tracker

func _resolve_moral_consequence(progression: ProgressionData) -> MoralConsequenceService:
	var service = root.get_node_or_null("MoralConsequence")
	if service == null:
		service = MoralConsequenceService.new()
		service.name = "MoralConsequence"
		root.add_child(service)
	service.bind_progression(progression)
	return service

func _resolve_personality_tracker(progression: ProgressionData) -> Node:
	var tracker = root.get_node_or_null("NPCPersonality")
	if tracker == null:
		tracker = NPCPersonalityTracker.new()
		tracker.name = "NPCPersonality"
		root.add_child(tracker)
	tracker.reset(progression)
	return tracker

func _resolve_adaptive_filter() -> Node:
	var adaptive_filter = root.get_node_or_null("AdaptiveDialogueFilter")
	if adaptive_filter != null:
		return adaptive_filter
	adaptive_filter = AdaptiveDialogueFilter.new()
	adaptive_filter.name = "AdaptiveDialogueFilter"
	root.add_child(adaptive_filter)
	return adaptive_filter

func _assert(condition: bool, message: String) -> bool:
	if condition:
		return true
	_fail(message)
	return false

func _fail(message: String) -> void:
	_failed = true
	print("[FAIL] %s" % message)
	quit(1)
