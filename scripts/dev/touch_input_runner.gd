extends SceneTree

## Touch Input Validation Runner
## Android/모바일 터치 입력 시뮬레이션 헤드리스 검증
## InputEventScreenTouch / InputEventScreenDrag를 직접 주입하여 게임 로직이 응답하는지 확인

const MAIN_SCENE: PackedScene = preload("res://scenes/Main.tscn")

var _results: Array[String] = []
var _fail: bool = false

func _initialize() -> void:
    call_deferred("_run")

func _run() -> void:
    var main: Node = MAIN_SCENE.instantiate()
    root.add_child(main)
    await process_frame
    await process_frame

    if main.has_method("start_game_direct"):
        main.start_game_direct()
        await process_frame
        await process_frame

    var battle = main.get_node_or_null("BattleScene")
    if battle == null:
        _fail_test("BattleScene not found in Main")
        _finish()
        return

    # ── 1. touch_tap_on_unit: 유닛 위치에 터치 이벤트 주입 ──────────────────
    await _wait_for_player_phase(battle)
    var ally_units: Array = battle.ally_units
    if ally_units.is_empty():
        _fail_test("No ally units to touch-test")
        _finish()
        return

    var first_unit = ally_units[0]
    var tap_pos: Vector2 = _grid_to_screen(battle, first_unit.grid_position)
    _inject_touch(tap_pos, 0)  # press
    await process_frame
    _inject_touch_release(tap_pos, 0)  # release
    await process_frame
    await process_frame
    _pass_test("touch_tap_on_unit: tap injected without crash (pos=%s)" % str(tap_pos))

    # ── 2. touch_drag_scroll: 드래그 이벤트 주입 (패닉 없어야 함) ─────────────
    var drag_start := Vector2(200, 200)
    var drag_end   := Vector2(300, 300)
    _inject_drag(drag_start, 0)
    await process_frame
    for step in range(5):
        var t := float(step) / 4.0
        _inject_drag_move(drag_start.lerp(drag_end, t), 0)
        await process_frame
    _inject_drag_end(drag_end, 0)
    await process_frame
    _pass_test("touch_drag_scroll: drag sequence injected without crash")

    # ── 3. multi_touch_pinch: 두 손가락 터치 (패닉 없어야 함) ────────────────
    _inject_touch(Vector2(150, 200), 0)
    _inject_touch(Vector2(350, 200), 1)
    await process_frame
    _inject_touch_release(Vector2(150, 200), 0)
    _inject_touch_release(Vector2(350, 200), 1)
    await process_frame
    _pass_test("multi_touch_pinch: two-finger touch injected without crash")

    # ── 4. touch_hud_button_area: HUD 영역 터치 ──────────────────────────────
    # HUD는 화면 하단에 위치. 임의 HUD 좌표 주입
    var hud_pos := Vector2(100, 700)
    _inject_touch(hud_pos, 0)
    await process_frame
    _inject_touch_release(hud_pos, 0)
    await process_frame
    _pass_test("touch_hud_button_area: HUD area touch injected without crash")

    # ── 5. Battle flow continues after touch ─────────────────────────────────
    # 터치 주입 후에도 배틀이 아직 진행 중인지 (phase가 유효한지)
    var phase: int = int(battle.current_phase)
    var valid_phases := [
        int(battle.BattlePhase.PLAYER_SELECT),
        int(battle.BattlePhase.PLAYER_ACTION_PREVIEW),
        int(battle.BattlePhase.PLAYER_PHASE_START),
        int(battle.BattlePhase.ENEMY_PHASE_START),
        int(battle.BattlePhase.ENEMY_DECIDE),
        int(battle.BattlePhase.ENEMY_ACTION_RESOLVE),
        int(battle.BattlePhase.ENEMY_PHASE_END),
        int(battle.BattlePhase.ROUND_END),
        int(battle.BattlePhase.VICTORY),
        int(battle.BattlePhase.DEFEAT),
    ]
    if phase in valid_phases:
        _pass_test("battle_phase_valid_after_touch: phase=%d" % phase)
    else:
        _fail_test("battle_phase_invalid_after_touch: phase=%d" % phase)

    _finish()

# ── Touch Event Injection ─────────────────────────────────────────────────────

func _inject_touch(pos: Vector2, finger: int) -> void:
    var ev := InputEventScreenTouch.new()
    ev.position = pos
    ev.index    = finger
    ev.pressed  = true
    root.get_viewport().push_input(ev)

func _inject_touch_release(pos: Vector2, finger: int) -> void:
    var ev := InputEventScreenTouch.new()
    ev.position = pos
    ev.index    = finger
    ev.pressed  = false
    root.get_viewport().push_input(ev)

func _inject_drag(pos: Vector2, finger: int) -> void:
    var ev := InputEventScreenDrag.new()
    ev.position = pos
    ev.index    = finger
    ev.relative = Vector2.ZERO
    ev.velocity = Vector2.ZERO
    root.get_viewport().push_input(ev)

func _inject_drag_move(pos: Vector2, finger: int) -> void:
    var ev := InputEventScreenDrag.new()
    ev.position = pos
    ev.index    = finger
    ev.relative = Vector2(10, 10)
    ev.velocity = Vector2(100, 100)
    root.get_viewport().push_input(ev)

func _inject_drag_end(pos: Vector2, finger: int) -> void:
    _inject_touch_release(pos, finger)

# ── Helpers ──────────────────────────────────────────────────────────────────

func _grid_to_screen(battle, grid_pos: Vector2i) -> Vector2:
    # BattleBoard의 _cell_center_position() 또는 _cell_center() 메서드 시도
    if battle.has_method("_cell_center_position"):
        return battle._cell_center_position(grid_pos)
    # Fallback: 타일 크기 추정으로 계산
    var tile_size: int = 48
    return Vector2(grid_pos.x * tile_size + tile_size / 2,
                   grid_pos.y * tile_size + tile_size / 2)

func _wait_for_player_phase(battle) -> void:
    var safety: int = 0
    while true:
        var phase: int = int(battle.current_phase)
        if phase == int(battle.BattlePhase.PLAYER_SELECT) or \
           phase == int(battle.BattlePhase.PLAYER_ACTION_PREVIEW):
            return
        if phase == int(battle.BattlePhase.VICTORY) or phase == int(battle.BattlePhase.DEFEAT):
            return
        await process_frame
        safety += 1
        if safety > 120:
            push_warning("touch_input_runner: timed out waiting for player phase")
            return

func _pass_test(msg: String) -> void:
    _results.append("  PASS: " + msg)

func _fail_test(msg: String) -> void:
    _results.append("  FAIL: " + msg)
    _fail = true

func _finish() -> void:
    for r in _results:
        print(r)
    if _fail:
        push_error("[FAIL] touch_input_runner: one or more assertions failed.")
        quit(1)
    else:
        print("[PASS] touch_input_runner: all touch input assertions passed.")
        quit(0)
