extends SceneTree

## AudioEventRouter 최소 재현 누수 러너
## AudioEventRouter만 단독으로 생성·사용·해제하여 WAV/Playback 누수 원인을 확인

const AudioEventRouterScript = preload("res://scripts/audio/audio_event_router.gd")

var _router: Node = null

func _initialize() -> void:
    call_deferred("_run")

func _run() -> void:
    _router = AudioEventRouterScript.new()
    root.add_child(_router)
    await process_frame
    await process_frame

    # 실제 런타임에서 발생하는 것과 동일한 시퀀스: 다수 cue 반복 재생 (pool round-robin 포함)
    var cues := [
        "ui_inventory_open_01",
        "ui_inventory_close_01",
        "ui_common_cancel_01",
        "ui_common_confirm_01",
        "battle_hit_confirm_01",
        "battle_miss_01",
        "battle_state_enemy_phase_01",
        "battle_state_player_phase_01",
    ]
    for cue in cues:
        _router._on_ui_cue_requested(cue)
        await process_frame

    # 한 번 더 반복해서 pool slot을 다시 점유
    for cue in cues:
        _router._on_ui_cue_requested(cue)
        await process_frame

    var snapshot: Dictionary = _router.get_snapshot()
    print("[audio_event_router_min_runner] snapshot: ", snapshot)

    # 정리
    if _router != null and is_instance_valid(_router):
        _router.queue_free()
        _router = null
    await process_frame
    await process_frame

    print("[PASS] audio_event_router_min_runner completed.")
    quit(0)
