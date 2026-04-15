class_name CutsceneData
extends Resource

## 컷씬 리소스 — beat 시퀀스로 구성
## beat type:
##   text_card     — 텍스트 카드 (대사 또는 내레이션)
##   fragment_flash — 기억 조각 획득 연출 (검은 플래시 → 텍스트)
##   command_unlock — 커맨드 해금 메시지
##   black_screen   — 검은 화면 + 선택적 텍스트

@export var cutscene_id: StringName = &""
@export var skippable: bool = true

## beats: Array of Dictionaries
##   { "type": "text_card", "text": "...", "image_path": "", "duration": 3.0 }
@export var beats: Array[Dictionary] = []

func get_beat_count() -> int:
    return beats.size()

func get_beat(index: int) -> Dictionary:
    if index < 0 or index >= beats.size():
        return {}
    return beats[index]

func is_valid() -> bool:
    return cutscene_id != &"" and not beats.is_empty()

func to_debug_dict() -> Dictionary:
    return {
        "cutscene_id": cutscene_id,
        "skippable": skippable,
        "beat_count": beats.size()
    }
