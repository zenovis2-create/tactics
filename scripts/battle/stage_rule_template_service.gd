class_name StageRuleTemplateService
extends RefCounted

static func get_objective_override(stage_data, battle_objective_flags: Dictionary) -> String:
    var modifiers: Dictionary = _get_modifiers(stage_data)
    if modifiers.is_empty():
        return ""
    var final_flag: String = String(modifiers.get("final_pressure_flag", "")).strip_edges()
    if not final_flag.is_empty() and bool(battle_objective_flags.get(final_flag, false)):
        return String(modifiers.get("objective_after_final_pressure", "")).strip_edges()
    var relief_flag: String = String(modifiers.get("relief_flag", "")).strip_edges()
    if not relief_flag.is_empty() and bool(battle_objective_flags.get(relief_flag, false)):
        return String(modifiers.get("objective_after_relief", "")).strip_edges()
    return ""

static func get_objective_hint_override(stage_data, battle_objective_flags: Dictionary) -> String:
    var modifiers: Dictionary = _get_modifiers(stage_data)
    if modifiers.is_empty():
        return ""
    var final_flag: String = String(modifiers.get("final_pressure_flag", "")).strip_edges()
    if not final_flag.is_empty() and bool(battle_objective_flags.get(final_flag, false)):
        return String(modifiers.get("hint_after_final_pressure", "")).strip_edges()
    var relief_flag: String = String(modifiers.get("relief_flag", "")).strip_edges()
    if not relief_flag.is_empty() and bool(battle_objective_flags.get(relief_flag, false)):
        return String(modifiers.get("hint_after_relief", "")).strip_edges()
    return ""

static func get_relief_objective_state_id(stage_data, battle_objective_flags: Dictionary) -> StringName:
    var modifiers: Dictionary = _get_modifiers(stage_data)
    if modifiers.is_empty():
        return &""
    var relief_flag: String = String(modifiers.get("relief_flag", "")).strip_edges()
    if relief_flag.is_empty() or not bool(battle_objective_flags.get(relief_flag, false)):
        return &""
    return StringName(modifiers.get("relief_state_id", &""))

static func apply_interaction_rule(battle, object_id: String) -> bool:
    if battle == null or battle.stage_data == null:
        return false
    var template_id: StringName = battle.stage_data.rule_template_id
    var modifiers: Dictionary = _get_modifiers(battle.stage_data)
    match template_id:
        &"lete_route_cut":
            return _apply_lete_route_cut(battle, object_id, modifiers)
        &"melkion_archive_relief":
            return _apply_melkion_archive_relief(battle, object_id, modifiers)
        &"karon_bell_pressure":
            return _apply_karon_bell_pressure(battle, object_id, modifiers)
        _:
            return false

static func _apply_lete_route_cut(battle, object_id: String, modifiers: Dictionary) -> bool:
    var latch_id: String = String(modifiers.get("control_object_id", "")).strip_edges()
    if object_id != latch_id:
        return false
    battle.battle_objective_flags[latch_id] = true
    var relief_flag: String = String(modifiers.get("relief_flag", "")).strip_edges()
    if not relief_flag.is_empty():
        battle.battle_objective_flags[relief_flag] = true
    var extra_flag: String = String(modifiers.get("relief_tracking_flag", "")).strip_edges()
    if not extra_flag.is_empty():
        battle.battle_objective_flags[extra_flag] = true
    _erase_blocked_cells(battle, modifiers.get("open_cells", []))
    var boss = battle._find_boss_enemy()
    if boss != null:
        battle.enemy_movement_bonus_by_unit.erase(boss.get_instance_id())
        _set_enemy_cooldowns(battle, boss, modifiers.get("boss_cooldowns", {}))
    _clear_ally_statuses(battle, modifiers.get("clear_statuses", []))
    _queue_board_redraw(battle)
    return true

static func _apply_melkion_archive_relief(battle, object_id: String, modifiers: Dictionary) -> bool:
    var lectern_id: String = String(modifiers.get("control_object_id", "")).strip_edges()
    if object_id != lectern_id:
        return false
    battle.battle_objective_flags[lectern_id] = true
    var relief_flag: String = String(modifiers.get("relief_flag", "")).strip_edges()
    if not relief_flag.is_empty():
        battle.battle_objective_flags[relief_flag] = true
    var destabilized_flag: String = String(modifiers.get("relief_tracking_flag", "")).strip_edges()
    if not destabilized_flag.is_empty():
        battle.battle_objective_flags[destabilized_flag] = true
    var boss = battle._find_boss_enemy()
    if boss != null:
        _set_enemy_cooldowns(battle, boss, modifiers.get("boss_cooldowns", {}))
    var clear_terrain_cells: Array = modifiers.get("clear_terrain_cells", [])
    for cell_variant in clear_terrain_cells:
        var cell: Vector2i = cell_variant
        battle.stage_data.terrain_types[cell] = &"plain"
        battle.stage_data.terrain_move_costs.erase(cell)
        battle.stage_data.terrain_defense_bonuses.erase(cell)
    _clear_ally_statuses(battle, modifiers.get("clear_statuses", []))
    _erase_unit_runtime_entries(battle.ignored_terrain_turns_by_unit, battle.ally_units)
    _queue_board_redraw(battle)
    return true

static func _apply_karon_bell_pressure(battle, object_id: String, modifiers: Dictionary) -> bool:
    var bell_dais_id: String = String(modifiers.get("bell_dais_object_id", "")).strip_edges()
    var anchor_chain_id: String = String(modifiers.get("control_object_id", "")).strip_edges()
    if object_id == bell_dais_id:
        battle.battle_objective_flags["final_bell_dais_held"] = true
        return true
    if object_id != anchor_chain_id:
        return false
    battle.battle_objective_flags[anchor_chain_id] = true
    var relief_flag: String = String(modifiers.get("relief_flag", "")).strip_edges()
    if not relief_flag.is_empty():
        battle.battle_objective_flags[relief_flag] = true
    battle.battle_objective_flags["karon_cut_off"] = bool(battle.battle_objective_flags.get("final_bell_dais_held", false))
    _erase_blocked_cells(battle, modifiers.get("open_cells", []))
    var boss = battle._find_boss_enemy()
    if boss != null:
        _set_enemy_cooldowns(battle, boss, modifiers.get("boss_cooldowns", {}))
    _clear_ally_statuses(battle, modifiers.get("clear_statuses", []))
    _erase_unit_runtime_entries(battle.bond_suppression_turns_by_unit, battle.ally_units)
    _queue_board_redraw(battle)
    return true

static func _get_modifiers(stage_data) -> Dictionary:
    if stage_data == null:
        return {}
    return Dictionary(stage_data.rule_template_modifiers)

static func _erase_blocked_cells(battle, cells_variant: Variant) -> void:
    for cell_variant in Array(cells_variant):
        var cell: Vector2i = cell_variant
        battle.stage_data.blocked_cells.erase(cell)

static func _set_enemy_cooldowns(battle, boss, cooldowns_variant: Variant) -> void:
    var cooldowns: Dictionary = Dictionary(cooldowns_variant)
    for skill_id_variant in cooldowns.keys():
        battle._set_enemy_skill_cooldown(boss, StringName(skill_id_variant), int(cooldowns.get(skill_id_variant, 0)))

static func _clear_ally_statuses(battle, statuses_variant: Variant) -> void:
    for ally in battle.ally_units:
        if ally == null or not is_instance_valid(ally) or ally.is_defeated():
            continue
        for status_variant in Array(statuses_variant):
            battle._set_unit_visual_status(ally, StringName(status_variant), 0)

static func _erase_unit_runtime_entries(runtime_store: Dictionary, units: Array) -> void:
    for unit in units:
        if unit == null or not is_instance_valid(unit) or unit.is_defeated():
            continue
        runtime_store.erase(unit.get_instance_id())

static func _queue_board_redraw(battle) -> void:
    if battle.battle_board != null:
        battle.battle_board.queue_redraw()
