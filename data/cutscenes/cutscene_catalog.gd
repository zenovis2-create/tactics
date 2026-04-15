class_name CutsceneCatalog
extends RefCounted

## 컷씬 카탈로그 — 코드 기반으로 CutsceneData를 빌드
## (외부 .tres 없이 headless 환경에서도 참조 가능)

const CutsceneData = preload("res://scripts/cutscene/cutscene_data.gd")

## CH01 전투 시작 컷씬 (인트로 텍스트)
static func build_ch01_start() -> CutsceneData:
    var d: CutsceneData = CutsceneData.new()
    d.cutscene_id = &"ch01_start"
    d.skippable = true
    d.beats = [
        {
            "type": "black_screen",
            "text": "재의 들판. 살아남은 자들이 북쪽으로 이동한다.",
            "duration": 2.5
        },
        {
            "type": "text_card",
            "text": "Rian: 기억이 없다. 하지만 손은 기억하고 있다.",
            "duration": 3.0
        },
        {
            "type": "text_card",
            "text": "Serin: 이름을 모르면 우리를 따라와. 여기서 죽으면 이름도 없이 끝난다.",
            "duration": 3.5
        }
    ]
    return d

## CH01 전투 클리어 컷씬 (dawn oath 이후)
static func build_ch01_clear() -> CutsceneData:
    var d: CutsceneData = CutsceneData.new()
    d.cutscene_id = &"ch01_clear"
    d.skippable = true
    d.beats = [
        {
            "type": "text_card",
            "text": "Serin: 새벽 맹세가 끝났다. 이제 북쪽으로.",
            "duration": 3.0
        },
        {
            "type": "text_card",
            "text": "Rian: 이름도 없이 이 자리에 서 있다. 그래도 이 사람들은 살아남았다.",
            "duration": 3.5
        }
    ]
    return d

## CH01 기억 조각 획득 연출
static func build_ch01_fragment_flash() -> CutsceneData:
    var d: CutsceneData = CutsceneData.new()
    d.cutscene_id = &"ch01_fragment_flash"
    d.skippable = false  # 기억 조각 연출은 스킵 불가
    d.beats = [
        {
            "type": "black_screen",
            "text": "",
            "duration": 0.5
        },
        {
            "type": "fragment_flash",
            "fragment_id": "mem_frag_ch01_first_order",
            "text": "기억 조각 복원됨: 첫 번째 명령",
            "duration": 2.0
        },
        {
            "type": "command_unlock",
            "command_id": "tactical_shift",
            "text": "커맨드 해금: 전술 이동",
            "duration": 2.0
        }
    ]
    return d

## ID로 컷씬 조회
static func get_cutscene(cutscene_id: StringName) -> CutsceneData:
    match cutscene_id:
        &"ch01_start":
            return build_ch01_start()
        &"ch01_clear":
            return build_ch01_clear()
        &"ch01_fragment_flash":
            return build_ch01_fragment_flash()
        _:
            return null
