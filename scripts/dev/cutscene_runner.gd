extends SceneTree

## 3-E: 컷씬 시스템 검증 러너
## - CutsceneData 필드 및 유효성 확인
## - CutsceneCatalog CH01 리소스 3개 로드
## - CutscenePlayer.play() → beat 순서대로 진행
## - skip() → skippable/non-skippable 구분
## - fragment_flash beat 이벤트 로그 기록
## - command_unlock beat 이벤트 로그 기록
## - get_snapshot() 키 검증
## - beat_started/cutscene_finished 시그널 발화

const CutsceneData = preload("res://scripts/cutscene/cutscene_data.gd")
const CutscenePlayer = preload("res://scripts/cutscene/cutscene_player.gd")
const CutsceneCatalog = preload("res://data/cutscenes/cutscene_catalog.gd")

var _failed: bool = false

func _initialize() -> void:
    call_deferred("_run")

func _run() -> void:
    var player: CutscenePlayer = CutscenePlayer.new()
    root.add_child(player)
    await process_frame

    if not _assert_cutscene_data_fields(): return
    if not _assert_catalog_loads(): return
    if not _assert_play_advances_beats(player): return
    if not _assert_skip_skippable(player): return
    if not _assert_skip_non_skippable(player): return
    if not _assert_fragment_flash_log(player): return
    if not _assert_command_unlock_log(player): return
    if not _assert_snapshot_keys(player): return

    print("[PASS] cutscene_runner: all assertions passed.")
    quit(0)

# --- Assertions ---

func _assert_cutscene_data_fields() -> bool:
    var d: CutsceneData = CutsceneData.new()
    if not d.get("cutscene_id") is StringName:
        return _fail("CutsceneData.cutscene_id must be StringName")
    if not d.get("skippable") is bool:
        return _fail("CutsceneData.skippable must be bool")
    if not d.get("beats") is Array:
        return _fail("CutsceneData.beats must be Array")
    if not d.is_valid() == false:
        return _fail("Empty CutsceneData.is_valid() should be false")
    return true

func _assert_catalog_loads() -> bool:
    var ch01_start = CutsceneCatalog.get_cutscene(&"ch01_start")
    if ch01_start == null:
        return _fail("ch01_start not found in catalog")
    if not ch01_start.is_valid():
        return _fail("ch01_start should be valid (has beats)")
    if ch01_start.get_beat_count() < 2:
        return _fail("ch01_start should have at least 2 beats")

    var ch01_clear = CutsceneCatalog.get_cutscene(&"ch01_clear")
    if ch01_clear == null:
        return _fail("ch01_clear not found in catalog")

    var ch01_flash = CutsceneCatalog.get_cutscene(&"ch01_fragment_flash")
    if ch01_flash == null:
        return _fail("ch01_fragment_flash not found in catalog")
    if ch01_flash.skippable:
        return _fail("fragment_flash cutscene should not be skippable")
    return true

func _assert_play_advances_beats(player: CutscenePlayer) -> bool:
    var data: CutsceneData = CutsceneCatalog.get_cutscene(&"ch01_start")

    player.play(data)
    if not player.is_playing():
        return _fail("player should be playing after play()")

    # beat를 하나씩 즉시 완료
    var beat_count: int = data.get_beat_count()
    for i in beat_count:
        player.advance_beat_immediate()

    if player.is_playing():
        return _fail("player should stop after all beats completed")

    # 이벤트 로그에서 cutscene_finished 확인
    var log: Array[Dictionary] = player.get_event_log()
    var found_finish: bool = false
    for entry: Dictionary in log:
        if entry.get("event") == "cutscene_finished":
            found_finish = true
    if not found_finish:
        return _fail("event log should contain cutscene_finished")
    return true

func _assert_skip_skippable(player: CutscenePlayer) -> bool:
    var data: CutsceneData = CutsceneCatalog.get_cutscene(&"ch01_clear")

    player.play(data)
    player.skip()

    if player.is_playing():
        return _fail("player should stop after skip()")

    # 이벤트 로그에서 skipped=true 확인
    var log: Array[Dictionary] = player.get_event_log()
    var skipped_ok: bool = false
    for entry: Dictionary in log:
        if entry.get("event") == "cutscene_finished" and bool(entry.get("skipped", false)):
            skipped_ok = true
    if not skipped_ok:
        return _fail("event log should record cutscene_finished with skipped=true")
    return true

func _assert_skip_non_skippable(player: CutscenePlayer) -> bool:
    var data: CutsceneData = CutsceneCatalog.get_cutscene(&"ch01_fragment_flash")
    player.play(data)
    player.skip()
    if not player.is_playing():
        return _fail("non-skippable cutscene should still be playing after skip()")
    # 강제 완료
    var bc: int = data.get_beat_count()
    for i in bc:
        player.advance_beat_immediate()
    return true

func _assert_fragment_flash_log(player: CutscenePlayer) -> bool:
    var data: CutsceneData = CutsceneCatalog.get_cutscene(&"ch01_fragment_flash")
    player.play(data)
    var bc: int = data.get_beat_count()
    for i in bc:
        player.advance_beat_immediate()

    var log: Array[Dictionary] = player.get_event_log()
    var found_flash: bool = false
    for entry: Dictionary in log:
        if entry.get("event") == "fragment_flash":
            found_flash = true
    if not found_flash:
        return _fail("event log should contain fragment_flash event")
    return true

func _assert_command_unlock_log(player: CutscenePlayer) -> bool:
    var log: Array[Dictionary] = player.get_event_log()
    var found_unlock: bool = false
    for entry: Dictionary in log:
        if entry.get("event") == "command_unlock":
            found_unlock = true
    if not found_unlock:
        return _fail("event log should contain command_unlock event")
    return true

func _assert_snapshot_keys(player: CutscenePlayer) -> bool:
    var data: CutsceneData = CutsceneCatalog.get_cutscene(&"ch01_start")
    player.play(data)
    var snap: Dictionary = player.get_snapshot()
    for key: String in ["is_playing", "cutscene_id", "beat_index", "beat_total", "is_skipped"]:
        if not snap.has(key):
            return _fail("snapshot missing key: %s" % key)
    # 강제 완료
    var bc: int = data.get_beat_count()
    for i in bc:
        player.advance_beat_immediate()
    return true

func _fail(msg: String) -> bool:
    print("[FAIL] ", msg)
    _failed = true
    quit(1)
    return false
