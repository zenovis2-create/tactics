extends SceneTree

const MAIN_SCENE: PackedScene = preload("res://scenes/Main.tscn")
const CH08_FINAL_STAGE = preload("res://data/stages/ch08_05_stage.tres")

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var main: Node = MAIN_SCENE.instantiate()
	root.add_child(main)
	await process_frame
	await process_frame

	var campaign = main.campaign_controller
	if campaign == null:
		push_error("Campaign hunt integration runner could not resolve campaign controller.")
		quit(1)
		return

	campaign.debug_seed_chapter_camp(&"CH08", 4, CH08_FINAL_STAGE)
	await process_frame
	await process_frame

	var progression = campaign._get_progression_data()
	if progression == null:
		push_error("Campaign hunt integration runner expected progression data.")
		quit(1)
		return
	var hunt_ids: Array[StringName] = [&"hunt_basil", &"hunt_lete"]
	progression.unlocked_hunt_ids = hunt_ids
	main.battle_controller.last_result_summary = {
		"optional_objectives_completed": ["hunt_lete_black_hounds_preserved"],
		"battle_temp_flags": {"hunt_lete_gate_latch": true}
	}

	if not campaign.apply_hunt_victory_to_current_camp(&"hunt_lete"):
		push_error("Campaign hunt integration runner expected apply_hunt_victory_to_current_camp to succeed.")
		quit(1)
		return
	await process_frame
	await process_frame

	var snapshot: Dictionary = main.campaign_panel.get_snapshot()
	var inventory_entries: Array = snapshot.get("inventory_entries", [])
	if not _contains_line(inventory_entries, "금화 보상 +1000G"):
		push_error("CampaignPanel inventory should surface the committed hunt gold reward line.")
		quit(1)
		return
	if not _contains_line(inventory_entries, "흑견 보존 보너스 +200G"):
		push_error("CampaignPanel inventory should surface branched hunt bonus payout when the optional objective was completed.")
		quit(1)
		return
	var presentation_cards: Array = snapshot.get("presentation_cards", [])
	if presentation_cards.size() < 1:
		push_error("CampaignPanel should still expose presentation cards after hunt integration.")
		quit(1)
		return
	if not _contains_card_title(presentation_cards, "해금된 회상 2개"):
		push_error("CampaignPanel should surface recall hunt summary cards in camp mode.")
		quit(1)
		return
	if not _contains_card_title(presentation_cards, "레테 회상 토벌전 분기 귀환"):
		push_error("CampaignPanel should surface a branch-aware hunt return card after recall victory.")
		quit(1)
		return
	if not _contains_card_memory_stamp(presentation_cards, "HUNT_LETE / Optional Objective"):
		push_error("CampaignPanel branched hunt return card should surface a recall memory stamp for the optional objective branch.")
		quit(1)
		return
	if not _contains_card_progress_row(presentation_cards, "선택 목표"):
		push_error("CampaignPanel branched hunt return card should surface a dedicated optional-objective progress row.")
		quit(1)
		return
	if not _contains_card_outcome_line(presentation_cards, "보너스 정산과 귀환 기록이 강화되었다"):
		push_error("CampaignPanel branched hunt return card should surface a dedicated branch outcome line.")
		quit(1)
		return
	if not _contains_card_source_label(presentation_cards, "Return Surface"):
		push_error("CampaignPanel branched hunt return card should surface a dedicated source label.")
		quit(1)
		return
	if not _contains_card_eyebrow_label(presentation_cards, "Branch Return"):
		push_error("CampaignPanel branched hunt return card should surface a dedicated eyebrow label.")
		quit(1)
		return
	if not _contains_card_memory_rail(presentation_cards, "branch_return"):
		push_error("CampaignPanel branched hunt return card should surface a dedicated memory rail marker.")
		quit(1)
		return
	if not _contains_card_memory_stack(presentation_cards, "rail:branch_return"):
		push_error("CampaignPanel branched hunt return card should surface a compact branch memory stack.")
		quit(1)
		return
	if not _contains_card_memory_stack(presentation_cards, "eyebrow:branch_return") or not _contains_card_memory_stack(presentation_cards, "progress:branch_return"):
		push_error("CampaignPanel branched hunt return card should summarize eyebrow/progress in its memory stack.")
		quit(1)
		return
	if not _contains_card_memory_signature(presentation_cards, "branch_return|return_surface|branch_return"):
		push_error("CampaignPanel branched hunt return card should expose a compact branch memory signature.")
		quit(1)
		return
	if not _contains_card_eyebrow(presentation_cards, "분기 귀환"):
		push_error("CampaignPanel branched hunt return card should elevate its eyebrow when a branch summary exists.")
		quit(1)
		return
	if not _contains_card_title(presentation_cards, "레테 회상 토벌전"):
		push_error("CampaignPanel should surface the selected recall hunt in presentation cards.")
		quit(1)
		return
	if not _contains_card_body(presentation_cards, "최근 귀환: 흑견 추격대 보존 성공"):
		push_error("CampaignPanel selected recall hunt card should surface the latest branch summary.")
		quit(1)
		return
	if not _contains_card_body(presentation_cards, "흑견 추격대가 사라지기 전에"):
		push_error("CampaignPanel should surface hunt launch flavor text for the selected recall hunt.")
		quit(1)
		return
	if not _contains_card_title(presentation_cards, "레테 회상 토벌전 출정"):
		push_error("CampaignPanel should surface a dedicated hunt launch scene card.")
		quit(1)
		return
	if not _contains_card_title(presentation_cards, "레테 회상 토벌전 전개"):
		push_error("CampaignPanel should surface a dedicated hunt stage brief card.")
		quit(1)
		return
	if not _contains_card_body(presentation_cards, "랜드마크"):
		push_error("CampaignPanel should surface landmark/context lines for the selected recall hunt.")
		quit(1)
		return
	if not _contains_card_body(presentation_cards, "최근 제어"):
		push_error("CampaignPanel stage brief card should surface the latest branch control recap.")
		quit(1)
		return
	if not _contains_card_title(presentation_cards, "레테 회상 토벌전 제어 후일담"):
		push_error("CampaignPanel branched hunt return scene card should surface a branch-aware title.")
		quit(1)
		return
	if not _contains_card_memory_stamp(presentation_cards, "Gate Latch / Controlled"):
		push_error("CampaignPanel branched hunt return scene card should surface a control-result memory stamp.")
		quit(1)
		return
	if not _contains_card_progress_row(presentation_cards, "제어 결과"):
		push_error("CampaignPanel branched hunt return scene card should surface a dedicated control progress row.")
		quit(1)
		return
	if not _contains_card_outcome_line(presentation_cards, "다음 출정 준비 화면에도 제어 결과가 남는다"):
		push_error("CampaignPanel branched hunt return scene card should surface a dedicated control outcome line.")
		quit(1)
		return
	if not _contains_card_source_label(presentation_cards, "Control Surface"):
		push_error("CampaignPanel branched hunt return scene card should surface a dedicated control source label.")
		quit(1)
		return
	if not _contains_card_eyebrow_label(presentation_cards, "Control Aftermath"):
		push_error("CampaignPanel branched hunt return scene card should surface a dedicated control eyebrow label.")
		quit(1)
		return
	if not _contains_card_memory_rail(presentation_cards, "control_aftermath"):
		push_error("CampaignPanel branched hunt return scene card should surface a dedicated control memory rail marker.")
		quit(1)
		return
	if not _contains_card_memory_stack(presentation_cards, "rail:control_aftermath"):
		push_error("CampaignPanel branched hunt return scene card should surface a compact control memory stack.")
		quit(1)
		return
	if not _contains_card_memory_stack(presentation_cards, "eyebrow:control_aftermath") or not _contains_card_memory_stack(presentation_cards, "progress:control_aftermath"):
		push_error("CampaignPanel branched hunt return scene card should summarize eyebrow/progress in its memory stack.")
		quit(1)
		return
	if not _contains_card_memory_signature(presentation_cards, "control_aftermath|control_surface|control_aftermath"):
		push_error("CampaignPanel branched hunt return scene card should expose a compact control memory signature.")
		quit(1)
		return
	if not _contains_card_body(presentation_cards, "흑견 추격대 보존 성공"):
		push_error("CampaignPanel should surface the branched hunt return summary when the optional objective was completed.")
		quit(1)
		return
	if not _contains_card_title(presentation_cards, "흑견 추격대 보존"):
		push_error("CampaignPanel should surface a dedicated branch presentation card when the optional objective was completed.")
		quit(1)
		return
	if not _contains_card_body(presentation_cards, "이송문 걸쇠가 끝내 풀리고"):
		push_error("CampaignPanel should surface the branched hunt return cutscene override when the recall rule object was resolved.")
		quit(1)
		return
	var recommendation: String = String(snapshot.get("recommendation", ""))
	if recommendation.find("귀환 결과") == -1:
		push_error("CampaignPanel recommendation should mention the recall hunt return flow after hunt reward integration.")
		quit(1)
		return
	if recommendation.find("사냥의 마지막 흔적을 회수한 채") == -1:
		push_error("CampaignPanel recommendation should surface hunt return flavor text after recall victory.")
		quit(1)
		return
	if recommendation.find("레테 회상 토벌전") == -1:
		push_error("CampaignPanel recommendation should still surface the active hunt label after branch integration.")
		quit(1)
		return
	if not _contains_line(inventory_entries, "재료 보상"):
		push_error("CampaignPanel inventory should surface hunt-specific material reward lines.")
		quit(1)
		return

	print("[PASS] campaign_hunt_integration_runner: CampaignPanel surfaces hunt rewards and recall hunts in camp mode.")
	quit(0)

func _contains_line(lines: Array, needle: String) -> bool:
	for line in lines:
		if String(line).find(needle) != -1:
			return true
	return false

func _contains_card_title(cards: Array, needle: String) -> bool:
	for card in cards:
		if typeof(card) != TYPE_DICTIONARY:
			continue
		if String(card.get("title", "")).find(needle) != -1:
			return true
	return false

func _contains_card_body(cards: Array, needle: String) -> bool:
	for card in cards:
		if typeof(card) != TYPE_DICTIONARY:
			continue
		if String(card.get("body", "")).find(needle) != -1:
			return true
	return false

func _contains_card_eyebrow(cards: Array, needle: String) -> bool:
	for card in cards:
		if typeof(card) != TYPE_DICTIONARY:
			continue
		if String(card.get("eyebrow", "")).find(needle) != -1:
			return true
	return false

func _contains_card_memory_stamp(cards: Array, needle: String) -> bool:
	for card in cards:
		if typeof(card) != TYPE_DICTIONARY:
			continue
		if String(card.get("memory_stamp", "")).find(needle) != -1:
			return true
	return false

func _contains_card_progress_row(cards: Array, needle: String) -> bool:
	for card in cards:
		if typeof(card) != TYPE_DICTIONARY:
			continue
		for row in card.get("progress_rows", []):
			if typeof(row) != TYPE_DICTIONARY:
				continue
			if String(row.get("label", "")).find(needle) != -1:
				return true
	return false

func _contains_card_outcome_line(cards: Array, needle: String) -> bool:
	for card in cards:
		if typeof(card) != TYPE_DICTIONARY:
			continue
		if String(card.get("outcome_line", "")).find(needle) != -1:
			return true
	return false

func _contains_card_source_label(cards: Array, needle: String) -> bool:
	for card in cards:
		if typeof(card) != TYPE_DICTIONARY:
			continue
		if String(card.get("source_label", "")).find(needle) != -1:
			return true
	return false

func _contains_card_eyebrow_label(cards: Array, needle: String) -> bool:
	for card in cards:
		if typeof(card) != TYPE_DICTIONARY:
			continue
		if String(card.get("eyebrow_label", "")).find(needle) != -1:
			return true
	return false

func _contains_card_memory_rail(cards: Array, needle: String) -> bool:
	for card in cards:
		if typeof(card) != TYPE_DICTIONARY:
			continue
		if String(card.get("memory_rail", "")).find(needle) != -1:
			return true
	return false

func _contains_card_memory_stack(cards: Array, needle: String) -> bool:
	for card in cards:
		if typeof(card) != TYPE_DICTIONARY:
			continue
		for entry in card.get("memory_stack", []):
			if String(entry).find(needle) != -1:
				return true
	return false

func _contains_card_memory_signature(cards: Array, needle: String) -> bool:
	for card in cards:
		if typeof(card) != TYPE_DICTIONARY:
			continue
		if String(card.get("memory_signature", "")).find(needle) != -1:
			return true
	return false
