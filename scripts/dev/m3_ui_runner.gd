extends SceneTree

const MAIN_SCENE: PackedScene = preload("res://scenes/Main.tscn")

var _failed: bool = false

func _initialize() -> void:
    call_deferred("_run")

func _run() -> void:
    var main: Node = MAIN_SCENE.instantiate()
    root.add_child(main)

    await process_frame
    await process_frame

    var battle = main.battle_controller
    if battle == null:
        _fail("Main is missing battle_controller reference.")
        return

    # 타이틀 화면을 건너뛰고 즉시 배틀 시작 (테스트 전용)
    if main.has_method("start_game_direct"):
        main.start_game_direct()
        await process_frame
        await process_frame

    if not await _assert_mobile_layout_contract(main):
        return
    if not await _assert_battle_hud_inventory_and_input_block(battle):
        return
    if not _assert_battle_result_surface(battle):
        return
    if not _assert_structured_result_and_feedback_surfaces(battle):
        return
    if not await _advance_campaign_to_camp(main):
        return
    if not _assert_campaign_panel_snapshot(main.campaign_panel):
        return
    if not _assert_campaign_save_entry(main):
        return
    if not _assert_result_to_record_handoff(main):
        return
    if not await _assert_campaign_panel_selection_persistence(main):
        return

    print("[PASS] M3 UI runner verified battle HUD inventory and camp shell snapshots.")
    quit(0)

func _assert_mobile_layout_contract(main) -> bool:
    var battle = main.battle_controller
    if not battle.hud.has_method("apply_layout_for_viewport_size"):
        return _fail("BattleHUD is missing apply_layout_for_viewport_size() for mobile layout verification.")

    if not battle.hud.has_method("get_layout_snapshot"):
        return _fail("BattleHUD is missing get_layout_snapshot() for mobile layout verification.")

    battle.hud.apply_layout_for_viewport_size(Vector2(430, 900))
    await process_frame

    var hud_layout: Dictionary = battle.hud.get_layout_snapshot()
    if not bool(hud_layout.get("compact", false)):
        return _fail("BattleHUD should enter compact layout on narrow viewports.")

    if not battle.hud.phase_label.text.begins_with("Phase: "):
        return _fail("BattleHUD phase label should use an explicit Phase prefix for readability.")

    if not battle.hud.objective_label.text.begins_with("Objective: "):
        return _fail("BattleHUD objective label should use an explicit Objective prefix for readability.")

    if int(hud_layout.get("action_columns", 0)) != 2:
        return _fail("BattleHUD should use 2 action columns on narrow viewports.")

    if float(hud_layout.get("action_button_min_height", 0.0)) < 72.0:
        return _fail("BattleHUD compact action buttons should keep a 72px minimum height.")

    if String(hud_layout.get("inventory_body_orientation", "")) != "vertical":
        return _fail("BattleHUD inventory body should stack vertically on narrow viewports.")

    if absf(float(battle.hud.inventory_panel.offset_left) - 16.0) > 0.1 or absf(float(battle.hud.inventory_panel.offset_right) + 16.0) > 0.1 or absf(float(battle.hud.inventory_panel.offset_bottom) + 16.0) > 0.1:
        return _fail("BattleHUD compact inventory panel should preserve a 16px safe inset from screen edges.")

    if not main.campaign_panel.has_method("apply_layout_for_viewport_size"):
        return _fail("CampaignPanel is missing apply_layout_for_viewport_size() for mobile layout verification.")

    if not main.campaign_panel.has_method("get_layout_snapshot"):
        return _fail("CampaignPanel is missing get_layout_snapshot() for mobile layout verification.")

    main.campaign_panel.apply_layout_for_viewport_size(Vector2(430, 900))
    await process_frame

    var campaign_layout: Dictionary = main.campaign_panel.get_layout_snapshot()
    if not bool(campaign_layout.get("compact", false)):
        return _fail("CampaignPanel should enter compact layout on narrow viewports.")

    if int(campaign_layout.get("tab_columns", 0)) != 2:
        return _fail("CampaignPanel should use a 2-column tab layout on narrow viewports.")

    if float(campaign_layout.get("tab_button_min_height", 0.0)) < 56.0:
        return _fail("CampaignPanel compact tab buttons should keep a 56px minimum height.")

    if String(campaign_layout.get("party_content_orientation", "")) != "vertical":
        return _fail("CampaignPanel party content should stack vertically on narrow viewports.")

    if absf(float(main.campaign_panel.panel.offset_left) - 16.0) > 0.1 or absf(float(main.campaign_panel.panel.offset_right) + 16.0) > 0.1 or absf(float(main.campaign_panel.panel.offset_bottom) + 16.0) > 0.1:
        return _fail("CampaignPanel compact layout should preserve a 16px safe inset from screen edges.")

    battle.hud.apply_layout_for_viewport_size(Vector2(1152, 648))
    main.campaign_panel.apply_layout_for_viewport_size(Vector2(1152, 648))
    await process_frame
    return true

func _assert_battle_hud_inventory_and_input_block(battle) -> bool:
    if not battle.hud.has_method("open_inventory_panel"):
        return _fail("BattleHUD is missing open_inventory_panel().")

    if not battle.hud.has_method("is_menu_open"):
        return _fail("BattleHUD is missing is_menu_open().")

    if battle.selected_unit == null:
        return _fail("BattleHUD should auto-focus the first ready ally at battle start.")

    if battle.hud.wait_button.disabled:
        return _fail("BattleHUD wait button should start enabled once the first ready ally is auto-focused.")

    if battle.hud.wait_button.tooltip_text.strip_edges().is_empty():
        return _fail("BattleHUD disabled wait button should explain why the action is unavailable.")

    if battle.hud.cancel_button.tooltip_text.strip_edges().is_empty():
        return _fail("BattleHUD disabled cancel button should explain why the action is unavailable.")

    if battle.hud.transition_reason_label.text.find("|") != -1 or battle.hud.transition_reason_label.text.find("=") != -1:
        return _fail("BattleHUD transition reason should present readable text instead of raw debug payload formatting.")

    var inventory_button: Button = battle.hud.get_node_or_null("BottomPanel/Margin/Content/Actions/InventoryButton")
    if inventory_button == null:
        return _fail("BattleHUD is missing InventoryButton.")

    var ready_units: Array = _get_ready_ally_units(battle)
    if ready_units.is_empty():
        return _fail("No ready ally units found for HUD UI test.")

    var unit = ready_units[0]
    battle._on_world_cell_pressed(unit.grid_position)
    await process_frame

    if battle.selected_unit != unit:
        return _fail("Failed to select ally before testing inventory menu.")

    if battle.hud.detail_label.text.find("HP:") == -1 or battle.hud.detail_label.text.find("Move:") == -1 or battle.hud.detail_label.text.find("Range:") == -1:
        return _fail("BattleHUD selected-unit summary should use explicit stat labels for readability.")

    if battle.hud.transition_reason_label.text.find("|") != -1 or battle.hud.transition_reason_label.text.find("=") != -1:
        return _fail("BattleHUD selection transition reason should remain human-readable after unit selection.")

    battle.hud.open_inventory_panel()
    await process_frame

    if not battle.hud.is_menu_open():
        return _fail("Inventory menu did not open.")

    var overlay_scrim: ColorRect = battle.hud.get_node_or_null("OverlayScrim")
    if overlay_scrim == null:
        return _fail("BattleHUD is missing OverlayScrim for inventory modal readability.")

    if not overlay_scrim.visible:
        return _fail("BattleHUD overlay scrim should be visible while the inventory menu is open.")

    if battle.selected_unit != unit:
        return _fail("Opening inventory unexpectedly cleared the current selection.")

    var party_label: RichTextLabel = battle.hud.get_node_or_null("InventoryPanel/Margin/Content/Body/PartyColumn/PartyList")
    if party_label == null or party_label.text.find(unit.unit_data.display_name) == -1:
        return _fail("Inventory panel does not show party data.")

    var party_heading: Label = battle.hud.get_node_or_null("InventoryPanel/Margin/Content/Body/PartyColumn/PartyHeading")
    if party_heading == null or party_heading.text.find("(") == -1:
        return _fail("BattleHUD inventory heading should expose the party count for readability.")

    var inventory_heading: Label = battle.hud.get_node_or_null("InventoryPanel/Margin/Content/Body/InventoryColumn/InventoryHeading")
    if inventory_heading == null or inventory_heading.text.find("(") == -1:
        return _fail("BattleHUD inventory heading should expose the recovered supply count for readability.")

    if not battle.hud.inventory_objective_label.text.begins_with("Objective: "):
        return _fail("BattleHUD inventory panel should repeat the objective with an explicit Objective prefix.")

    var dismiss_hint_label: Label = battle.hud.get_node_or_null("InventoryPanel/Margin/Content/Footer/DismissHintLabel")
    if dismiss_hint_label == null or dismiss_hint_label.text.find("close") == -1:
        return _fail("BattleHUD inventory footer should teach the player how to close the modal.")

    if battle.hud.close_inventory_button.tooltip_text.find("close") == -1:
        return _fail("BattleHUD close button should explain the modal dismissal affordance.")

    if battle.input_controller.world_input_enabled:
        return _fail("InputController should disable world input while the inventory menu is open.")

    var blocking_rects: Array = battle.hud.get_input_blocking_rects()
    if blocking_rects.size() < 3:
        return _fail("BattleHUD should expose input blocking rects for top bar, bottom bar, and inventory menu.")

    if not battle.hud.has_method("dismiss_overlay_at_position"):
        return _fail("BattleHUD is missing dismiss_overlay_at_position() for outside-tap dismissal.")

    if not battle.hud.dismiss_overlay_at_position(Vector2(8, 120)):
        return _fail("BattleHUD should dismiss the inventory overlay on outside tap.")

    await process_frame
    if battle.hud.is_menu_open():
        return _fail("Inventory menu should close after outside-tap dismissal.")

    await process_frame
    return true

func _assert_hud_state_after_move(battle) -> void:
    if battle.hud.wait_button.disabled:
        _fail("Wait button should remain enabled after moving.")
        return

    if battle.hud.cancel_button.disabled:
        _fail("Cancel button should remain enabled after moving.")
        return

func _assert_battle_result_surface(battle) -> bool:
    if not battle.hud.has_method("get_result_snapshot"):
        return _fail("BattleHUD is missing get_result_snapshot() for result readability verification.")

    battle.hud.show_result("Victory\nObjective: Demo objective\nMemory:\n- Demo entry")
    var result_snapshot: Dictionary = battle.hud.get_result_snapshot()
    if String(result_snapshot.get("title", "")) != "Victory":
        return _fail("BattleHUD result surface should promote the first line into the dialog title.")
    if String(result_snapshot.get("body", "")).find("Objective: Demo objective") == -1:
        return _fail("BattleHUD result body should keep the structured objective copy.")
    if String(result_snapshot.get("body", "")).find("Memory:") == -1:
        return _fail("BattleHUD result body should preserve section headings for readability.")
    if not bool(result_snapshot.get("visible", false)):
        return _fail("BattleHUD result popup should be visible after show_result().")
    battle.hud.result_popup.hide()
    return true

func _assert_structured_result_and_feedback_surfaces(battle) -> bool:
    battle.hud.set_selection_summary("Rian", "12/12", 4, 1, 6, 2, 1, "Plain", 2)
    var layout_snapshot: Dictionary = battle.hud.get_layout_snapshot()
    if not bool(layout_snapshot.get("oblivion_badge_visible", false)):
        return _fail("BattleHUD layout snapshot should expose the oblivion badge visibility when a unit has stacks.")

    battle.hud.set_transition_reason("support_attack_resolved", {"bond": 3, "count": 1})
    if battle.hud.transition_reason_label.text.find("Bond 3") == -1:
        return _fail("BattleHUD support feedback should expose the supporting bond level in readable text.")
    if battle.hud.telegraph_label.text != "Support Attack":
        return _fail("BattleHUD telegraph label should promote support attacks with explicit wording.")
    if battle.hud.telegraph_detail_label.text.find("bond 3+") == -1:
        return _fail("BattleHUD support telegraph detail should explain the bond trigger clearly.")

    battle.hud.show_result_screen({
        "title": "Victory",
        "objective": "Hold the archive line.",
        "reward_entries": ["Archive proof relay"],
        "memory_entries": ["Recovered order fragment"],
        "recovered_fragment_ids": ["ch05_fragment"],
        "unlocked_command_ids": ["tactical_shift"],
        "unit_exp_results": [
            {"display_name": "Rian", "level_before": 1, "exp_before": 0, "exp_gain": 10, "level_after": 2, "exp_after": 0, "leveled_up": true}
        ],
        "support_attack_count": 1,
        "supporter_bond_level": 3,
        "burden_delta": 1,
        "trust_delta": 1
    })
    var result_screen = battle.hud.result_screen
    if result_screen == null:
        return _fail("BattleHUD should instantiate a structured BattleResultScreen.")
    var structured_snapshot: Dictionary = result_screen.get_result_snapshot()
    if not bool(structured_snapshot.get("visible", false)):
        return _fail("BattleResultScreen should become visible when show_result_screen() is called.")

    var body_label: RichTextLabel = result_screen.get_node_or_null("Panel/Margin/Content/BodyLabel")
    if body_label == null:
        return _fail("BattleResultScreen body label could not be resolved for UI verification.")
    var result_body := String(body_label.text)
    if result_body.find("Support Attacks") == -1 or result_body.find("Support Bond") == -1:
        return _fail("BattleResultScreen should surface both support attack count and support bond emphasis.")
    if result_body.find("기억 복원") == -1:
        return _fail("BattleResultScreen should preserve memory-restoration emphasis in the structured result body.")
    if result_body.find("Unit EXP") == -1 or result_body.find("Rian") == -1 or result_body.find("Lv 1 -> 2") == -1:
        return _fail("BattleResultScreen should surface per-unit EXP gain and level-up lines.")

    result_screen.hide_result()
    return true

func _assert_campaign_save_entry(main) -> bool:
    var save_button: Button = main.campaign_panel.get_node_or_null("Panel/Margin/Content/FooterRow/SaveButton")
    if save_button == null:
        return _fail("CampaignPanel is missing SaveButton for camp save flow.")
    if not save_button.visible or save_button.disabled:
        return _fail("CampaignPanel save entry should be visible and enabled in camp mode.")
    save_button.pressed.emit()
    if main.save_load_panel == null or not main.save_load_panel.visible:
        return _fail("Camp save entry should open the shared SaveLoadPanel.")
    var panel_snapshot: Dictionary = main.save_load_panel.get_layout_snapshot()
    if String(panel_snapshot.get("mode", "")) != "save":
        return _fail("Camp save entry should open SaveLoadPanel in save mode.")
    main.save_load_panel.close()
    return true

func _assert_result_to_record_handoff(main) -> bool:
    var result_summary: Dictionary = main.battle_controller.get_last_result_summary()
    var panel_snapshot: Dictionary = main.campaign_panel.get_snapshot()
    for key: String in ["memory_entries", "evidence_entries", "letter_entries"]:
        var result_entries: Array = result_summary.get(key, [])
        var panel_entries: Array = panel_snapshot.get(key, [])
        if result_entries != panel_entries:
            return _fail("Battle result and camp panel should expose the same %s after handoff." % key)
    return true

func _advance_campaign_to_camp(main) -> bool:
    var safety: int = 0
    while safety < 12:
        if _failed:
            return false
        var snapshot: Dictionary = main.get_campaign_state_snapshot()
        var mode: String = String(snapshot.get("mode", ""))
        if mode == "camp":
            return true

        if mode == "cutscene":
            main.advance_campaign_step()
            await process_frame
            await process_frame
        elif mode == "battle":
            var battle = main.battle_controller
            await _play_battle_to_victory(battle)
            if _failed:
                return false
            await process_frame
            await process_frame
        else:
            return _fail("Unexpected campaign mode while advancing UI test: %s" % mode)
        safety += 1

    return _fail("UI runner did not reach camp mode in time.")

func _assert_campaign_panel_snapshot(campaign_panel) -> bool:
    var snapshot: Dictionary = campaign_panel.get_snapshot()
    if not snapshot.has("recommendation"):
        return _fail("CampaignPanel snapshot is missing recommendation. Keys: %s" % [snapshot.keys()])

    if not snapshot.has("flow_text"):
        return _fail("CampaignPanel snapshot is missing flow_text. Keys: %s" % [snapshot.keys()])

    if not snapshot.has("section_hint"):
        return _fail("CampaignPanel snapshot is missing section_hint. Keys: %s" % [snapshot.keys()])

    if not snapshot.has("party_entries"):
        return _fail("CampaignPanel snapshot is missing party_entries. Keys: %s" % [snapshot.keys()])

    if not snapshot.has("inventory_entries"):
        return _fail("CampaignPanel snapshot is missing inventory_entries. Keys: %s" % [snapshot.keys()])

    if not snapshot.has("party_details"):
        return _fail("CampaignPanel snapshot is missing party_details. Keys: %s" % [snapshot.keys()])

    if not snapshot.has("selected_party_name"):
        return _fail("CampaignPanel snapshot is missing selected_party_name. Keys: %s" % [snapshot.keys()])

    if not snapshot.has("memory_entries"):
        return _fail("CampaignPanel snapshot is missing memory_entries. Keys: %s" % [snapshot.keys()])

    if not snapshot.has("evidence_entries"):
        return _fail("CampaignPanel snapshot is missing evidence_entries. Keys: %s" % [snapshot.keys()])

    if not snapshot.has("letter_entries"):
        return _fail("CampaignPanel snapshot is missing letter_entries. Keys: %s" % [snapshot.keys()])

    if not snapshot.has("section_badges"):
        return _fail("CampaignPanel snapshot is missing section_badges. Keys: %s" % [snapshot.keys()])

    if not snapshot.has("dialogue_entries"):
        return _fail("CampaignPanel snapshot is missing dialogue_entries. Keys: %s" % [snapshot.keys()])

    if not snapshot.has("presentation_cards"):
        return _fail("CampaignPanel snapshot is missing presentation_cards. Keys: %s" % [snapshot.keys()])

    var recommendation: String = String(snapshot.get("recommendation", ""))
    if recommendation.is_empty():
        return _fail("CampaignPanel recommendation was empty in camp mode.")

    var body_text: String = String(snapshot.get("body", ""))
    if body_text.find("Burden / Trust:") == -1:
        return _fail("CampaignPanel camp body should surface the current Burden / Trust bands.")
    if body_text.find("Recovered fragments:") == -1:
        return _fail("CampaignPanel camp body should expose recovered fragment count.")
    if body_text.find("Unlocked commands:") == -1:
        return _fail("CampaignPanel camp body should expose unlocked command count.")

    var flow_text: String = String(snapshot.get("flow_text", ""))
    if flow_text.is_empty():
        return _fail("CampaignPanel flow_text was empty in camp mode.")

    if flow_text.find("Camp review") == -1:
        return _fail("CampaignPanel flow_text should explain the battle-to-camp handoff, got %s." % [flow_text])

    var section_hint: String = String(snapshot.get("section_hint", ""))
    if section_hint.is_empty():
        return _fail("CampaignPanel section_hint was empty in camp mode.")

    var party_entries: Array = snapshot.get("party_entries", [])
    if party_entries.is_empty():
        return _fail("CampaignPanel party_entries should not be empty in camp mode.")

    var party_details: Array = snapshot.get("party_details", [])
    if party_details.is_empty():
        return _fail("CampaignPanel party_details should not be empty in camp mode.")

    var selected_party_name: String = String(snapshot.get("selected_party_name", ""))
    if selected_party_name.is_empty():
        return _fail("CampaignPanel selected_party_name should not be empty in camp mode.")

    var memory_entries: Array = snapshot.get("memory_entries", [])
    if memory_entries.is_empty():
        return _fail("CampaignPanel memory_entries should not be empty in camp mode.")

    var evidence_entries: Array = snapshot.get("evidence_entries", [])
    if evidence_entries.is_empty():
        return _fail("CampaignPanel evidence_entries should not be empty in camp mode.")

    var letter_entries: Array = snapshot.get("letter_entries", [])
    if letter_entries.is_empty():
        return _fail("CampaignPanel letter_entries should not be empty in camp mode.")

    var dialogue_entries: Array = snapshot.get("dialogue_entries", [])
    if dialogue_entries.is_empty():
        return _fail("CampaignPanel dialogue_entries should not be empty in camp mode.")

    if str(dialogue_entries[0]).find("Empire") == -1:
        return _fail("CampaignPanel dialogue_entries should expose the CH01 interlude dialogue.")

    var presentation_cards: Array = snapshot.get("presentation_cards", [])
    if presentation_cards.is_empty():
        return _fail("CampaignPanel presentation_cards should not be empty in camp mode.")

    if str(presentation_cards[0].get("title", "")).find("Serin") == -1:
        return _fail("CampaignPanel presentation_cards should expose the CH01 ally handoff.")

    var section_badges: Dictionary = snapshot.get("section_badges", {})
    if String(section_badges.get("records", "")).is_empty():
        return _fail("CampaignPanel records badge should not be empty in camp mode.")

    if String(section_badges.get("inventory", "")).is_empty():
        return _fail("CampaignPanel inventory badge should not be empty in camp mode.")

    if String(section_badges.get("party", "")).is_empty():
        return _fail("CampaignPanel party badge should not be empty in camp mode.")

    var alerts: Array = snapshot.get("alerts", [])
    var joined_alerts := "\n".join(alerts)
    if joined_alerts.find("Burden") == -1 or joined_alerts.find("Fragments") == -1:
        return _fail("CampaignPanel alerts should surface burden/trust and fragment/command progression summary.")

    var records_button: Button = campaign_panel.get_node_or_null("Panel/Margin/Content/SectionTabs/RecordsButton")
    if records_button == null or records_button.text.find("NEW") == -1:
        return _fail("CampaignPanel records button should surface a NEW badge.")

    var summary_button: Button = campaign_panel.get_node_or_null("Panel/Margin/Content/SectionTabs/SummaryButton")
    if summary_button == null or summary_button.tooltip_text.find("Start here") == -1:
        return _fail("CampaignPanel summary tab should explain its purpose for readability.")

    var flow_label: Label = campaign_panel.get_node_or_null("Panel/Margin/Content/Header/FlowLabel")
    if flow_label == null or flow_label.text.find("Camp review") == -1:
        return _fail("CampaignPanel FlowLabel should expose the loop handoff state.")

    var presentation_heading: Label = campaign_panel.get_node_or_null("Panel/Margin/Content/BodyStack/SummarySection/PresentationHeading")
    if presentation_heading == null or presentation_heading.text.find("Camp") == -1:
        return _fail("CampaignPanel presentation heading should expose the camp handoff framing.")

    var presentation_cards_container: VBoxContainer = campaign_panel.get_node_or_null("Panel/Margin/Content/BodyStack/SummarySection/PresentationCards")
    if presentation_cards_container == null or presentation_cards_container.get_child_count() < 1:
        return _fail("CampaignPanel should render at least one presentation card in summary mode.")

    var party_overview_label: Label = campaign_panel.get_node_or_null("Panel/Margin/Content/OverviewStrip/PartyOverviewCard/Padding/Stack/Value")
    if party_overview_label == null or party_overview_label.text.find("ready") == -1:
        return _fail("CampaignPanel party overview card should summarize readiness.")

    var inventory_overview_label: Label = campaign_panel.get_node_or_null("Panel/Margin/Content/OverviewStrip/InventoryOverviewCard/Padding/Stack/Value")
    if inventory_overview_label == null or inventory_overview_label.text.find("updates") == -1:
        return _fail("CampaignPanel inventory overview card should summarize loot changes.")

    var records_overview_label: Label = campaign_panel.get_node_or_null("Panel/Margin/Content/OverviewStrip/RecordsOverviewCard/Padding/Stack/Value")
    if records_overview_label == null or records_overview_label.text.find("new") == -1:
        return _fail("CampaignPanel records overview card should summarize new story records.")

    var party_heading: Label = campaign_panel.get_node_or_null("Panel/Margin/Content/BodyStack/PartySection/PartyHeading")
    if party_heading == null or party_heading.text.find("(") == -1:
        return _fail("CampaignPanel party heading should expose the roster count for quick scanning.")

    var inventory_heading: Label = campaign_panel.get_node_or_null("Panel/Margin/Content/BodyStack/InventorySection/InventoryHeading")
    if inventory_heading == null or inventory_heading.text.find("(") == -1:
        return _fail("CampaignPanel inventory heading should expose the inventory count for quick scanning.")

    var memory_heading: Label = campaign_panel.get_node_or_null("Panel/Margin/Content/BodyStack/RecordsSection/RecordsStack/MemoryHeading")
    if memory_heading == null or memory_heading.text.find("(") == -1:
        return _fail("CampaignPanel memory heading should expose the unlocked memory count.")

    var evidence_heading: Label = campaign_panel.get_node_or_null("Panel/Margin/Content/BodyStack/RecordsSection/RecordsStack/EvidenceHeading")
    if evidence_heading == null or evidence_heading.text.find("(") == -1:
        return _fail("CampaignPanel evidence heading should expose the unlocked evidence count.")

    var letter_heading: Label = campaign_panel.get_node_or_null("Panel/Margin/Content/BodyStack/RecordsSection/RecordsStack/LetterHeading")
    if letter_heading == null or letter_heading.text.find("(") == -1:
        return _fail("CampaignPanel letter heading should expose the unlocked letter count.")

    var advance_button: Button = campaign_panel.get_node_or_null("Panel/Margin/Content/FooterRow/AdvanceButton")
    if advance_button == null:
        return _fail("CampaignPanel is missing AdvanceButton.")

    if advance_button.text != "Next Battle":
        return _fail("CampaignPanel camp CTA should read Next Battle, got %s." % [advance_button.text])

    campaign_panel.apply_layout_for_viewport_size(Vector2(430, 900))
    var roster_scroll = campaign_panel.get_node_or_null("Panel/Margin/Content/BodyStack/PartySection/PartyContent/RosterColumn/RosterScroll")
    if roster_scroll == null:
        return _fail("CampaignPanel should wrap the party roster in a scroll container for mobile overflow safety.")

    if float(advance_button.custom_minimum_size.y) < 64.0:
        return _fail("CampaignPanel primary CTA should keep a 64px minimum height.")

    var assignment_button: Button = campaign_panel.get_node_or_null("Panel/Margin/Content/BodyStack/PartySection/PartyContent/DetailCard/Margin/DetailStack/AssignmentButton")
    if assignment_button == null:
        return _fail("CampaignPanel is missing AssignmentButton.")

    if float(assignment_button.custom_minimum_size.y) < 56.0:
        return _fail("CampaignPanel primary camp actions should keep a 56px minimum height in mobile layout.")

    if assignment_button.disabled and assignment_button.tooltip_text.strip_edges().is_empty():
        return _fail("CampaignPanel disabled assignment button should explain why sortie assignment is unavailable.")

    var weapon_card: PanelContainer = campaign_panel.get_node_or_null("Panel/Margin/Content/BodyStack/PartySection/PartyContent/DetailCard/Margin/DetailStack/SlotCards/WeaponCard")
    if weapon_card == null:
        return _fail("CampaignPanel should render an explicit weapon slot card.")

    var weapon_item_label: Label = campaign_panel.get_node_or_null("Panel/Margin/Content/BodyStack/PartySection/PartyContent/DetailCard/Margin/DetailStack/SlotCards/WeaponCard/Margin/Stack/ItemLabel")
    if weapon_item_label == null or weapon_item_label.text.strip_edges().is_empty():
        return _fail("CampaignPanel weapon slot card should show the current weapon name.")

    var weapon_preview: TextureRect = campaign_panel.get_node_or_null("Panel/Margin/Content/BodyStack/PartySection/PartyContent/DetailCard/Margin/DetailStack/SlotCards/WeaponCard/Margin/Stack/Preview")
    if weapon_preview == null or weapon_preview.texture == null:
        return _fail("CampaignPanel weapon slot card should render a runtime preview texture.")

    var weapon_hint_label: Label = campaign_panel.get_node_or_null("Panel/Margin/Content/BodyStack/PartySection/PartyContent/DetailCard/Margin/DetailStack/SlotCards/WeaponCard/Margin/Stack/HintLabel")
    if weapon_hint_label == null or weapon_hint_label.text.strip_edges().is_empty():
        return _fail("CampaignPanel weapon slot card should explain weapon availability.")
    if weapon_hint_label.text.find("Allowed:") == -1 or weapon_hint_label.text.find("Eligible:") == -1:
        return _fail("CampaignPanel weapon slot card should expose allowed types and eligible count.")

    var armor_card: PanelContainer = campaign_panel.get_node_or_null("Panel/Margin/Content/BodyStack/PartySection/PartyContent/DetailCard/Margin/DetailStack/SlotCards/ArmorCard")
    if armor_card == null:
        return _fail("CampaignPanel should render an explicit armor slot card.")

    var armor_item_label: Label = campaign_panel.get_node_or_null("Panel/Margin/Content/BodyStack/PartySection/PartyContent/DetailCard/Margin/DetailStack/SlotCards/ArmorCard/Margin/Stack/ItemLabel")
    if armor_item_label == null or armor_item_label.text.strip_edges().is_empty():
        return _fail("CampaignPanel armor slot card should show the current armor name.")

    var armor_preview: TextureRect = campaign_panel.get_node_or_null("Panel/Margin/Content/BodyStack/PartySection/PartyContent/DetailCard/Margin/DetailStack/SlotCards/ArmorCard/Margin/Stack/Preview")
    if armor_preview == null or armor_preview.texture == null:
        return _fail("CampaignPanel armor slot card should render a runtime preview texture.")

    var armor_hint_label: Label = campaign_panel.get_node_or_null("Panel/Margin/Content/BodyStack/PartySection/PartyContent/DetailCard/Margin/DetailStack/SlotCards/ArmorCard/Margin/Stack/HintLabel")
    if armor_hint_label == null or armor_hint_label.text.find("Allowed:") == -1 or armor_hint_label.text.find("Eligible:") == -1:
        return _fail("CampaignPanel armor slot card should expose allowed types and eligible count.")

    var accessory_card: PanelContainer = campaign_panel.get_node_or_null("Panel/Margin/Content/BodyStack/PartySection/PartyContent/DetailCard/Margin/DetailStack/SlotCards/AccessoryCard")
    if accessory_card == null:
        return _fail("CampaignPanel should render an explicit accessory slot card.")

    var accessory_item_label: Label = campaign_panel.get_node_or_null("Panel/Margin/Content/BodyStack/PartySection/PartyContent/DetailCard/Margin/DetailStack/SlotCards/AccessoryCard/Margin/Stack/ItemLabel")
    if accessory_item_label == null or accessory_item_label.text.strip_edges().is_empty():
        return _fail("CampaignPanel accessory slot card should show the current accessory state.")

    var accessory_preview: TextureRect = campaign_panel.get_node_or_null("Panel/Margin/Content/BodyStack/PartySection/PartyContent/DetailCard/Margin/DetailStack/SlotCards/AccessoryCard/Margin/Stack/Preview")
    if accessory_preview == null or accessory_preview.texture == null:
        return _fail("CampaignPanel accessory slot card should render a runtime preview texture.")

    var accessory_hint_label: Label = campaign_panel.get_node_or_null("Panel/Margin/Content/BodyStack/PartySection/PartyContent/DetailCard/Margin/DetailStack/SlotCards/AccessoryCard/Margin/Stack/HintLabel")
    if accessory_hint_label == null or accessory_hint_label.text.find("All recruits may equip accessories.") == -1:
        return _fail("CampaignPanel accessory slot card should explain unrestricted accessory eligibility.")

    var weapon_button: Button = campaign_panel.get_node_or_null("Panel/Margin/Content/BodyStack/PartySection/PartyContent/DetailCard/Margin/DetailStack/SlotCards/WeaponCard/Margin/Stack/WeaponButton")
    if weapon_button == null:
        return _fail("CampaignPanel is missing WeaponButton.")

    if weapon_button.disabled and weapon_button.tooltip_text.strip_edges().is_empty():
        return _fail("CampaignPanel disabled weapon button should explain why no loadout action is available.")

    if campaign_panel.party_roster_buttons.get_child_count() > 0:
        var first_roster_button: Node = campaign_panel.party_roster_buttons.get_child(0)
        if first_roster_button is Button and float(first_roster_button.custom_minimum_size.y) < 56.0:
            return _fail("CampaignPanel roster buttons should keep a 56px minimum height in mobile layout.")

    campaign_panel._select_section(campaign_panel.SECTION_PARTY)
    var back_event := InputEventAction.new()
    back_event.action = "ui_cancel"
    back_event.pressed = true
    campaign_panel._unhandled_input(back_event)
    if String(campaign_panel.get_snapshot().get("active_section", "")) != campaign_panel.SECTION_SUMMARY:
        return _fail("CampaignPanel should return to Summary when back/cancel is pressed from a deeper tab.")

    campaign_panel._select_section(campaign_panel.SECTION_SUMMARY)
    var right_event := InputEventAction.new()
    right_event.action = "ui_right"
    right_event.pressed = true
    campaign_panel._unhandled_input(right_event)
    if String(campaign_panel.get_snapshot().get("active_section", "")) != campaign_panel.SECTION_PARTY:
        return _fail("CampaignPanel should support right-navigation across tabs.")

    var left_event := InputEventAction.new()
    left_event.action = "ui_left"
    left_event.pressed = true
    campaign_panel._unhandled_input(left_event)
    if String(campaign_panel.get_snapshot().get("active_section", "")) != campaign_panel.SECTION_SUMMARY:
        return _fail("CampaignPanel should support left-navigation back toward Summary.")

    campaign_panel.apply_layout_for_viewport_size(Vector2(1152, 648))

    if party_details.size() > 1:
        campaign_panel.select_party_index(1)
        var updated_snapshot: Dictionary = campaign_panel.get_snapshot()
        if String(updated_snapshot.get("selected_party_name", "")) == selected_party_name:
            return _fail("CampaignPanel party selection did not update the selected_party_name.")
    return true

func _assert_campaign_panel_selection_persistence(main) -> bool:
    var campaign_panel = main.campaign_panel
    var controller = main.campaign_controller
    var snapshot: Dictionary = campaign_panel.get_snapshot()
    var party_details: Array = snapshot.get("party_details", [])
    if party_details.size() < 2:
        return _fail("CampaignPanel needs at least two party entries to verify selection persistence.")

    campaign_panel._select_section(campaign_panel.SECTION_PARTY)
    campaign_panel.select_party_index(1)
    await process_frame

    var selected_snapshot: Dictionary = campaign_panel.get_snapshot()
    var selected_unit_id := String(selected_snapshot.get("selected_party_unit_id", ""))
    if selected_unit_id.is_empty():
        return _fail("CampaignPanel should expose the selected party unit id before refresh.")

    if controller._unlocked_accessory_ids.is_empty():
        controller._unlocked_accessory_ids.append(&"acc_militia_emblem")

    controller.cycle_accessory_for_unit(StringName(selected_unit_id))
    await process_frame

    var refreshed_snapshot: Dictionary = campaign_panel.get_snapshot()
    if String(refreshed_snapshot.get("active_section", "")) != campaign_panel.SECTION_PARTY:
        return _fail("CampaignPanel should stay on the Party tab after a controller-driven loadout refresh.")

    if String(refreshed_snapshot.get("selected_party_unit_id", "")) != selected_unit_id:
        return _fail("CampaignPanel should preserve the selected party member after a controller-driven loadout refresh.")

    return true

func _play_battle_to_victory(battle) -> void:
    var max_round_loops: int = 20
    for _round_loop in range(max_round_loops):
        if _failed:
            return
        await _wait_for_player_phase(battle)
        if _is_battle_finished(battle):
            break

        await _play_player_phase(battle)
        await process_frame
        await process_frame

        if _is_battle_finished(battle):
            break

func _wait_for_player_phase(battle) -> void:
    var safety: int = 0
    while not _is_battle_finished(battle):
        if _failed:
            return
        var phase: int = int(battle.current_phase)
        if phase == int(battle.BattlePhase.PLAYER_SELECT) or phase == int(battle.BattlePhase.PLAYER_ACTION_PREVIEW):
            return
        await process_frame
        safety += 1
        if safety > 180:
            _fail("Timed out waiting for player phase in UI runner.")
            return

func _play_player_phase(battle) -> void:
    while true:
        if _failed:
            return
        if _is_battle_finished(battle):
            return

        var ready_units: Array = _get_ready_ally_units(battle)
        if ready_units.is_empty():
            battle._on_end_turn_requested()
            await process_frame
            return

        var unit = ready_units[0]
        battle._on_world_cell_pressed(unit.grid_position)
        await process_frame

        var acted: bool = await _take_action_for_unit(battle, unit)
        if acted:
            return

        _fail("UI runner could not find a valid player action.")
        return

func _take_action_for_unit(battle, unit) -> bool:
    var interaction_destination: Vector2i = _pick_interaction_destination(battle, unit)
    if interaction_destination != Vector2i(-1, -1):
        if interaction_destination != unit.grid_position:
            battle._on_world_cell_pressed(interaction_destination)
            await process_frame

        var interactable = _find_interactable_object_for_selected_unit(battle)
        if interactable != null:
            battle._on_world_cell_pressed(interactable.grid_position)
            await process_frame
            return true

    var opponents: Array = battle.enemy_units
    var dynamic_blocked: Dictionary = battle._get_dynamic_blocked_cells(unit)
    var plan: Dictionary = battle.ai_service.pick_action(unit, opponents, battle.path_service, battle.range_service, dynamic_blocked)
    var action_type: String = String(plan.get("type", "wait"))

    if action_type == "attack":
        var immediate_target = plan.get("target", null)
        if immediate_target != null:
            battle._on_world_cell_pressed(immediate_target.grid_position)
            await process_frame
            return true

    if action_type == "move_attack":
        var move_to: Vector2i = plan.get("move_to", unit.grid_position)
        if move_to != unit.grid_position:
            battle._on_world_cell_pressed(move_to)
            await process_frame

        var target = plan.get("target", null)
        if target != null:
            battle._on_world_cell_pressed(target.grid_position)
            await process_frame
            return true

    if action_type == "move_wait":
        var wait_destination: Vector2i = plan.get("move_to", unit.grid_position)
        if wait_destination != unit.grid_position:
            battle._on_world_cell_pressed(wait_destination)
            await process_frame

        battle._on_wait_requested()
        await process_frame
        return true

    battle._on_wait_requested()
    await process_frame
    return true

func _get_ready_ally_units(battle) -> Array:
    var ready_units: Array = []
    for unit in battle.ally_units:
        if is_instance_valid(unit) and not unit.is_defeated() and battle.turn_manager.can_unit_act(unit):
            ready_units.append(unit)
    return ready_units

func _is_battle_finished(battle) -> bool:
    var phase: int = int(battle.current_phase)
    return phase == int(battle.BattlePhase.VICTORY) or phase == int(battle.BattlePhase.DEFEAT)

func _pick_interaction_destination(battle, unit) -> Vector2i:
    var win_condition: String = String(battle.stage_data.win_condition)
    if win_condition != "resolve_all_interactions" and win_condition != "resolve_all_interactions_and_defeat_all_enemies":
        return Vector2i(-1, -1)

    var best_destination := Vector2i(-1, -1)
    var best_cost: int = 2147483647
    var dynamic_blocked: Dictionary = battle._get_dynamic_blocked_cells(unit)

    for object_actor in battle.interactive_objects:
        if object_actor == null or not is_instance_valid(object_actor) or object_actor.is_resolved:
            continue

        if object_actor.can_interact(unit):
            return unit.grid_position

        var candidate_cells: Array = battle.range_service.get_attack_cells(object_actor.grid_position, object_actor.object_data.interaction_range)
        for cell in candidate_cells:
            if not battle.path_service.is_walkable(cell, dynamic_blocked):
                continue

            var path: Array = battle.path_service.find_path(unit.grid_position, cell, dynamic_blocked)
            if path.is_empty():
                continue

            var path_cost: int = battle.path_service.get_path_cost(path)
            if path_cost < best_cost:
                best_cost = path_cost
                best_destination = battle.ai_service._truncate_path_to_movement(path, unit.get_movement(), battle.path_service)

    return best_destination

func _find_interactable_object_for_selected_unit(battle):
    for object_actor in battle.interactive_objects:
        if object_actor == null or not is_instance_valid(object_actor) or object_actor.is_resolved:
            continue
        if battle._can_selected_unit_interact(object_actor):
            return object_actor
    return null

func _fail(message: String) -> bool:
    if _failed:
        return false
    _failed = true
    push_error(message)
    quit(1)
    return false
