extends SceneTree

const BATTLE_SCENE: PackedScene = preload("res://scenes/battle/BattleScene.tscn")
const CombatService = preload("res://scripts/battle/combat_service.gd")
const CH02_STAGE = preload("res://data/stages/ch02_02_stage.tres")
const CH06_STAGE = preload("res://data/stages/ch06_05_stage.tres")
const CH10_STAGE = preload("res://data/stages/ch10_05_stage.tres")

var _failed: bool = false

func _initialize() -> void:
    call_deferred("_run")

func _run() -> void:
    await _assert_rain_extinguishes_fire_and_shows_weather()
    if _failed:
        return
    await _assert_night_reduces_ranged_range()
    if _failed:
        return
    await _assert_fire_night_smoke_synergy()
    if _failed:
        return

    print("[PASS] weather_system_runner: rain, night, and terrain synergy checks passed.")
    quit(0)

func _assert_rain_extinguishes_fire_and_shows_weather() -> void:
    var battle = await _spawn_battle_with_stage(CH02_STAGE, "rain", [
        {"type": "fire", "position": Vector2i(3, 3), "radius": 0}
    ])
    if _failed:
        return

    if battle.weather_type != "rain":
        _fail("Rain battle should expose weather_type = 'rain'.")
        return
    if battle.hud._status_weather_label.text != "🌧️":
        _fail("Rain battle HUD should show the rain icon.")
        return
    if _has_feature_type(battle.stage_data.terrain_features, "fire"):
        _fail("Rain weather should extinguish fire terrain features at battle start.")
        return
    if "steam" not in battle._synergy_activation_log:
        _fail("Rain + fire should trigger the steam synergy reaction.")
        return
    battle.queue_free()
    await process_frame

func _assert_night_reduces_ranged_range() -> void:
    var combat_service := CombatService.new()
    root.add_child(combat_service)
    combat_service.set_weather_type("night")
    var effective_range := combat_service._apply_weather_range_modifier(3, "night")
    if effective_range != 2:
        _fail("Night weather should reduce ranged attack range from 3 to 2, got %d." % effective_range)
        return
    combat_service.queue_free()

    var battle = await _spawn_battle_with_stage(CH06_STAGE, "night", [])
    if _failed:
        return
    if battle.hud._status_weather_label.text != "🌙":
        _fail("Night battle HUD should show the moon icon.")
        return
    battle.queue_free()
    await process_frame

func _assert_fire_night_smoke_synergy() -> void:
    var battle = await _spawn_battle_with_stage(CH10_STAGE, "night", [
        {"type": "fire", "position": Vector2i(3, 3), "radius": 0}
    ])
    if _failed:
        return
    if "smoke" not in battle._synergy_activation_log:
        _fail("Night + fire should trigger the smoke synergy reaction.")
        return
    if not _has_feature_type(battle.stage_data.terrain_features, "smoke"):
        _fail("Smoke synergy should spread a smoke terrain feature.")
        return
    battle.queue_free()
    await process_frame

func _spawn_battle_with_stage(base_stage, weather: String, terrain_features: Array[Dictionary]):
    var stage = base_stage.duplicate(true)
    stage.weather_type = weather
    stage.terrain_synergies_enabled = true
    stage.terrain_features = terrain_features.duplicate(true)
    var battle = BATTLE_SCENE.instantiate()
    root.add_child(battle)
    battle.set_stage(stage)
    await process_frame
    await process_frame
    return battle

func _has_feature_type(features: Array, feature_type: String) -> bool:
    for feature_variant in features:
        var feature: Dictionary = feature_variant
        if String(feature.get("type", "")).to_lower() == feature_type:
            return true
    return false

func _fail(message: String) -> void:
    if _failed:
        return
    _failed = true
    push_error(message)
    quit(1)
