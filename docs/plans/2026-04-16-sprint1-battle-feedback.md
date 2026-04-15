# Sprint 1 — Battle Feedback: Damage Popup & Attack Animation

> **Goal:** 전투 피드백을 파랜드택틱스급으로 끌어올리는 두 가지 즉각 임팩트 구현.
> **Architecture:** 기존 소유권 유지. `UnitActor`가 시각 담당, `CombatService`/`BattleController`가 로직 담당, `DamageLabel`은 신규 노드.

---

## 1. Task 1-A: DamageLabel (데미지 숫자 팝업)

### Goal
전투에서 데미지/MISS/GUARD/CRITICAL 텍스트가 유닛 위로 부유하며 사라지는 시스템.

### Files
- **Create:** `scripts/battle/damage_label.gd`
- **Create:** `scenes/battle/DamageLabel.tscn`
- **Modify:** `scripts/battle/unit_actor.gd` — `show_damage()` 메서드 추가
- **Modify:** `scripts/battle/battle_controller.gd` — 데미지 발생 시 `show_damage()` 호출

### Design Rules
- `DamageLabel`은 `Node2D` 기반. `Label` 자식으로 텍스트 표시.
- 부유 애니메이션: y축 -40px 이동 + alpha 1→0, 총 0.8초 후 `queue_free()`.
- 색상: 일반 데미지=빨강, 치유=초록, MISS=회색, GUARD=노랑, CRITICAL=빨강+크게.
- `UnitActor.show_damage(amount: int, type: StringName)` → DamageLabel 인스턴스 생성.
- `BattleController._on_resolve_attack()` 결과에서 데미지 값 추출 → `defender.show_damage(damage, type)` 호출.
- `BattleController`는 `show_damage` 호출만, 애니메이션 로직은 `DamageLabel`이 자체 처리.
- 모바일 가독성: 폰트 최소 16px, 외곽선 2px.

### Implementation Spec

```gdscript
# scripts/battle/damage_label.gd
class_name DamageLabel
extends Node2D

const FLOAT_DISTANCE := 40.0
const DURATION := 0.8
const FONT_SIZE_NORMAL := 18
const FONT_SIZE_CRIT := 24

@onready var label: Label = $Label

var _type_colors: Dictionary = {
    &"damage": Color.RED,
    &"heal": Color.GREEN,
    &"miss": Color.GRAY,
    &"guard": Color.YELLOW,
    &"critical": Color.ORANGE_RED,
}

func setup(amount: int, type: StringName = &"damage") -> void:
    var text: String = _format_text(amount, type)
    label.text = text
    label.add_theme_font_size_override("font_size",
        FONT_SIZE_CRIT if type == &"critical" else FONT_SIZE_NORMAL)
    label.add_theme_color_override("font_color",
        _type_colors.get(type, Color.WHITE))
    _play_animation()

func _format_text(amount: int, type: StringName) -> String:
    match type:
        &"miss": return "MISS"
        &"guard": return "GUARD"
        &_: return str(amount)

func _play_animation() -> void:
    var tw := create_tween().set_trans(Tween.TRANS_SINE)
    tw.tween_property(self, "position:y", position.y - FLOAT_DISTANCE, DURATION)
    tw.parallel().tween_property(label, "modulate:a", 0.0, DURATION)
    tw.tween_callback(queue_free)
```

### Runner Spec

```gdscript
# scripts/dev/s1_damage_popup_runner.gd
# 동적 인스턴스 기반 테스트:
# 1. DamageLabel 인스턴스 생성 → setup(15, &"damage") → 텍스트 "15" 확인
# 2. DamageLabel 인스턴스 생성 → setup(0, &"miss") → 텍스트 "MISS" 확인
# 3. DamageLabel 인스턴스 생성 → setup(25, &"critical") → 폰트 사이즈 24 확인
# 4. UnitActor 인스턴스 → show_damage(10, &"damage") → DamageLabel 자식 존재 확인
# 5. Gate 0 PASS
```

---

## 2. Task 1-B: Attack Animation (전진-타격-복귀)

### Goal
유닛이 적 방향으로 0.12초 전진 → 타격 이펙트 → 0.10초 복귀 애니메이션.

### Files
- **Modify:** `scripts/battle/unit_actor.gd` — `play_attack_animation()` 메서드 추가
- **Modify:** `scripts/battle/battle_controller.gd` — 공격 해결 전 애니메이션 재생 후 진행

### Design Rules
- `UnitActor.play_attack_animation(target_pos: Vector2i, cell_size: float)` → tween 생성.
- 전진 거리: 타겟 방향으로 `cell_size * 0.4` (24px @ 60px cell).
- 시퀀스: 전진(0.12s, SINE) → 콜백(타격) → 복귀(0.10s, SINE).
- 타격 콜백 시점에 `_on_attack_anim_hit()` 시그널 방출.
- `BattleController`는 시그널 대기 후 `_resolve_attack()` 호출.
- 피격 시 넉백은 Sprint 3+에서 구현 (현재는 전진-복귀만).
- 모바일: tween 시간 축소 없음 (0.22초 총.< 0.3초 목표).

### Implementation Spec

```gdscript
# In unit_actor.gd — new methods

signal attack_anim_hit  ## 타격 시점 방출

var _animating_attack: bool = false

func play_attack_animation(target_pos: Vector2i, cell_size: float) -> void:
    if _animulating_attack:
        return
    _animulating_attack = true
    var original_pos: Vector2 = position
    var direction: Vector2 = Vector2(
        target_pos.x * cell_size - original_pos.x,
        target_pos.y * cell_size - original_pos.y
    ).normalized()
    var lunge_distance: float = cell_size * 0.4
    var target_offset: Vector2 = direction * lunge_distance

    var tw := create_tween().set_trans(Tween.TRANS_SINE)
    tw.tween_property(self, "position", original_pos + target_offset, 0.12)
    tw.tween_callback(_on_attack_anim_hit.emit)
    tw.tween_property(self, "position", original_pos, 0.10)
    tw.tween_callback(func(): _animulating_attack = false)

func is_animating_attack() -> bool:
    return _animulating_attack
```

```gdscript
# In battle_controller.gd — modified attack resolution
# _commit_player_attack() 또는 유사 메서드에서:
#   attacker.play_attack_animation(defender.grid_position, stage_data.cell_size)
#   await attacker.attack_anim_hit
#   _resolve_attack(attacker, defender, ...)
```

### Runner Spec

```gdscript
# scripts/dev/s1_attack_anim_runner.gd
# 1. UnitActor 인스턴스 생성 → play_attack_animation 호출 → _animulating_attack == true 확인
# 2. attack_anim_hit 시그널 방출 확인
# 3. 애니메이션 완료 후 _animulating_attack == false 확인
# 4. 중복 호출 시 무시 확인 (_animulating_attack == true 중 재호출 → 리턴)
# 5. is_animating_attack() getter 확인
# 6. Gate 0 PASS
```

---

## 3. Integration: BattleController 데미지 표시 흐름

### Flow
```
BattleController._commit_player_attack()
  → attacker.play_attack_animation(defender.grid_position, cell_size)
  → await attacker.attack_anim_hit
  → result = _resolve_attack(attacker, defender, ...)
  → defender.show_damage(result.damage, _damage_type(result))
  → (if support_attack) supporter.show_damage(support_damage, &"damage")
```

### _damage_type helper
```gdscript
func _damage_type(result: Dictionary) -> StringName:
    if not bool(result.get("hit", true)):
        return &"miss"
    if bool(result.get("guard", false)):
        return &"guard"
    var dmg: int = int(result.get("damage", 0))
    if dmg >= int(result.get("defender_hp_before", 999)) * 2:
        return &"critical"
    if dmg <= 0:
        return &"heal"
    return &"damage"
```

---

## 4. Sprint 1 Checklist

- [ ] `damage_label.gd` 작성 및 DamageLabel.tscn 생성
- [ ] `unit_actor.gd`에 `show_damage()` 메서드 추가
- [ ] `unit_actor.gd`에 `play_attack_animation()` 메서드 추가
- [ ] `battle_controller.gd`에 데미지 타입 헬퍼 및 호출 흐름 통합
- [ ] `s1_damage_popup_runner.gd` 작성 및 PASS
- [ ] `s1_attack_anim_runner.gd` 작성 및 PASS
- [ ] Gate 0 PASS
- [ ] 기존 러너 전체 회귀 PASS (battle_result, m1_playtest, m3_ui, bond, ai_depth)

---

## 5. 병렬 작업 계획

| 태스크 | 독립성 | 병렬 가능 |
|--------|--------|-----------|
| 1-A DamageLabel (신규 파일) | 완전 독립 | ✅ |
| 1-B Attack Animation (unit_actor.gd 수정) | unit_actor.gd 공유 | 1-A 완료 후 권장 |
| 1-C 통합 러너 | 1-A, 1-B 완료 후 | ❌ 순차 |

**추천:** 1-A를 먼저 완료 → 1-B 진행 → 1-C 통합.

단, 1-A의 `damage_label.gd`와 `.tscn`은 `unit_actor.gd`와 무관하므로 **1-A와 1-B를 병렬로 시작** 가능.
단, `unit_actor.gd`에 `show_damage()`를 추가하는 건 1-B에서 `play_attack_animation()`도 같이 추가하므로
한 번에 처리하는 것이 충돌 방지에 유리.