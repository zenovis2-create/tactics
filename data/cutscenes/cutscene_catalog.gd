class_name CutsceneCatalog
extends RefCounted

## 컷씬 카탈로그 — 코드 기반으로 CutsceneData를 빌드
## (외부 .tres 없이 headless 환경에서도 참조 가능)

const CutsceneData = preload("res://scripts/cutscene/cutscene_data.gd")

const STAGE_TEXT_CUTSCENES := {
    &"ch01_02_intro": {"header": "재의 들판 — 생존자 행렬.", "lines": ["세린: 뒤를 막는 병사들이 따라붙고 있어. 생존자들을 동쪽으로 빼내야 해.", "리안: 호위선을 열고, 후퇴 경로를 끊지 않겠다."]},
    &"ch01_02_outro": {"header": "", "lines": ["세린: 생존자들은 빠져나갔어. 다음 흔적은 폐허 우물 쪽이야.", "리안: 후퇴 명령을 내린 장교가 왜 거길 지켰는지 확인한다."]},
    &"ch01_03_intro": {"header": "폐허 우물 — 봉인 흔적.", "lines": ["세린: 우물 아래로 숨긴 문장이 있어. 후퇴 장교도 그걸 지키려 했어.", "리안: 봉인선을 읽고, 북문으로 이어지는 길을 드러낸다."]},
    &"ch01_03_outro": {"header": "", "lines": ["세린: 북문으로 이어지는 표식이 선명해졌어.", "리안: 다음은 성벽 아래, 그 차가운 지휘 목소리의 근원이다."]},
    &"ch01_04_intro": {"header": "북문 외곽 — 무너진 성벽.", "lines": ["세린: 성문이 완전히 잠기기 전에 약점을 찾아야 해.", "리안: 붕괴선과 화살 사선을 함께 끊어서 새벽 전당으로 들어간다."]},
    &"ch01_04_outro": {"header": "", "lines": ["세린: 성문 약점은 열렸어. 이제 맹세의 전당만 남았어.", "리안: 새벽의 맹세를 여기서 끝낸다."]},
    &"ch01_05_intro": {"header": "새벽의 맹세 — 전당 중심.", "lines": ["세린: 적 지휘관이 전열을 굳혔어. 여기서 무너지면 북쪽 길도 끝이야.", "리안: 지휘선을 자르고, 첫 명령의 기억을 되찾는다."]},
    &"ch01_05_outro": {"header": "", "lines": ["세린: 맹세선이 끊겼어. 이제 북쪽으로 갈 수 있어.", "리안: 살아남은 이름들을 데리고 교대 캠프로 이동한다."]},
    &"ch06_01_intro": {"header": "발토르 외곽 — 연막 성문.", "lines": ["브란: 포연이 아직 남아 있다. 성문이 닫히기 전에 포대선을 찢는다.", "리안: 외곽 진입로만 열면 요새 안쪽 흐름이 보일 거야."]},
    &"ch06_01_outro": {"header": "", "lines": ["세린: 연막 성문은 넘었다. 이제 포열 능선을 직접 상대해야 해.", "브란: 다음 진입은 더 좁아진다. 방패선을 정리해 둬."]},
    &"ch06_02_intro": {"header": "발토르 포열 능선 — 교차 포대.", "lines": ["브란: 좌우 포대를 같이 묶지 않으면 진입로가 갈린다.", "리안: 사슬 승강문을 기준으로 선을 맞춘다."]},
    &"ch06_02_outro": {"header": "", "lines": ["세린: 포대 화선이 끊겼어. 안쪽 성채까지 길이 난다.", "리안: 다음은 금고와 감옥 교차로. 요새의 심장부로 들어간다."]},
    &"ch06_03_intro": {"header": "발토르 내부 — 군수 금고.", "lines": ["에녹: 군수 기록이 여기서 갈라진다. 감옥 쪽과 성채 관문 중 하나를 먼저 눌러야 해.", "리안: 둘 다 잡는다. 금고를 읽고 관문을 연다."]},
    &"ch06_03_outro": {"header": "", "lines": ["브란: 군수선이 흔들렸어. 이제 외벽보다 안쪽 명령이 더 급하다.", "세린: 다음 구간은 의식 봉인 구역. 발가르가 직접 나설 거야."]},
    &"ch06_04_intro": {"header": "발토르 심부 — 의식 봉인.", "lines": ["세린: 봉인실이 열리면 맹세의 계단으로 바로 이어진다.", "리안: 봉인을 읽고 경사로를 확보한다. 발가르까지 한 번에 밀어붙인다."]},
    &"ch06_04_outro": {"header": "", "lines": ["브란: 봉인선은 무너졌다. 이제 남은 건 요새 제단뿐이야.", "리안: 발가르가 기다리는 자리까지 간다."]},
    &"ch07_01_intro": {"header": "엘리오르 외곽 — 행선판.", "lines": ["세린: 여기서는 전투보다 먼저 줄을 읽어야 해. 시장으로 가는 흐름 자체가 통제되고 있어.", "리안: 판과 종부터 끊는다. 그다음에야 사람들을 빼낼 수 있어."]},
    &"ch07_01_outro": {"header": "", "lines": ["세린: 광장으로 가는 행렬선이 흔들렸어.", "리안: 이제 침묵 명판을 직접 확인한다. 이 도시는 절차로 사람을 지우고 있어."]},
    &"ch07_02_intro": {"header": "엘리오르 광장 — 침묵 구역.", "lines": ["리안: 사각형으로 나눠 놓고 하나씩 비우는 구조야.", "세린: 명판과 해제 기둥을 같이 잡아야 다음 줄이 풀린다."]},
    &"ch07_02_outro": {"header": "", "lines": ["세린: 광장 통제가 깨졌다. 행렬선 뒤쪽 기록도 드러난다.", "리안: 다음은 실제 행렬 경로다. 목격 표식을 확보한다."]},
    &"ch07_03_intro": {"header": "엘리오르 행렬선 — 증언 회수.", "lines": ["세린: 두루마리와 목격 표식이 같이 있어야 성당 route가 확정돼.", "리안: 사람을 지운 순서를 반대로 따라간다."]},
    &"ch07_03_outro": {"header": "", "lines": ["세린: 성당으로 이어지는 route가 잡혔어.", "리안: 이제 회중석과 도르래까지 직접 들어간다."]},
    &"ch07_04_intro": {"header": "엘리오르 성당 외곽 — 회중석 도르래.", "lines": ["세린: 회중석 통로를 열면 안쪽 기도단으로 바로 닿아.", "리안: 도르래 두 개를 읽고, 중앙 좌석선을 비운다."]},
    &"ch07_04_outro": {"header": "", "lines": ["세린: 외곽 회랑은 열렸다. 이제 안쪽 기도단만 남았어.", "리안: 사리아가 기다리는 계단으로 간다."]},
    &"ch08_01_intro": {"header": "흑견 폐허 — 첫 추적.", "lines": ["티아: 서쪽 표식과 동쪽 신호대가 아직 살아 있어. 레테는 추격로를 좁혀 오려 할 거야.", "리안: 갈림길을 먼저 읽고, 추적선을 뺏는다."]},
    &"ch08_01_outro": {"header": "", "lines": ["티아: 첫 표식은 읽었어. 다음은 냄새가 더 짙은 초소 쪽이다.", "세린: 달 향기 초소로 이동한다. 매복이 시작될 거야."]},
    &"ch08_02_intro": {"header": "흑견 숲 — 달 향기 초소.", "lines": ["티아: 초소 둘 사이를 잘못 넘으면 곧바로 포위된다.", "리안: 분기 보관함부터 회수하고 길을 고정한다."]},
    &"ch08_02_outro": {"header": "", "lines": ["세린: 갈림길은 정리됐다. 이제 구금문 쪽으로 간다.", "리안: 레테의 추적대가 안쪽 폐허로 빠지고 있어."]},
    &"ch08_03_intro": {"header": "흑견 폐허 심부 — 구금문.", "lines": ["티아: 여기선 수감 기록과 배기 윈치를 같이 잡아야 해. 하나만 보면 곧 막힌다.", "리안: 숨을 통로부터 열고 사람들을 꺼낸다."]},
    &"ch08_03_outro": {"header": "", "lines": ["세린: 폐허 안쪽 통로가 열렸어.", "티아: 다음은 제어 각인 회랑. 레테가 직접 개입할 거야."]},
    &"ch08_04_intro": {"header": "흑견 회랑 — 제어 각인.", "lines": ["티아: 검은 표식이 회랑 전체를 잠갔어. 서쪽과 동쪽 제어를 같이 눌러야 길이 열린다.", "리안: 각인부터 끊는다. 레테를 좁은 마당으로 끌어낸다."]},
    &"ch08_04_outro": {"header": "", "lines": ["세린: 제어 각인이 꺼졌어. 이제 남은 건 흑견 마당이다.", "리안: 마지막 추격로에서 레테를 멈춘다."]},
    &"ch09a_01_intro": {"header": "서쪽 분기 — 방어 서판.", "lines": ["카일: 서쪽 route는 아직 군기가 남아 있다. 하지만 그 군기가 사람을 지우는 기준이 됐어.", "리안: 서판과 검문 통로를 같이 잡는다."]},
    &"ch09a_01_outro": {"header": "", "lines": ["세린: 첫 검문선이 열렸다. 다음은 장부 다리 쪽이다.", "카일: 맹세는 여전히 남아 있어. 안쪽으로 들어가면 더 노골적으로 보일 거야."]},
    &"ch09a_02_intro": {"header": "서쪽 분기 — 군기 다리.", "lines": ["카일: 다리 장부를 읽어야 다음 진입이 허가된다. 거부되면 바로 소거야.", "리안: 장부부터 확보하고 창기둥 화선을 끊는다."]},
    &"ch09a_02_outro": {"header": "", "lines": ["세린: 다리 검열선은 끊겼어.", "리안: 다음은 표식 회랑. 근원 접근 전 마지막 검열이다."]},
    &"ch09a_03_intro": {"header": "서쪽 분기 — 검열 표식.", "lines": ["카일: 표식 회랑은 명단과 바닥 각인을 같이 본다. 둘 중 하나만 놓쳐도 다시 원점이야.", "리안: 맹세 전당 바닥까지 한 번에 밀어."]},
    &"ch09a_03_outro": {"header": "", "lines": ["세린: 표식 회랑은 정리됐다.", "카일: 이제 남은 건 구금동과 안뜰. 끝이 가까워."]},
    &"ch09a_04_intro": {"header": "서쪽 분기 — 구금동.", "lines": ["카일: 여기서 살아남은 증언을 빼내지 못하면 마지막 전투도 의미가 없어.", "리안: 감방선을 열고 검열 창두를 끊는다."]},
    &"ch09a_04_outro": {"header": "", "lines": ["세린: 구금동은 열렸다. 이제 안뜰 중심부로 간다.", "리안: 마지막 검열선을 여기서 끊는다."]},
    &"ch09b_01_intro": {"header": "동쪽 분기 — 근원 봉인.", "lines": ["노아: 보관소는 길보다 색인을 먼저 읽어야 해. 틀리면 같은 자리만 돌게 된다.", "리안: 봉인과 색인을 같이 잡아 안쪽 관문을 연다."]},
    &"ch09b_01_outro": {"header": "", "lines": ["세린: 관문은 열렸어. 이제 서가가 움직이기 시작한다.", "노아: 다음은 삭제 구역. 기록이 의도적으로 비워진 곳이야."]},
    &"ch09b_02_intro": {"header": "동쪽 분기 — 삭제 서가.", "lines": ["노아: 여기선 남아 있는 책보다 사라진 칸이 더 중요해.", "리안: 개정 서가와 열람 구역을 같이 확인한다."]},
    &"ch09b_02_outro": {"header": "", "lines": ["세린: 삭제선의 방향이 보인다. 더 아래로 이어져 있어.", "노아: 다음은 기억 격자. 보관인의 손이 직접 닿는 층이다."]},
    &"ch09b_03_intro": {"header": "동쪽 분기 — 기억 격자.", "lines": ["노아: 걸쇠를 열지 않으면 기록은 읽히지 않아. 하지만 열리는 순간 방어선도 바뀐다.", "리안: 격자와 보관 기록을 한 번에 잡아."]},
    &"ch09b_03_outro": {"header": "", "lines": ["세린: 기억 격자는 열렸어. 이제 개정 핵만 남았다.", "노아: 다음 층은 정말로 누가 기록을 고쳤는지 드러나는 곳이야."]},
    &"ch09b_04_intro": {"header": "동쪽 분기 — 개정 핵.", "lines": ["노아: 붉은 주석 기둥이 중심이야. 좌우 개정 핵을 놓치면 전장이 다시 덮인다.", "리안: 핵 두 개를 읽고 심연으로 내려간다."]},
    &"ch09b_04_outro": {"header": "", "lines": ["세린: 개정선은 무너졌다. 이제 심연 중심부만 남았어.", "리안: 멜키온을 만나러 간다."]},
    &"ch10_01_intro": {"header": "무명의 탑 — 외곽 승강기.", "lines": ["세린: 첫 공명탑이 돌아가기 시작했어. 이제 위로 갈수록 이름이 더 크게 울린다.", "리안: 서판과 승강기를 잡고, 올라가는 길을 고정한다."]},
    &"ch10_01_outro": {"header": "", "lines": ["세린: 외곽 승강기는 확보했어.", "리안: 다음은 문장 제어 구역. 탑이 직접 선을 나누기 시작한다."]},
    &"ch10_02_intro": {"header": "무명의 탑 — 문장 제어.", "lines": ["세린: 좌우 문장 제어를 동시에 읽어야 외곽 고리가 풀린다.", "리안: 회랑 앵커로 가기 전에 탑의 손부터 자른다."]},
    &"ch10_02_outro": {"header": "", "lines": ["세린: 탑 고리는 열렸어. 이제 회랑이 드러난다.", "리안: 서쪽과 동쪽 앵커를 따라 더 위로 간다."]},
    &"ch10_03_intro": {"header": "무명의 탑 — 회랑 앵커.", "lines": ["리안: 양쪽 앵커가 회랑 전체를 붙들고 있어.", "세린: 하나만 풀면 다른 쪽이 더 강해져. 동시에 압박해야 해."]},
    &"ch10_03_outro": {"header": "", "lines": ["세린: 회랑 앵커는 풀렸어. 남은 건 왕의 전당 계단이다.", "리안: 이제 카르온의 목소리가 직접 들릴 거야."]},
    &"ch10_04_intro": {"header": "무명의 탑 — 왕의 전당.", "lines": ["카르온: 옥좌 아래까지 왔군. 하지만 아직 종을 울릴 이름은 없다.", "리안: 옥좌와 계단을 확보해. 마지막 종단으로 올라간다."]},
    &"ch10_04_outro": {"header": "", "lines": ["세린: 옥좌는 비었어. 이제 종길만 남았다.", "리안: 끝까지 올라간다. 이번에는 이름을 잃지 않아."]}
}

const HUNT_TEXT_CUTSCENES := {
    &"hunt_basil_launch": {"header": "회상 토벌전 — 바실.", "lines": ["침수 성소가 다시 잠기기 전에 제단 중심을 붙든다.", "바실의 마지막 기도는 이번엔 수위와 함께 되밀려 온다."]},
    &"hunt_basil_return": {"header": "", "lines": ["가라앉던 제단의 기록이 손에 남고, 침수선은 더 이상 부대를 밀어내지 못한다."]},
    &"hunt_saria_launch": {"header": "회상 토벌전 — 사리아.", "lines": ["무너지는 기도 행렬이 완전히 끊기기 전에 회중석을 정리한다.", "사리아의 합창은 이번에도 사람을 줄로 세우려 한다."]},
    &"hunt_saria_return": {"header": "", "lines": ["기도실의 마지막 합창이 꺼지고, 남은 이름들은 더 이상 줄 속에서 지워지지 않는다."]},
    &"hunt_lete_launch": {"header": "회상 토벌전 — 레테.", "lines": ["흑견 추격대가 사라지기 전에 마지막 사냥길을 끊는다.", "레테는 이번에도 추격을 마당 전체에 흩뿌리려 한다."]},
    &"hunt_lete_return": {"header": "", "lines": ["사냥의 마지막 흔적이 회수되고, 흑견 마당은 더 이상 누구의 발자국도 재촉하지 못한다."]},
    &"hunt_karuon_launch": {"header": "기억 시험 — 카르온.", "lines": ["본편의 마지막 전투가 아니라, 종길 압박만 떼어 낸 회상 시험이다.", "카르온의 종소리를 다시 읽고 Anchor Chain과 Bell Dais의 의미를 확인한다."]},
    &"hunt_karuon_return": {"header": "", "lines": ["종길의 잔향이 낮아지고, 마지막 이름을 잃지 않는 법만 기록으로 남는다."]},
}

static func _build_stage_text_cutscene(cutscene_id: StringName, header_text: String, lines: PackedStringArray, skippable: bool = true) -> CutsceneData:
    var d: CutsceneData = CutsceneData.new()
    d.cutscene_id = cutscene_id
    d.skippable = skippable
    var beats: Array[Dictionary] = []
    if not header_text.strip_edges().is_empty():
        beats.append({
            "type": "black_screen",
            "text": header_text,
            "duration": 2.0
        })
    for line in lines:
        if line.strip_edges().is_empty():
            continue
        beats.append({
            "type": "text_card",
            "text": line,
            "duration": 3.0
        })
    d.beats = beats
    return d

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
            "text": "리안: 기억은 없다. 하지만 손은 아직 기억하고 있다.",
            "duration": 3.0
        },
        {
            "type": "text_card",
            "text": "세린: 이름이 떠오르지 않아도 따라와. 여기서 쓰러지면 정말 이름도 없이 끝난다.",
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
            "text": "세린: 새벽의 맹세는 끝났다. 이제 북쪽으로 간다.",
            "duration": 3.0
        },
        {
            "type": "text_card",
            "text": "리안: 나는 이름도 없이 이 자리에 서 있다. 그래도 이 사람들은 살아남았다.",
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

## CH02 stage cutscenes
static func build_ch02_01_intro() -> CutsceneData:
    return _build_stage_text_cutscene(&"ch02_01_intro", "하드렌 외곽 — 국경의 연무.", PackedStringArray([
        "브란: 연막이 걷히기 전에 외벽으로 붙어야 한다.",
        "리안: 무너지기 시작한 방어선부터 끊어 낸다."
    ]))

static func build_ch02_01_outro() -> CutsceneData:
    return _build_stage_text_cutscene(&"ch02_01_outro", "", PackedStringArray([
        "세린: 첫 방어선은 넘었다. 이제 하드렌 성벽이 보인다.",
        "리안: 안으로 들어가면, 더 큰 전장이 기다리고 있다."
    ]))

static func build_ch02_02_intro() -> CutsceneData:
    return _build_stage_text_cutscene(&"ch02_02_intro", "하드렌 외벽 — 붕괴 지점.", PackedStringArray([
        "세린: 무너진 벽 너머로 길이 났어.",
        "리안: 포대 사선을 끊고 안쪽으로 진입한다."
    ]))

static func build_ch02_02_outro() -> CutsceneData:
    return _build_stage_text_cutscene(&"ch02_02_outro", "", PackedStringArray([
        "브란: 아직 안쪽에 남은 기사들이 있다.",
        "리안: 그들을 합류시키는 게 다음이다."
    ]))

static func build_ch02_03_intro() -> CutsceneData:
    return _build_stage_text_cutscene(&"ch02_03_intro", "하드렌 내성 앞 — 잔류 기사들.", PackedStringArray([
        "브란: 살아 있는 자가 남아 있다면, 내가 직접 데리고 나온다.",
        "리안: 그럼 길은 내가 연다."
    ]))

static func build_ch02_03_outro() -> CutsceneData:
    return _build_stage_text_cutscene(&"ch02_03_outro", "", PackedStringArray([
        "브란: ...이제 인정하지. 오늘은 네가 없었다면 끝장이었다.",
        "세린: 아직 끝난 건 아니야. 철문 아래로 내려간다."
    ]))

static func build_ch02_04_intro() -> CutsceneData:
    return _build_stage_text_cutscene(&"ch02_04_intro", "철문 아래 — 지하 제어로.", PackedStringArray([
        "리안: 레버 셋을 맞추면 내부문이 열린다.",
        "브란: 이 길은 기사단도 거의 쓰지 않던 길이다."
    ]))

static func build_ch02_04_outro() -> CutsceneData:
    return _build_stage_text_cutscene(&"ch02_04_outro", "", PackedStringArray([
        "세린: 내부 전당으로 가는 길이 열렸어.",
        "리안: 이제 하드렌의 군기를 직접 마주한다."
    ]))

static func build_ch02_05_intro() -> CutsceneData:
    return _build_stage_text_cutscene(&"ch02_05_intro", "하드렌 전당 — 부서진 군기.", PackedStringArray([
        "브란: 저 군기가 아직 서 있다면 하드렌도 아직 완전히 죽진 않았다.",
        "리안: 그 끝을 여기서 정리한다."
    ]))

static func build_ch02_05_outro() -> CutsceneData:
    return _build_stage_text_cutscene(&"ch02_05_outro", "", PackedStringArray([
        "브란: 하드렌은 끝났다. 이제 내가 너희와 간다.",
        "세린: 다음 흔적은 숲으로 이어진다."
    ]))

## CH03 stage cutscenes
static func build_ch03_01_intro() -> CutsceneData:
    return _build_stage_text_cutscene(&"ch03_01_intro", "녹영숲 입구 — 잃어버린 숲.", PackedStringArray([
        "티아: 발을 헛디디면 숲이 널 삼킬 거다.",
        "리안: 그렇다면 길이 남은 흔적부터 찾는다."
    ]))

static func build_ch03_01_outro() -> CutsceneData:
    return _build_stage_text_cutscene(&"ch03_01_outro", "", PackedStringArray([
        "세린: 숲도 누군가의 명령 아래 움직인 흔적이 있어.",
        "리안: 더 안쪽으로 들어가면 답이 나온다."
    ]))

static func build_ch03_02_intro() -> CutsceneData:
    return _build_stage_text_cutscene(&"ch03_02_intro", "녹영숲 하단 — 덫선.", PackedStringArray([
        "티아: 여기서부터는 숲이 아니라 사냥터다.",
        "리안: 덫을 끊고 난민 길을 살린다."
    ]))

static func build_ch03_02_outro() -> CutsceneData:
    return _build_stage_text_cutscene(&"ch03_02_outro", "", PackedStringArray([
        "티아: 네가 적이 아니라는 건 알겠어. 하지만 아직 믿진 않아.",
        "세린: 그 정도면 충분해. 다음 길로 간다."
    ]))

static func build_ch03_03_intro() -> CutsceneData:
    return _build_stage_text_cutscene(&"ch03_03_intro", "녹영숲 중부 — 난민 대열.", PackedStringArray([
        "세린: 대열이 흩어지면 끝이야.",
        "리안: 경로를 확보하고 모두를 통과시킨다."
    ]))

static func build_ch03_03_outro() -> CutsceneData:
    return _build_stage_text_cutscene(&"ch03_03_outro", "", PackedStringArray([
        "티아: 숲길은 하나로 좁혀졌다. 이젠 제단 쪽이야.",
        "리안: 남은 흔적도 거기서 이어진다."
    ]))

static func build_ch03_04_intro() -> CutsceneData:
    return _build_stage_text_cutscene(&"ch03_04_intro", "녹영숲 심부 — 산불의 메아리.", PackedStringArray([
        "세린: 불길이 아직도 명령처럼 남아 있어.",
        "리안: 그 명령이 어디서 왔는지 확인한다."
    ]))

static func build_ch03_04_outro() -> CutsceneData:
    return _build_stage_text_cutscene(&"ch03_04_outro", "", PackedStringArray([
        "티아: 산불은 사고가 아니었어.",
        "리안: 그렇다면 마지막 제단에서 누가 시켰는지 드러난다."
    ]))

static func build_ch03_05_intro() -> CutsceneData:
    return _build_stage_text_cutscene(&"ch03_05_intro", "녹영숲 최심부 — 수지 제단.", PackedStringArray([
        "티아: 여기가 끝이자 시작이야. 숲의 거짓도 여기서 끝낸다.",
        "리안: 제단을 넘고 진실만 들고 나간다."
    ]))

static func build_ch03_05_outro() -> CutsceneData:
    return _build_stage_text_cutscene(&"ch03_05_outro", "", PackedStringArray([
        "티아: ...같이 가겠다. 끝까지 보고 싶어졌어.",
        "세린: 다음은 가라앉은 수도원이다."
    ]))

## CH04 stage cutscenes
static func build_ch04_01_intro() -> CutsceneData:
    return _build_stage_text_cutscene(&"ch04_01_intro", "가라앉은 수도원 — 침수된 회랑.", PackedStringArray([
        "세린: 여긴 원래 기도하던 곳이었어. 그런데 지금은 물과 침묵밖에 없어.",
        "리안: 물길이 바뀌기 전에 안쪽으로 간다."
    ]))

static func build_ch04_01_outro() -> CutsceneData:
    return _build_stage_text_cutscene(&"ch04_01_outro", "", PackedStringArray([
        "세린: 회랑은 열렸어. 종루 쪽으로 이어진다.",
        "리안: 기록도 그쪽에 남아 있을 가능성이 크다."
    ]))

static func build_ch04_02_intro() -> CutsceneData:
    return _build_stage_text_cutscene(&"ch04_02_intro", "가라앉은 수도원 — 잊힌 종루.", PackedStringArray([
        "세린: 이 종은 사람을 모으던 종이었어.",
        "리안: 지금은 다른 걸 깨우고 있다면, 그 근원을 본다."
    ]))

static func build_ch04_02_outro() -> CutsceneData:
    return _build_stage_text_cutscene(&"ch04_02_outro", "", PackedStringArray([
        "티아: 아래쪽 제어 시설로 길이 났어.",
        "세린: 수도원의 물길을 누가 바꿨는지 거기서 알 수 있을 거야."
    ]))

static func build_ch04_03_intro() -> CutsceneData:
    return _build_stage_text_cutscene(&"ch04_03_intro", "가라앉은 수도원 — 수문 제어실.", PackedStringArray([
        "리안: 수문만 맞추면 금고 쪽 압력이 풀린다.",
        "세린: 이게 기도실인지 실험실인지 이제 구분도 안 돼."
    ]))

static func build_ch04_03_outro() -> CutsceneData:
    return _build_stage_text_cutscene(&"ch04_03_outro", "", PackedStringArray([
        "세린: 성유물 금고에 들어갈 수 있게 됐어.",
        "리안: 그 안에 남은 기록이 다음 길을 정한다."
    ]))

static func build_ch04_04_intro() -> CutsceneData:
    return _build_stage_text_cutscene(&"ch04_04_intro", "가라앉은 수도원 — 성유물실.", PackedStringArray([
        "세린: 봉인을 복원해야 안쪽의 오염을 걷어낼 수 있어.",
        "리안: 마지막 제단으로 가는 길을 연다."
    ]))

static func build_ch04_04_outro() -> CutsceneData:
    return _build_stage_text_cutscene(&"ch04_04_outro", "", PackedStringArray([
        "세린: 봉인은 복원됐다. 이제 바실이 있는 제단만 남았어.",
        "리안: 수도원의 진실도 거기서 끝장을 본다."
    ]))

static func build_ch04_05_intro() -> CutsceneData:
    return _build_stage_text_cutscene(&"ch04_05_intro", "가라앉은 수도원 — 침수 제단.", PackedStringArray([
        "바실: 잊는 것이야말로 가장 빠른 구원이다.",
        "세린: 이름을 지우는 걸 자비라 부르지 마."
    ]))

static func build_ch04_05_outro() -> CutsceneData:
    return _build_stage_text_cutscene(&"ch04_05_outro", "", PackedStringArray([
        "세린: 믿음이 아니라 실험이었어... 그래도 난 여기서 물러서지 않겠어.",
        "리안: 다음 기록은 잿빛 기록보관소에 있다."
    ]))

## CH05 stage cutscenes
static func build_ch05_01_intro() -> CutsceneData:
    return _build_stage_text_cutscene(&"ch05_01_intro", "재의 서고 — 재의 관문.", PackedStringArray([
        "에녹: 안쪽 기록이 다 타기 전에 들어와야 한다.",
        "리안: 남은 장부가 있다면 진실도 아직 남아 있다."
    ]))

static func build_ch05_01_outro() -> CutsceneData:
    return _build_stage_text_cutscene(&"ch05_01_outro", "", PackedStringArray([
        "세린: 외곽문은 열렸다. 안쪽 서가로 간다.",
        "리안: 제로라는 이름의 흔적도 그 안에 있을지 모른다."
    ]))

static func build_ch05_02_intro() -> CutsceneData:
    return _build_stage_text_cutscene(&"ch05_02_intro", "재의 서고 — 금서 서가.", PackedStringArray([
        "에녹: 이 서가는 태운다고 끝나는 기록이 아니야. 지우려 든 흔적이 더 많지.",
        "리안: 그렇다면 그 흔적까지 전부 읽는다."
    ]))

static func build_ch05_02_outro() -> CutsceneData:
    return _build_stage_text_cutscene(&"ch05_02_outro", "", PackedStringArray([
        "에녹: 더 깊은 봉인 구역으로 길이 났다.",
        "세린: 불길보다 먼저 진실을 집어야 해."
    ]))

static func build_ch05_03_intro() -> CutsceneData:
    return _build_stage_text_cutscene(&"ch05_03_intro", "재의 서고 — 불타는 계단.", PackedStringArray([
        "세린: 위층이 무너지고 있어. 오래 버티지 못해.",
        "리안: 기록이 사라지기 전에 올라간다."
    ]))

static func build_ch05_03_outro() -> CutsceneData:
    return _build_stage_text_cutscene(&"ch05_03_outro", "", PackedStringArray([
        "에녹: 마지막 봉인실이 열릴 준비가 됐어.",
        "리안: 이제 제로의 이름을 직접 마주한다."
    ]))

static func build_ch05_04_intro() -> CutsceneData:
    return _build_stage_text_cutscene(&"ch05_04_intro", "재의 서고 — 진실 서가.", PackedStringArray([
        "에녹: 여기 적힌 이름을 보고도 널 같은 눈으로 볼 수 있을지 모르겠군.",
        "리안: 그래도 읽는다. 그게 여기까지 온 이유니까."
    ]))

static func build_ch05_04_outro() -> CutsceneData:
    return _build_stage_text_cutscene(&"ch05_04_outro", "", PackedStringArray([
        "세린: 제로... 결국 네 과거는 제국 한복판에 있었어.",
        "리안: 그럼 남은 답은 발토르에 있다."
    ]))

static func build_ch05_05_intro() -> CutsceneData:
    return _build_stage_text_cutscene(&"ch05_05_intro", "재의 서고 — 재의 탈출로.", PackedStringArray([
        "에녹: 난 기록을 숨긴 적은 있어도, 지우려 들진 않았다. 여기서 나가면 그 차이를 증명하자.",
        "리안: 함께 나온다면, 다음은 발토르다."
    ]))

static func build_ch05_05_outro() -> CutsceneData:
    return _build_stage_text_cutscene(&"ch05_05_outro", "", PackedStringArray([
        "에녹: 제로는 이름일 뿐이다. 그 이름으로 끝낼지, 다시 시작할지는 네 선택이야.",
        "세린: 다음은 철성 발토르. 거기서 또 다른 죄를 마주해야 해."
    ]))

## CH06_05 보스 스테이지 인트로
static func build_ch06_05_intro() -> CutsceneData:
    return _build_stage_text_cutscene(&"ch06_05_intro", "발토르 제단 — 발가르의 문.", PackedStringArray([
        "발가르: 쇠사슬은 배신하지 않는다. 이름도 의지도 모두 묶어 두면 된다.",
        "브란: 저 문 뒤가 요새의 명령핵이다. 오늘은 묶인 쪽이 아니라 끊는 쪽으로 선다.",
        "리안: 군수 기록과 감옥선, 봉인선까지 전부 여기로 이어졌다. 발가르를 꺾고 요새의 죄를 증언한다."
    ]))

## CH06_05 보스 스테이지 아웃트로
static func build_ch06_05_outro() -> CutsceneData:
    return _build_stage_text_cutscene(&"ch06_05_outro", "", PackedStringArray([
        "브란: 발토르의 쇠사슬은 끊겼다. 여기 남은 사람들은 더는 명령으로 묶이지 않아.",
        "세린: 요새의 기록도, 구출한 이름도 함께 들고 간다. 다음은 절차로 사람을 지우는 도시야."
    ]))

## CH07_05 보스 스테이지 인트로
static func build_ch07_05_intro() -> CutsceneData:
    return _build_stage_text_cutscene(&"ch07_05_intro", "엘리오르 성당 — 사리아의 기도단.", PackedStringArray([
        "사리아: 침묵은 질서다. 줄에서 벗어난 이름은 도시를 더럽힐 뿐이야.",
        "세린: 행선판, 명판, 증언까지 전부 네 기도단으로 이어졌어. 이제 줄이 아니라 사람을 본다.",
        "리안: 절차로 지워진 이름들을 되돌린다. 이 도시의 마지막 종을 멈춰."
    ]))

## CH07_05 보스 스테이지 아웃트로
static func build_ch07_05_outro() -> CutsceneData:
    return _build_stage_text_cutscene(&"ch07_05_outro", "", PackedStringArray([
        "세린: 기도단의 줄은 끊겼어. 광장에 남은 사람들도 자기 이름으로 말하기 시작했다.",
        "리안: 다음은 추격로다. 절차가 지운 이름을 쫓아온 사냥개를 멈춘다."
    ]))

## CH08_05 보스 스테이지 인트로
static func build_ch08_05_intro() -> CutsceneData:
    return _build_stage_text_cutscene(&"ch08_05_intro", "흑견 마당 — 레테의 마지막 추격로.", PackedStringArray([
        "레테: 달아난 이름은 냄새를 남긴다. 끝까지 쫓아가서 주인의 표식으로 돌려놓지.",
        "티아: 표식도 초소도 구금문도 네 사냥을 위해 놓인 덫이었어. 오늘은 네가 몰리는 쪽이다.",
        "리안: 추격선을 끊고 포로들을 내보낸다. 흑견의 마지막 명령은 여기서 끝난다."
    ]))

## CH08_05 보스 스테이지 아웃트로
static func build_ch08_05_outro() -> CutsceneData:
    return _build_stage_text_cutscene(&"ch08_05_outro", "", PackedStringArray([
        "티아: 이제 발자국이 도망친 흔적이 아니라 돌아갈 길이 됐어.",
        "세린: 흑견의 기록을 회수했다. 다음 선택은 서쪽 검열선과 동쪽 보관소로 갈린다."
    ]))

## CH09A_05 보스 스테이지 인트로
static func build_ch09a_05_intro() -> CutsceneData:
    return _build_stage_text_cutscene(&"ch09a_05_intro", "서쪽 분기 — 검열 안뜰.", PackedStringArray([
        "카일: 서판, 장부, 표식, 감방까지 전부 이 안뜰에서 다시 심문받게 되어 있다.",
        "검열관: 증언은 허가된 말만 남는다. 허가받지 못한 이름은 반역이다.",
        "리안: 허가가 아니라 증언으로 남긴다. 서쪽 검열선을 여기서 끝낸다."
    ]))

## CH09A_05 보스 스테이지 아웃트로
static func build_ch09a_05_outro() -> CutsceneData:
    return _build_stage_text_cutscene(&"ch09a_05_outro", "", PackedStringArray([
        "카일: 검열 안뜰은 무너졌다. 군기가 남긴 기준도 더는 사람을 재단하지 못해.",
        "세린: 서쪽 증언을 확보했어. 이제 심연 중심부에서 동쪽 기록과 맞물릴 답을 찾아야 해."
    ]))

## CH09B_05 보스 스테이지 인트로
static func build_ch09b_05_intro() -> CutsceneData:
    return _build_stage_text_cutscene(&"ch09b_05_intro", "동쪽 분기 — 멜키온의 심연 색인.", PackedStringArray([
        "멜키온: 기록은 살아남은 자의 편집본일 뿐이다. 내가 지운 이름은 처음부터 없었던 이름이 된다.",
        "노아: 봉인, 삭제 서가, 기억 격자, 개정 핵까지 전부 네 손글씨였어. 이제 원본을 돌려받는다.",
        "리안: 지워진 칸을 빈칸으로 두지 않는다. 동쪽 기록선을 여기서 되찾는다."
    ]))

## CH09B_05 보스 스테이지 아웃트로
static func build_ch09b_05_outro() -> CutsceneData:
    return _build_stage_text_cutscene(&"ch09b_05_outro", "", PackedStringArray([
        "노아: 개정된 기록 아래 원본이 남아 있었어. 사라진 이름들도 다시 색인에 붙었다.",
        "리안: 동쪽 기록을 확보했다. 이제 무명의 탑에서 서쪽 증언과 하나로 맞춘다."
    ]))

## CH10_05 최종 보스 스테이지 인트로 (클리어 컷씬은 캠페인 엔딩 플로우 담당)
static func build_ch10_05_intro() -> CutsceneData:
    var d: CutsceneData = CutsceneData.new()
    d.cutscene_id = &"ch10_05_intro"
    d.skippable = false
    d.beats = [
        {
            "type": "black_screen",
            "text": "종탑 최상층 — 마지막 이름.",
            "duration": 2.5
        },
        {
            "type": "text_card",
            "text": "리안: 기억이 돌아왔다. 이름도 함께 돌아왔다.",
            "duration": 3.5
        },
        {
            "type": "text_card",
            "text": "카르온: 이름을 되찾았다고 해서, 모든 것이 끝나는 건 아니다.",
            "duration": 3.0
        }
    ]
    return d

static func build_ch10_normal_resolution_cinematic() -> CutsceneData:
    var d: CutsceneData = CutsceneData.new()
    d.cutscene_id = &"ch10_normal_resolution_cinematic"
    d.skippable = true
    d.beats = [
        {
            "type": "black_screen",
            "header": "ENDING / NORMAL",
            "mood": "잔향 격리",
            "text": "무명의 탑 — 종이 멈춘 직후. 하지만 마지막 공명은 아직 리안의 몸에 남아 있다.",
            "duration": 2.0,
            "background_color": Color(0.03, 0.02, 0.02, 0.94),
            "header_color": Color(0.97, 0.82, 0.63, 0.92),
            "meta_color": Color(0.86, 0.73, 0.56, 0.9)
        },
        {
            "type": "text_card",
            "header": "PHASE 01 / LAST BURDEN",
            "speaker": "리안",
            "mood": "희생 수락",
            "text": "아직 끝난 게 아니야. 종이 받아야 할 기억의 부하가 남았어. 내가 대신 안고 내려갈게.",
            "duration": 3.2,
            "background_color": Color(0.05, 0.03, 0.02, 0.94),
            "header_color": Color(1.0, 0.86, 0.67, 0.94),
            "meta_color": Color(0.96, 0.82, 0.63, 0.92)
        },
        {
            "type": "text_card",
            "header": "PHASE 01 / NAME EROSION",
            "speaker": "세린",
            "mood": "경고",
            "text": "그건 내려가는 게 아니야. 네 얼굴과 이름부터 먼저 지워질 거야. 우리를 살리려고 너 혼자 사라지겠다는 말이잖아.",
            "duration": 3.2,
            "background_color": Color(0.06, 0.03, 0.02, 0.94),
            "header_color": Color(0.98, 0.78, 0.62, 0.94),
            "meta_color": Color(0.96, 0.80, 0.64, 0.92)
        },
        {
            "type": "text_card",
            "header": "PHASE 02 / MEMORY HANDOFF",
            "speaker": "리안",
            "mood": "유언 대신 인계",
            "text": "그래도 너희는 남아. 누가 무엇을 남길지는 이제 우리가 정한다. 내가 잊더라도, 너희가 여기서 다음 이름을 이어 줘.",
            "duration": 3.2,
            "background_color": Color(0.06, 0.04, 0.03, 0.94),
            "header_color": Color(0.98, 0.83, 0.67, 0.94),
            "meta_color": Color(0.94, 0.84, 0.70, 0.92)
        },
        {
            "type": "text_card",
            "header": "PHASE 03 / BELL RESIDUE",
            "speaker": "내레이션",
            "mood": "잔향 봉합",
            "text": "리안은 무너진 종핵에 손을 얹고 마지막 공명을 혼자 끌어안는다. 빛이 꺼질수록 동료들의 얼굴과 이름이 그의 시야에서 한 겹씩 흐려진다.",
            "duration": 3.2,
            "background_color": Color(0.07, 0.04, 0.03, 0.94),
            "header_color": Color(0.94, 0.76, 0.56, 0.94),
            "meta_color": Color(0.90, 0.72, 0.58, 0.92)
        },
        {
            "type": "text_card",
            "header": "PHASE 04 / WITNESS KEEP",
            "speaker": "세린",
            "mood": "증언 유지",
            "text": "잊지 마, 리안. 네가 우리를 살렸다는 것만은 내가 끝까지 기억할게. 네 빈자리는 우리가 대신 증언할 거야.",
            "duration": 3.1,
            "background_color": Color(0.06, 0.04, 0.03, 0.94),
            "header_color": Color(0.96, 0.84, 0.70, 0.94),
            "meta_color": Color(0.92, 0.82, 0.72, 0.92)
        }
    ]
    return d

static func build_ch10_true_resolution_cinematic() -> CutsceneData:
    var d: CutsceneData = CutsceneData.new()
    d.cutscene_id = &"ch10_true_resolution_cinematic"
    d.skippable = true
    d.beats = [
        {
            "type": "black_screen",
            "header": "ENDING / TRUE",
            "mood": "공명 안정화",
            "text": "무명의 탑 — 마지막 공명이 가라앉은 뒤. 이번엔 누구도 지워지지 않았어.",
            "duration": 2.0,
            "background_color": Color(0.01, 0.04, 0.08, 0.94),
            "header_color": Color(0.78, 0.90, 1.0, 0.96),
            "meta_color": Color(0.68, 0.82, 0.98, 0.92)
        },
        {
            "type": "text_card",
            "header": "PHASE 01 / ALL NAMES REMAIN",
            "speaker": "리안",
            "mood": "공동 결말 선언",
            "text": "아무도 지워지지 않았어. 그래서 이 결말은 한 사람의 구원이 아니라, 우리가 끝까지 붙든 이름들의 결말이야.",
            "duration": 3.2,
            "background_color": Color(0.02, 0.05, 0.09, 0.94),
            "header_color": Color(0.76, 0.90, 1.0, 0.96),
            "meta_color": Color(0.72, 0.86, 1.0, 0.94)
        },
        {
            "type": "text_card",
            "header": "PHASE 02 / SHARED WITNESS",
            "speaker": "브란",
            "mood": "공동 증언",
            "text": "무너진 벽 대신 끝까지 남은 인연이 새 기준이 된다. 이제부터는 우리가 서로의 증언이 된다.",
            "duration": 3.0,
            "background_color": Color(0.02, 0.06, 0.10, 0.94),
            "header_color": Color(0.74, 0.88, 0.98, 0.96),
            "meta_color": Color(0.68, 0.82, 0.96, 0.94)
        },
        {
            "type": "text_card",
            "header": "PHASE 03 / NAME HANDOFF",
            "speaker": "노아",
            "mood": "인계 선언",
            "text": "마지막 기억은 봉인이 아니라 인계가 되었다. 모든 이름은 다음 사람에게 건네진다. 기록은 사람을 지우는 대신 서로를 남기는 방식으로 이어진다.",
            "duration": 3.0,
            "background_color": Color(0.03, 0.06, 0.11, 0.94),
            "header_color": Color(0.82, 0.94, 1.0, 0.98),
            "meta_color": Color(0.78, 0.90, 0.99, 0.94)
        },
        {
            "type": "text_card",
            "header": "PHASE 04 / FIRST SENTENCE",
            "speaker": "내레이션",
            "mood": "새 시대 개시",
            "text": "탑 바깥으로 나온 동료들은 각자의 이름을 잃지 않은 채 다시 행군을 시작하고, 그 이름들이 다음 시대의 첫 문장이 된다.",
            "duration": 3.2,
            "background_color": Color(0.04, 0.08, 0.12, 0.94),
            "header_color": Color(0.84, 0.95, 1.0, 0.98),
            "meta_color": Color(0.76, 0.90, 0.99, 0.94)
        }
    ]
    return d

static func build_ch10_true_companion_scene() -> CutsceneData:
    var d: CutsceneData = CutsceneData.new()
    d.cutscene_id = &"ch10_true_companion_scene"
    d.skippable = true
    d.beats = [
        {
            "type": "black_screen",
            "header": "TRUE ENDING / COMPANION ROLL",
            "mood": "공동 귀환",
            "text": "무명의 탑 아래 — 함께 내려가는 길. 이번 결말은 한 사람의 퇴장이 아니라 동료들이 같은 이름으로 서는 장면이다.",
            "duration": 2.0,
            "background_color": Color(0.02, 0.04, 0.07, 0.94),
            "header_color": Color(0.82, 0.94, 1.0, 0.98),
            "meta_color": Color(0.76, 0.88, 0.99, 0.94)
        },
        {
            "type": "text_card",
            "header": "COMPANION / FORM UP",
            "speaker": "세린",
            "mood": "행군 개시",
            "text": "이제 내려가자. 이번에는 우리 전부의 이름으로. 누구 하나 뒤에 남겨 두지 않고, 같은 보폭으로.",
            "duration": 3.0,
            "background_color": Color(0.02, 0.05, 0.08, 0.94),
            "header_color": Color(0.78, 0.92, 1.0, 0.98),
            "meta_color": Color(0.74, 0.88, 1.0, 0.94)
        },
        {
            "type": "text_card",
            "header": "COMPANION / SHIELD LINE",
            "speaker": "브란",
            "mood": "측면 보호",
            "text": "방패는 이제 뒤가 아니라 옆에 선 사람들을 위해 든다. 살아남은 이름들이 서로의 측면을 맡으면, 무너진 벽도 다시 세울 수 있다.",
            "duration": 3.0,
            "background_color": Color(0.02, 0.05, 0.09, 0.94),
            "header_color": Color(0.76, 0.90, 0.98, 0.98),
            "meta_color": Color(0.70, 0.84, 0.96, 0.94)
        },
        {
            "type": "text_card",
            "header": "COMPANION / WOODS RETURN",
            "speaker": "티아",
            "mood": "불안 해소",
            "text": "숲에서 건져 낸 이름도, 도시에서 되찾은 이름도 여기 같이 있네. 그러면 다음 길은 무섭기만 하진 않아.",
            "duration": 3.0,
            "background_color": Color(0.03, 0.06, 0.09, 0.94),
            "header_color": Color(0.78, 0.90, 0.98, 0.98),
            "meta_color": Color(0.74, 0.86, 0.96, 0.94)
        },
        {
            "type": "text_card",
            "header": "COMPANION / RECORD CHECK",
            "speaker": "에녹",
            "mood": "기록 재정의",
            "text": "기록은 오늘부터 사람을 정리하는 장부가 아니라 동료를 확인하는 목록이 된다. 빠진 이름이 없는지 내가 먼저 볼게.",
            "duration": 3.0,
            "background_color": Color(0.03, 0.07, 0.10, 0.94),
            "header_color": Color(0.80, 0.92, 0.99, 0.98),
            "meta_color": Color(0.74, 0.88, 0.98, 0.94)
        },
        {
            "type": "text_card",
            "header": "COMPANION / MARCH ORDER",
            "speaker": "카일",
            "mood": "열 재정렬",
            "text": "행군 기준은 다시 세우면 된다. 앞줄도 뒷줄도 없이, 끝까지 같이 선 사람들부터 맞춰 나가자.",
            "duration": 3.0,
            "background_color": Color(0.03, 0.06, 0.10, 0.94),
            "header_color": Color(0.78, 0.91, 0.99, 0.98),
            "meta_color": Color(0.72, 0.86, 0.97, 0.94)
        },
        {
            "type": "text_card",
            "header": "COMPANION / FIRST PARAGRAPH",
            "speaker": "노아",
            "mood": "공동 서문",
            "text": "좋아. 그럼 이건 탑의 마지막 문장이 아니라 우리 여섯이 함께 적는 첫 문단이야. 다음 시대는 여기서부터 서로의 이름으로 이어진다.",
            "duration": 3.2,
            "background_color": Color(0.04, 0.08, 0.12, 0.94),
            "header_color": Color(0.84, 0.96, 1.0, 0.98),
            "meta_color": Color(0.80, 0.92, 1.0, 0.96)
        }
    ]
    return d

## ID로 컷씬 조회
static func get_cutscene(cutscene_id: StringName) -> CutsceneData:
    if STAGE_TEXT_CUTSCENES.has(cutscene_id):
        var spec: Dictionary = STAGE_TEXT_CUTSCENES.get(cutscene_id, {})
        return _build_stage_text_cutscene(
            cutscene_id,
            String(spec.get("header", "")),
            PackedStringArray(spec.get("lines", [])),
            bool(spec.get("skippable", true))
        )
    if HUNT_TEXT_CUTSCENES.has(cutscene_id):
        var hunt_spec: Dictionary = HUNT_TEXT_CUTSCENES.get(cutscene_id, {})
        return _build_stage_text_cutscene(
            cutscene_id,
            String(hunt_spec.get("header", "")),
            PackedStringArray(hunt_spec.get("lines", [])),
            bool(hunt_spec.get("skippable", true))
        )
    match cutscene_id:
        &"ch01_start":
            return build_ch01_start()
        &"ch01_clear":
            return build_ch01_clear()
        &"ch01_fragment_flash":
            return build_ch01_fragment_flash()
        &"ch02_01_intro":
            return build_ch02_01_intro()
        &"ch02_01_outro":
            return build_ch02_01_outro()
        &"ch02_02_intro":
            return build_ch02_02_intro()
        &"ch02_02_outro":
            return build_ch02_02_outro()
        &"ch02_03_intro":
            return build_ch02_03_intro()
        &"ch02_03_outro":
            return build_ch02_03_outro()
        &"ch02_04_intro":
            return build_ch02_04_intro()
        &"ch02_04_outro":
            return build_ch02_04_outro()
        &"ch02_05_intro":
            return build_ch02_05_intro()
        &"ch02_05_outro":
            return build_ch02_05_outro()
        &"ch03_01_intro":
            return build_ch03_01_intro()
        &"ch03_01_outro":
            return build_ch03_01_outro()
        &"ch03_02_intro":
            return build_ch03_02_intro()
        &"ch03_02_outro":
            return build_ch03_02_outro()
        &"ch03_03_intro":
            return build_ch03_03_intro()
        &"ch03_03_outro":
            return build_ch03_03_outro()
        &"ch03_04_intro":
            return build_ch03_04_intro()
        &"ch03_04_outro":
            return build_ch03_04_outro()
        &"ch03_05_intro":
            return build_ch03_05_intro()
        &"ch03_05_outro":
            return build_ch03_05_outro()
        &"ch04_01_intro":
            return build_ch04_01_intro()
        &"ch04_01_outro":
            return build_ch04_01_outro()
        &"ch04_02_intro":
            return build_ch04_02_intro()
        &"ch04_02_outro":
            return build_ch04_02_outro()
        &"ch04_03_intro":
            return build_ch04_03_intro()
        &"ch04_03_outro":
            return build_ch04_03_outro()
        &"ch04_04_intro":
            return build_ch04_04_intro()
        &"ch04_04_outro":
            return build_ch04_04_outro()
        &"ch04_05_intro":
            return build_ch04_05_intro()
        &"ch04_05_outro":
            return build_ch04_05_outro()
        &"ch05_01_intro":
            return build_ch05_01_intro()
        &"ch05_01_outro":
            return build_ch05_01_outro()
        &"ch05_02_intro":
            return build_ch05_02_intro()
        &"ch05_02_outro":
            return build_ch05_02_outro()
        &"ch05_03_intro":
            return build_ch05_03_intro()
        &"ch05_03_outro":
            return build_ch05_03_outro()
        &"ch05_04_intro":
            return build_ch05_04_intro()
        &"ch05_04_outro":
            return build_ch05_04_outro()
        &"ch05_05_intro":
            return build_ch05_05_intro()
        &"ch05_05_outro":
            return build_ch05_05_outro()
        &"ch06_05_intro":
            return build_ch06_05_intro()
        &"ch06_05_outro":
            return build_ch06_05_outro()
        &"ch07_05_intro":
            return build_ch07_05_intro()
        &"ch07_05_outro":
            return build_ch07_05_outro()
        &"ch08_05_intro":
            return build_ch08_05_intro()
        &"ch08_05_outro":
            return build_ch08_05_outro()
        &"ch09a_05_intro":
            return build_ch09a_05_intro()
        &"ch09a_05_outro":
            return build_ch09a_05_outro()
        &"ch09b_05_intro":
            return build_ch09b_05_intro()
        &"ch09b_05_outro":
            return build_ch09b_05_outro()
        &"ch10_05_intro":
            return build_ch10_05_intro()
        &"ch10_normal_resolution_cinematic":
            return build_ch10_normal_resolution_cinematic()
        &"ch10_true_resolution_cinematic":
            return build_ch10_true_resolution_cinematic()
        &"ch10_true_companion_scene":
            return build_ch10_true_companion_scene()
        _:
            return null
