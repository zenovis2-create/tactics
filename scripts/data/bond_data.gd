class_name BondData
extends Resource

## 동료별 Bond 리소스
## bond_level 0-5: 각 레벨은 개인 아크 완료 조건과 연결

const MAX_BOND: int = 5

@export var companion_id: StringName = &""
@export var bond_level: int = 0

## 이 아크 플래그들이 충족되어야 다음 레벨로 올라갈 수 있음
## 예: [&"ch01_serin_arc_complete"] → bond 1→2 조건
@export var arc_flags_required: Array[StringName] = []

func is_valid() -> bool:
    return companion_id != &""

func to_debug_dict() -> Dictionary:
    return {
        "companion_id": companion_id,
        "bond_level": bond_level,
        "arc_flags_required": arc_flags_required
    }
