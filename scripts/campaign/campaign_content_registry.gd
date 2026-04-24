class_name CampaignContentRegistry
extends RefCounted

# ---------------------------------------------------------------------------
# Stage Reward Logs  (narrative reward text shown after each stage)
# ---------------------------------------------------------------------------

const CH01_STAGE_REWARD_LOG: Dictionary = {
    &"CH01_02": [
        "잿빛 들판 보급 기록: 생존자 대열을 위한 야전 식량 꾸러미를 확보했다."
    ],
    &"CH01_03": [
        "폐허 우물 조사 기록: 북쪽 성문 진입로로 이어지는 경로 메모를 회수했다."
    ],
    &"CH01_04": [
        "북문 중계 기록: 새벽 맹세 돌입에 필요한 돌파 타이밍 메모를 확보했다."
    ],
    &"CH01_05": [
        "새벽 맹세 인계 기록: 세린이 캠프 교대 구간의 정식 동료로 고정되었다."
    ]
}

const CH02_STAGE_REWARD_LOG: Dictionary = {
    &"CH02_01": [
        "민병대 인장 확보: 민병대 문장과 함께 장신구 루트가 열린다."
    ],
    &"CH02_02": [
        "외벽 보급 기록: 성벽 측면에서 강철 못과 응급약을 회수했다."
    ],
    &"CH02_03": [
        "잔존 기사 인계 기록: 브란이 전열에 합류하고 부서진 대장 인장이 등록되었다."
    ],
    &"CH02_04": [
        "철문 제어 기록: 터널 장부에 문지기 반지 루트가 표시되었다."
    ],
    &"CH02_05": [
        "하드렌 군기 회수: 요새 인계용 하드렌 철문장이 확보되었다."
    ]
}

const CH03_STAGE_REWARD_LOG: Dictionary = {
    &"CH03_01": [
        "녹림 경로 기록: 첫 숲 보급품과 함께 그린우드 깃털 길이 열린다."
    ],
    &"CH03_02": [
        "덫선 보급 기록: 사냥꾼 바늘길이 장부에 표시되었다."
    ],
    &"CH03_03": [
        "난민 호위 기록: 하단 산길용 벌목꾼 망토 루트를 확보했다."
    ],
    &"CH03_04": [
        "수지 결계 기록: 송진 부적 루트가 산불 지대 장부에 등록되었다."
    ],
    &"CH03_05": [
        "그린우드 사냥 인계 기록: 티아가 합류했고 첫 보스 무기를 확보했으며, 이후 수렵 게시판 루트가 열린다."
    ]
}

const CH04_STAGE_REWARD_LOG: Dictionary = {
    &"CH04_01": [
        "침수 회랑 보급 기록: 수도원 첫 보급 흔적을 확보했다."
    ],
    &"CH04_02": [
        "종탑 보급 기록: 봉인된 종 파편 루트가 드러났다."
    ],
    &"CH04_03": [
        "수문 제어 기록: 방수 예복 루트를 확보했다."
    ],
    &"CH04_04": [
        "성유물실 정화 기록: 성화 목걸이 루트가 드러났다."
    ],
    &"CH04_05": [
        "침수 제단 인계 기록: 바실이 쓰러졌고 첫 랜덤 보스 무기 루트가 이후 열리며, 수도원 기록이 확보되었다."
    ]
}

const CH05_STAGE_REWARD_LOG: Dictionary = {
    &"CH05_01": [
        "재의 관문 보급 기록: 기록보관소 외곽 루트를 확보했다."
    ],
    &"CH05_02": [
        "금서 서가 보급 기록: 첫 봉인 서가에서 잿빛 책갈피를 회수했다."
    ],
    &"CH05_03": [
        "불타는 계단 보급 기록: 재길 돌파용 내열 기록관 코트를 확보했다."
    ],
    &"CH05_04": [
        "진실 서가 봉인 기록: 첫 개정 기록 증거와 함께 제로 흔적 문서를 확보했다."
    ],
    &"CH05_05": [
        "잿빛 기록보관소 인계 기록: 에녹이 합류했고, 이후 분해 기능이 열리며 발토르로 향하는 길이 확보되었다."
    ]
}

const CH06_STAGE_REWARD_LOG: Dictionary = {
    &"CH06_01": [
        "전방 포열선 보급 기록: 발토르 진입 경로를 확보했다."
    ],
    &"CH06_02": [
        "포대선 보급 기록: 요새 포병대에서 포술 조준기를 회수했다."
    ],
    &"CH06_03": [
        "군수 심층부 보급 기록: 군수 저장고 심층에서 발토르 지휘 흉갑을 확보했다."
    ],
    &"CH06_04": [
        "맹세 전당 제어 기록: 내부 장부 금고에서 맹세 반지를 확보했다."
    ],
    &"CH06_05": [
        "발토르 인계 기록: 발가르가 쓰러졌고 엘리오르 구호 명령서를 확보했으며, 이후 대장간 접근이 열린다."
    ]
}

const CH07_STAGE_REWARD_LOG: Dictionary = {
    &"CH07_01": [
        "시장 경로 기록: 엘리오르 첫 구조 동선을 확보했다."
    ],
    &"CH07_02": [
        "침묵 광장 보급 기록: 감시초소에서 기억의 종을 회수했다."
    ],
    &"CH07_03": [
        "행렬 붕괴 기록: 미라와 네리를 무명 행렬에서 끌어냈고, 엘리오르 행렬 갑옷을 확보했다."
    ],
    &"CH07_04": [
        "성당 수로 기록: 찬가 수로 성유물함에서 매듭 부적을 확보했다."
    ],
    &"CH07_05": [
        "엘리오르 인계 기록: 사리아가 쓰러졌고 사리아의 자비 지팡이와 이름결 실을 확보했으며, 이후 문장 조율이 열리고 흑견 경로가 확보되었다."
    ]
}

const CH08_STAGE_REWARD_LOG: Dictionary = {
    &"CH08_01": [
        "소실된 숲길 보급 기록: 첫 흑견 추적 경로를 확보했다."
    ],
    &"CH08_02": [
        "매복 보급 기록: 분기 사냥길에서 월광 추적 인장을 회수했다."
    ],
    &"CH08_03": [
        "폐허 배기 기록: 하층 구금실에서 폐허 수호 부적과 폐허 추적 코트를 확보했다."
    ],
    &"CH08_04": [
        "흑표식 제어 기록: 폐허 제어 각인에서 흑견 송곳니 표식과 흑견선 활을 확보했다."
    ],
    &"CH08_05": [
        "흑견 인계 기록: 레테가 쓰러졌고 숨은 폐허의 진실이 드러났으며, 추격은 카일의 외곽선으로 향한다."
    ]
}

const CH09A_STAGE_REWARD_LOG: Dictionary = {
    &"CH09A_01": [
        "외곽선 보급 기록: 수도 첫 검문 경로를 확보했다."
    ],
    &"CH09A_02": [
        "교량 보급 기록: 카일의 교량 검문지에서 군기 고리를 확보했다."
    ],
    &"CH09A_03": [
        "맹세 전당 보급 기록: 맹세 전당 내부에서 무명 감시 배지를 확보했다."
    ],
    &"CH09A_04": [
        "구금동 보급 기록: 구금 장부에서 장교 구조 암호와 수도 증언패를 확보했다."
    ],
    &"CH09A_05": [
        "부서진 군기 인계 기록: 카일이 합류했고 군기 파쇄검과 근원 접근 봉인을 확보했으며, 내부 기록보관소 길이 열린다."
    ]
}

const CH09B_STAGE_REWARD_LOG: Dictionary = {
    &"CH09B_01": [
        "근원 관문 보급 기록: 첫 기록 핵심 경로를 확보했다."
    ],
    &"CH09B_02": [
        "삭제 서가 보급 기록: 첫 개정 서가에서 개정 수호 핀을 확보했다."
    ],
    &"CH09B_03": [
        "마지막 보관인 인계 기록: 노아가 합류했고 보관 실 봉인을 확보했으며, 노아의 근원 지팡이를 되찾았다."
    ],
    &"CH09B_04": [
        "개정 핵 기록: 개정 핵 내부에서 기록 증거 중계기와 개정 수호 망토를 확보했다."
    ],
    &"CH09B_05": [
        "심연 인계 기록: 멜키온이 쓰러졌고 마지막 기억이 복원되었으며, 식경 좌표를 확보했다."
    ]
}

const CH10_STAGE_REWARD_LOG: Dictionary = {
    &"CH10_01": [
        "식경 전야 보급 기록: 첫 탑 보급 경로를 확보했다."
    ],
    &"CH10_02": [
        "탑 문장 보급 기록: 탑 문장 중계지에서 공명 매듭을 확보했다."
    ],
    &"CH10_03": [
        "무명의 회랑 보급 기록: 무명의 회랑에서 탑 수호 인장과 종수호 판을 확보했다."
    ],
    &"CH10_04": [
        "왕의 전당 인계 기록: 종의 맹세 유물과 식경 공명검을 확보했고, 카르온의 첫 단계가 무너졌으며, 종의 방이 열린다."
    ],
    &"CH10_05": [
        "최종 결말 기록: 카르온이 쓰러졌고 종은 침묵했으며, 결말 상태가 확정되었다."
    ]
}

# ---------------------------------------------------------------------------
# Stage Cutscene Notes
# ---------------------------------------------------------------------------

const CH01_STAGE_CUTSCENE_NOTES: Dictionary = {
    &"CH01_02": [
        "세린은 리안이 떠도는 생존자가 아니라 retreat officer처럼 민간인을 정렬했다는 사실을 눈치챈다.",
        "호위 동선은 동쪽으로 꺾이고, Ruined Well이 다음 안전 지점이 된다."
    ],
    &"CH01_03": [
        "폐허 우물에서 리안은 물자와 보급, 배치를 지시하던 cold command voice를 듣는다.",
        "기억의 파문은 North Gate 진입로를 가리킨다."
    ],
    &"CH01_04": [
        "세린은 리안이 어떻게 weak point of the gate를 그토록 빨리 읽어냈는지 추궁한다.",
        "돌파구는 Dawn Oath가 기다리는 길을 연다."
    ]
}

const CH02_STAGE_CUTSCENE_NOTES: Dictionary = {
    &"CH02_01": [
        "연막선이 간신히 갈라지며 부대는 하드렌 외벽을 확인한다.",
        "신호탑 보급품은 요새 안쪽에 더 강한 장비가 남아 있음을 암시한다."
    ],
    &"CH02_02": [
        "외벽 붕괴는 고립된 기사들과 요새 내부로 향하는 더 좁은 길을 드러낸다.",
        "리안은 각도를 지나치게 빨리 읽어내고, 브란의 의심은 더 날카로워진다."
    ],
    &"CH02_03": [
        "브란과 리안은 마침내 같은 전선에 서고, 잔존 기사들은 그 틈에 재정비한다.",
        "철문 아래의 터널 제어 장치만이 남은 유일한 길이 된다."
    ],
    &"CH02_04": [
        "터널 레버가 차례대로 반응하며 하드렌 군기 전당으로 가는 마지막 길을 연다.",
        "리안은 설명할 수 없는 방식으로 이 요새를 낯익게 느낀다."
    ]
}

const CH03_STAGE_CUTSCENE_NOTES: Dictionary = {
    &"CH03_01": [
        "잃어버린 숲은 사냥꾼의 영역으로 좁아지고, 모든 길이 감시받는 듯하다.",
        "첫 보급함은 누군가가 생존자들을 비밀리에 그린우드로 이동시켜 왔음을 보여 준다."
    ],
    &"CH03_02": [
        "덫선은 조여 오고, 티아의 보이지 않는 사격은 그녀가 입을 열기도 전에 부대를 읽기 시작한다.",
        "난민 길은 남쪽으로 꺾이지만, 숲 자체는 더 큰 화공 계획을 가리킨다."
    ],
    &"CH03_03": [
        "대열은 살아남았지만 가장 안전한 길은 사라졌고, 이제 송진 분지 길만 남았다.",
        "티아는 부대를 단순한 침입자가 아닌 더 복잡한 존재로 보기 시작한다."
    ],
    &"CH03_04": [
        "불탄 흔적과 꺼진 봉화는 숲 화재가 우연이 아니라 계획이었음을 드러낸다.",
        "마지막 사당 길은 사냥 제단으로 곧장 이어진다."
    ]
}

const CH04_STAGE_CUTSCENE_NOTES: Dictionary = {
    &"CH04_01": [
        "수도원 입구는 절반이 잠겨 있고, 안전한 길은 모두 움직이는 수면선에 달려 있다.",
        "세린은 이 회랑을 성지가 아니라 처리 시설로 뒤틀린 장소로 알아본다."
    ],
    &"CH04_02": [
        "종탑은 더 이상 예배자를 부르지 않는다. 시야를 열고 기억을 흔들어 놓을 뿐이다.",
        "오래된 수문 기록은 아래쪽 제어 시설을 가리킨다."
    ],
    &"CH04_03": [
        "수문 제어 장치는 사원 기계가 아니라 실험실 장비처럼 반응한다.",
        "안정된 수압은 성유물 금고로 가는 길을 연다."
    ],
    &"CH04_04": [
        "마지막 성소를 정화하면서 수도원이 기도만이 아니라 기억 자체를 관리해 왔음이 드러난다.",
        "마지막 봉인 경로는 바실의 침수 제단으로 이어진다."
    ]
}

const CH05_STAGE_CUTSCENE_NOTES: Dictionary = {
    &"CH05_01": [
        "기록보관소는 바깥에서 안으로 타들어가며 증거 자체를 재로 바꾼다.",
        "반쯤 탄 장부는 몸보다 이름이 먼저 사라지고 있음을 보여 준다."
    ],
    &"CH05_02": [
        "움직이는 서가와 봉인된 줄은 이 길이 단순히 무너진 것이 아니라 의도적으로 편집되었다는 느낌을 준다.",
        "부대가 깊이 들어갈수록 기록보관소는 우연한 붕괴가 아니라 의도된 삭제로 보인다."
    ],
    &"CH05_03": [
        "상층부는 무너지고 있고, 부대는 불길과 좁아지는 길을 뚫고 올라가야 한다.",
        "살아남은 모든 기록은 우연히 남은 것이 아니라 선택된 것처럼 느껴진다."
    ],
    &"CH05_04": [
        "마지막 봉인이 열리고, 에녹은 처음으로 제로의 이름을 입 밖에 낸다.",
        "기록들은 같은 명령 위에 덧씌워진 수정 흔적과 붉은 주석을 보여 준다."
    ]
}

const CH06_STAGE_CUTSCENE_NOTES: Dictionary = {
    &"CH06_01": [
        "외곽 연무가 걷히자, 성벽에 닿기도 전에 공격자를 부러뜨리도록 설계된 요새 진입로가 드러난다.",
        "브란은 이 전선을 수비자의 시선으로 읽고, 리안은 한때 그것을 무너뜨린 자의 시선으로 읽는다."
    ],
    &"CH06_02": [
        "포대는 여전히 공성의 계산과 계획된 희생의 언어로 말하고 있다.",
        "포열선 하나를 해체할 때마다 내부 성채로 향하는 또 다른 길이 열린다."
    ],
    &"CH06_03": [
        "감옥 심층부는 생존 기사, 군수 경로, 그리고 엘리오르로 향하는 첫 분명한 흔적을 드러낸다.",
        "보급실조차 사람을 요새의 부속품으로 환원한 기록처럼 느껴진다."
    ],
    &"CH06_04": [
        "맹세 전당은 발토르를 안쪽에서 무너뜨린 계획을 아직 기억하고 있다.",
        "붉은 주석은 최초 경로가 그려진 뒤 가장 끔찍한 시점이 뒤늦게 덧씌워졌음을 증명한다."
    ]
}

const CH07_STAGE_CUTSCENE_NOTES: Dictionary = {
    &"CH07_01": [
        "시장은 사람들이 강요받을 뿐 아니라 스스로 망각을 선택하고 있음을 증명한다.",
        "미라와 네리는 이 교리가 현실의 얼굴을 갖고 있음을 처음으로 보여 주는 인물들로 다시 나타난다."
    ],
    &"CH07_02": [
        "대기열 시스템은 질서정연하고 조용하며, 소름 끼칠 만큼 설득력 있다.",
        "브란은 같은 약속을 들었다면 군인들 역시 그 줄에 섰을 것임을 깨닫는다."
    ],
    &"CH07_03": [
        "무명 행렬은 무너지지만, 그것은 부대가 사람들을 직접 의식장에서 떼어 놓은 뒤에야 가능해진다.",
        "세린은 사리아의 논리를 이해하지만 받아들이지는 않는다."
    ],
    &"CH07_04": [
        "성당 수로는 자비로 포장된 기계처럼 찬가를 실어 나른다.",
        "설교의 힘이 약해지자 사리아의 기도실로 들어가는 마지막 길이 열린다."
    ]
}

const CH08_STAGE_CUTSCENE_NOTES: Dictionary = {
    &"CH08_01": [
        "숲은 더 이상 단순한 지형이 아니다. 사냥 격자로 다시 쓰여 있다.",
        "첫 추적 흔적은 흑견이 사람 자체를 지도에서 지워내고 있음을 보여 준다."
    ],
    &"CH08_02": [
        "달빛 매복선은 부대를 갈라놓고 홀로 떨어진 자를 처벌한다.",
        "티아는 그 패턴을 숲의 감각을 훔쳐 교리로 바꾼 것으로 알아본다."
    ],
    &"CH08_03": [
        "하층 폐허는 피난처가 아니라 수용 구역의 냄새를 풍긴다.",
        "경로 하나를 회수할 때마다 티아의 희망과 공포는 동시에 더 날카로워진다."
    ],
    &"CH08_04": [
        "제어 표식은 포획 명령과 이후 수정이 같은 작전 위에 겹쳐 있다는 사실을 드러낸다.",
        "마지막 신호 경로는 레테의 사냥터로 곧장 열린다."
    ]
}

const CH09A_STAGE_CUTSCENE_NOTES: Dictionary = {
    &"CH09A_01": [
        "수도 외곽선은 증언이 도시 안으로 들어오기 전에 끊어 내도록 설계되어 있다.",
        "카일은 여전히 그 전선을 의무로 대하지만, 이제 모든 명령은 삭제의 냄새를 풍긴다."
    ],
    &"CH09A_02": [
        "교량 전선은 카일이 아직도 지워내지 못한 누군가에게서 전열을 배웠음을 증명한다.",
        "카일의 충성에 생긴 첫 균열은 그 전선이 사람보다 절차를 지키고 있음을 목격한 순간부터 시작된다."
    ],
    &"CH09A_03": [
        "무명의 맹세 전당은 지친 병사들을 역사 밖으로 처리될 증거물로 바꿔 놓는다.",
        "구호처럼 보였던 것은 질서정연한 소거로 밝혀진다."
    ],
    &"CH09A_04": [
        "버려진 장교들은 더 이상 구할 동료가 아니라 지워야 할 증인이 된다.",
        "카일은 자신의 지휘 체계가 소모 가능한 증거로 재분류되는 광경을 본다."
    ]
}

const CH09B_STAGE_CUTSCENE_NOTES: Dictionary = {
    &"CH09B_01": [
        "근원 관문은 카일의 증거와 노아의 경로가 잠시 겹치는 틈에만 부대를 들여보낸다.",
        "기록보관소가 숨겨진 이유는 비밀이어서가 아니라, 무엇이 역사로 인정될지를 스스로 정하기 때문이다."
    ],
    &"CH09B_02": [
        "삭제된 서가는 부재를 사고가 아니라 체계로 보여 준다.",
        "이곳에서 이름은 단순히 사라진 것이 아니라, 관리된 침묵 속으로 편철되어 있다."
    ],
    &"CH09B_03": [
        "노아가 지켜 온 것은 단순한 기억 조각이 아니라, 누가 그것을 감당할 수 있는가에 대한 타이밍이었다.",
        "보관인 경로는 기록보관소를 계급이 아니라 신뢰로 통과하는 장소로 바꾼다."
    ],
    &"CH09B_04": [
        "멜키온의 논리가 형태를 갖추자 전장 자체가 부대를 중심으로 다시 쓰이기 시작한다.",
        "규칙, 경로, 분류는 모두 검열의 도구가 된다."
    ]
}

const CH10_STAGE_CUTSCENE_NOTES: Dictionary = {
    &"CH10_01": [
        "외곽 상승 구간은 탑이 이미 전장 자체에서 이름을 흐리려 하고 있음을 증명한다.",
        "마지막 등반은 모두를 잊게 만들려는 하늘 아래에서 전열을 유지하는 일로 시작된다."
    ],
    &"CH10_02": [
        "공명탑은 지나치게 흩어진 부대를 가차 없이 응징한다.",
        "부대는 공유된 기억을 실제 전열 압박으로 바꿀 때에만 전진할 수 있다."
    ],
    &"CH10_03": [
        "무명의 회랑은 돌 복도가 아니라 개정된 문서의 페이지처럼 지어져 있다.",
        "노아의 존재만이 이 길이 공백 속으로 무너져 내리지 않게 붙들고 있다."
    ],
    &"CH10_04": [
        "카르온은 왕좌보다 더 크고 텅 빈 무언가가 되기 전까지는 여전히 왕처럼 싸운다.",
        "첫 단계를 부수면 칙령은 깨지지만, 그것을 울리게 한 종은 아직 멈추지 않는다."
    ]
}

# ---------------------------------------------------------------------------
# Stage 기억 Logs
# ---------------------------------------------------------------------------

const CH01_STAGE_MEMORY_LOG: Dictionary = {
    &"CH01_05": [
        {
            "title": "mem_frag_ch01_first_order",
            "summary": "첫 번째 명령: 불타는 들판 위로 잘려 나간 명령이 메아리치지만, 말한 이와 의도는 여전히 불분명하다."
        }
    ]
}

const CH02_STAGE_MEMORY_LOG: Dictionary = {
    &"CH02_05": [
        {
            "title": "mem_frag_ch02_hardren_blueprint",
            "summary": "하드렌 설계도: 리안은 이방인치고는 요새 경로와 공성로를 지나치게 정확히 기억하고 있다."
        }
    ]
}

const CH03_STAGE_MEMORY_LOG: Dictionary = {
    &"CH03_05": [
        {
            "title": "mem_frag_ch03_forest_fire_order",
            "summary": "숲 화재 명령: 리안은 제국의 명령 아래 그린우드를 태운 방화선 계획을 승인했다."
        }
    ]
}

const CH04_STAGE_MEMORY_LOG: Dictionary = {
    &"CH04_05": [
        {
            "title": "mem_frag_ch04_ark_research",
            "summary": "아크 연구 기록: 이 회랑에는 추출, 안정화, 계획된 망각 절차가 보관되어 있었다."
        }
    ]
}

const CH05_STAGE_MEMORY_LOG: Dictionary = {
    &"CH05_05": [
        {
            "title": "mem_frag_ch05_zero_revealed",
            "summary": "제로 명시: 기록보관소는 마침내 리안을 제로라고 부르지만, 주변 기록은 이후 덧씌워진 수정 흔적을 함께 보여 준다."
        }
    ]
}

const CH06_STAGE_MEMORY_LOG: Dictionary = {
    &"CH06_05": [
        {
            "title": "mem_frag_ch06_fortress_breach_context",
            "summary": "요새 돌파의 맥락: 리안은 성벽을 열었지만, 이후의 붉은 수정은 그 틈을 학살용 함정으로 조여 버렸다."
        }
    ]
}

const CH07_STAGE_MEMORY_LOG: Dictionary = {
    &"CH07_05": [
        {
            "title": "mem_frag_ch07_zero_named_by_karon",
            "summary": "카르온이 부여한 제로의 이름: 이름 없던 아이는 구원이자 속박이 되는 이름을 동시에 받았다."
        }
    ]
}

const CH08_STAGE_MEMORY_LOG: Dictionary = {
    &"CH08_05": [
        {
            "title": "mem_frag_ch08_north_corridor_context_seen",
            "summary": "북쪽 회랑의 맥락: 원래의 명령은 북쪽 경로를 열어 두었지만, 이후 수정은 그것을 포획과 숙청의 길로 좁혀 버렸다."
        }
    ]
}

const CH09A_STAGE_MEMORY_LOG: Dictionary = {
    &"CH09A_05": [
        {
            "title": "mem_frag_ch09a_returning_names_seen",
            "summary": "돌아오는 이름들: 카일은 제로를, 이름이 함께 돌아오지 않는 승리는 의미 없다고 말하던 장교로 기억해 낸다."
        }
    ]
}

const CH09B_STAGE_MEMORY_LOG: Dictionary = {
    &"CH09B_05": [
        {
            "title": "mem_frag_ch09b_final_restored",
            "summary": "최종 복원된 기억: 리안은 그 기계에 공모한 자이면서도, 그 안을 통과할 길을 남기기 위해 스스로 기억을 부순 자였다."
        }
    ]
}

const CH10_STAGE_MEMORY_LOG: Dictionary = {
    &"CH10_05": [
        {
            "title": "mem_frag_ch10_final_choice",
            "summary": "최종 선택: 리안은 삭제를 통한 평화를 거부하고, 기억된 고통이 새로운 선택으로 이어질 수 있는 세계를 택한다."
        }
    ]
}

# ---------------------------------------------------------------------------
# Stage 증거 Logs
# ---------------------------------------------------------------------------

const CH01_STAGE_EVIDENCE_LOG: Dictionary = {
    &"CH01_05": [
        {
            "title": "flag_evidence_hardren_seal_obtained",
            "summary": "하드렌 인장을 회수했다. 잿빛 들판의 지휘 계통을 따라 북쪽 국경 단서선까지 추적할 수 있다."
        }
    ]
}

const CH02_STAGE_EVIDENCE_LOG: Dictionary = {
    &"CH02_05": [
        {
            "title": "flag_evidence_greenwood_orders_obtained",
            "summary": "추적 명령서와 그린우드 북부 경로 스케치는 추격이 숲으로 향하고 있음을 확정한다."
        }
    ]
}

const CH03_STAGE_EVIDENCE_LOG: Dictionary = {
    &"CH03_05": [
        {
            "title": "flag_evidence_monastery_manifest_obtained",
            "summary": "정화 장부와 이송 메모는 추격 방향을 침수 수도원 쪽으로 가리킨다."
        }
    ]
}

const CH04_STAGE_EVIDENCE_LOG: Dictionary = {
    &"CH04_05": [
        {
            "title": "flag_evidence_archive_transfer_obtained",
            "summary": "연구 봉인과 이송 장부는 흔적을 잿빛 기록보관소로 이끈다."
        }
    ]
}

const CH05_STAGE_EVIDENCE_LOG: Dictionary = {
    &"CH05_03": [
        {
            "title": "flag_evidence_stack_seal_noted",
            "summary": "상층 서고 봉인 기록과 제어 흔적은 이 구역의 진실이 단순 보관물이 아니라, 통제와 열람 권한 아래 묶여 있다는 점을 드러낸다."
        }
    ],
    &"CH05_05": [
        {
            "title": "flag_evidence_fortress_ledger_obtained",
            "summary": "발토르 공성 장부와 생존 기사 명부는 행군을 철성 요새로 이끈다."
        }
    ]
}

const CH06_STAGE_EVIDENCE_LOG: Dictionary = {
    &"CH06_05": [
        {
            "title": "flag_evidence_elyor_edict_obtained",
            "summary": "엘리오르 구호 칙령과 민간인 이송 명부는 다음 추적이 정화 의식으로 이어짐을 확정한다."
        }
    ]
}

const CH07_STAGE_EVIDENCE_LOG: Dictionary = {
    &"CH07_01": [
        {
            "title": "flag_evidence_queue_bell_logged",
            "summary": "대기열 종과 시장 동선 기록은 엘리오르의 질서 유지가 단순 경비가 아니라, 공적 경고와 이동 통제를 결합한 체계로 운영된다는 점을 보여 준다."
        }
    ],
    &"CH07_05": [
        {
            "title": "flag_evidence_black_hound_orders_obtained",
            "summary": "흑견 명령서와 숨은 폐허 좌표는 추적 방향을 레테의 숲 경로로 가리킨다."
        }
    ]
}

const CH08_STAGE_EVIDENCE_LOG: Dictionary = {
    &"CH08_05": [
        {
            "title": "flag_evidence_outer_gate_writ_obtained",
            "summary": "특별 명령서와 검문 명판, 이송 전표는 추격 방향을 카일의 외곽 방어선으로 이끈다."
        }
    ]
}

const CH09A_STAGE_EVIDENCE_LOG: Dictionary = {
    &"CH09A_05": [
        {
            "title": "flag_evidence_root_archive_pass_obtained",
            "summary": "카일의 증언, 근원 기록보관소 통행증, 이동 장부가 이제 내부 기록보관소로 가는 길을 연다."
        }
    ]
}

const CH09B_STAGE_EVIDENCE_LOG: Dictionary = {
    &"CH09B_05": [
        {
            "title": "flag_evidence_eclipse_coords_obtained",
            "summary": "식경 좌표, 탑 격자, 마지막 칙령이 이제 최종 탑을 직접 가리킨다."
        }
    ]
}

const CH10_STAGE_EVIDENCE_LOG: Dictionary = {
    &"CH10_05": [
        {
            "title": "flag_ending_resolution_recorded",
            "summary": "종이 멈추고 탑의 격자가 붕괴하며, 이야기는 기억 끝에 무엇이 남는가를 중심으로 마무리된다."
        }
    ]
}

# ---------------------------------------------------------------------------
# Stage Letter Logs
# ---------------------------------------------------------------------------

const CH01_STAGE_LETTER_LOG: Dictionary = {
    &"CH01_05": [
        {
            "title": "세린의 편지",
            "summary": "\"지금은 네 검집에 적힌 이름이면 충분해. 우리는 함께 북쪽으로 가고, 뒤에 남은 생존자들을 지킬 거야.\""
        }
    ]
}

const CH02_STAGE_LETTER_LOG: Dictionary = {
    &"CH02_05": [
        {
            "title": "브란의 감시 맹세",
            "summary": "\"나는 아직도 네 과거를 믿지 않는다. 그래도 지금 네가 하려는 일과는 함께 걷겠다.\""
        }
    ]
}

const CH03_STAGE_LETTER_LOG: Dictionary = {
    &"CH03_05": [
        {
            "title": "티아의 불안한 휴전",
            "summary": "\"네 명령이 여기서 한 일을 용서한 건 아니야. 그래도 무엇이 남았는지는 끝까지 보러 가겠어.\""
        }
    ]
}

const CH04_STAGE_LETTER_LOG: Dictionary = {
    &"CH04_05": [
        {
            "title": "세린의 부서진 믿음",
            "summary": "\"저들은 기도로 사람에게서 이름을 씻어냈어. 난 그걸 자비라고 부르지 않을 거야.\""
        }
    ]
}

const CH05_STAGE_LETTER_LOG: Dictionary = {
    &"CH05_05": [
        {
            "title": "에녹의 난외 메모",
            "summary": "\"기억은 증거이지 판결이 아니야. 다음 요새엔 그 차이를 증명할 사람들이 아직 남아 있을지도 몰라.\""
        }
    ]
}

const CH06_STAGE_LETTER_LOG: Dictionary = {
    &"CH06_05": [
        {
            "title": "브란의 용서 없는 행군",
            "summary": "\"이 성벽을 연 손을 아직 용서할 수는 없다. 그래도 그 책임을 마주 선 자 옆으로는 여전히 걸을 수 있다.\""
        }
    ]
}

const CH07_STAGE_LETTER_LOG: Dictionary = {
    &"CH07_05": [
        {
            "title": "미라의 보내지 못한 쪽지",
            "summary": "\"나는 거의 내 아이를 침묵에게 넘길 뻔했어. 다시 자비를 구하기 전에, 그 사실을 먼저 기억하겠어.\""
        }
    ]
}

const CH08_STAGE_LETTER_LOG: Dictionary = {
    &"CH08_05": [
        {
            "title": "티아가 끝내 보내지 못한 이름",
            "summary": "\"그녀를 되돌릴 수는 없어. 하지만 그 이름을 앞으로 가져가서, 다음 거짓말은 여기서 멈추게 할 수는 있어.\""
        }
    ]
}

const CH09A_STAGE_LETTER_LOG: Dictionary = {
    &"CH09A_05": [
        {
            "title": "카일의 부서진 군기",
            "summary": "\"널 위해 편을 바꾸는 게 아니다. 내 눈으로 안쪽을 보기 위해 이 선을 넘는 것뿐이다.\""
        }
    ]
}

const CH09B_STAGE_LETTER_LOG: Dictionary = {
    &"CH09B_05": [
        {
            "title": "노아의 마지막 신뢰",
            "summary": "\"다른 너는 변명이 아니라 길을 남겼어. 나는 지금의 네가 여전히 사람을 선택할 수 있을 때까지 그 길을 지켜 왔다.\""
        }
    ]
}

const CH10_STAGE_LETTER_LOG: Dictionary = {
    &"CH10_05": [
        {
            "title": "네리의 또렷한 이름",
            "summary": "\"제 이름은 네리예요. 그러니까, 우리 중 누구도 잊지 말아 주세요.\""
        }
    ]
}

# ---------------------------------------------------------------------------
# Accessory Unlock Tables
# ---------------------------------------------------------------------------

const CH02_STAGE_ACCESSORY_UNLOCKS: Dictionary = {
    &"CH02_01": [&"acc_militia_emblem"],
    &"CH02_03": [&"acc_broken_captain_seal"],
    &"CH02_04": [&"acc_gatekeeper_ring"],
    &"CH02_05": [&"acc_hardren_iron_crest"]
}

const CH03_STAGE_ACCESSORY_UNLOCKS: Dictionary = {
    &"CH03_01": [&"acc_verdant_plume"],
    &"CH03_02": [&"acc_trap_hunter_needle"],
    &"CH03_04": [&"acc_sap_charm"]
}

const CH04_STAGE_ACCESSORY_UNLOCKS: Dictionary = {
    &"CH04_01": [&"acc_watergate_boots"],
    &"CH04_02": [&"acc_locked_bell_shard"],
    &"CH04_04": [&"acc_sanctified_pendant"],
    &"CH04_05": [&"acc_whiteflow_token"]
}

const CH05_STAGE_ACCESSORY_UNLOCKS: Dictionary = {
    &"CH05_02": [&"acc_gray_bookmark"],
    &"CH05_03": [&"acc_heatproof_archivist_coat"],
    &"CH05_04": [&"acc_zero_trace_codex"]
}

const CH06_STAGE_ACCESSORY_UNLOCKS: Dictionary = {
    &"CH06_02": [&"acc_artillery_sight"],
    &"CH06_03": [&"acc_valtor_command_cuirass"],
    &"CH06_04": [&"acc_oath_ring"]
}

const CH07_STAGE_ACCESSORY_UNLOCKS: Dictionary = {
    &"CH07_02": [&"acc_memory_bell"],
    &"CH07_04": [&"acc_knot_talisman"],
    &"CH07_05": [&"acc_namebound_thread"]
}

const CH08_STAGE_ACCESSORY_UNLOCKS: Dictionary = {
    &"CH08_02": [&"acc_moonlit_pursuit_sigil"],
    &"CH08_03": [&"acc_ruin_holdfast_charm"],
    &"CH08_04": [&"acc_houndfang_mark"]
}

const CH09A_STAGE_ACCESSORY_UNLOCKS: Dictionary = {
    &"CH09A_02": [&"acc_bannerline_clasp"],
    &"CH09A_03": [&"acc_nameless_watch_badge"],
    &"CH09A_04": [&"acc_officer_rescue_cipher"]
}

const CH09B_STAGE_ACCESSORY_UNLOCKS: Dictionary = {
    &"CH09B_02": [&"acc_revision_ward_pin"],
    &"CH09B_03": [&"acc_keeper_thread_seal"],
    &"CH09B_04": [&"acc_archive_proof_relay"]
}

const CH10_STAGE_ACCESSORY_UNLOCKS: Dictionary = {
    &"CH10_02": [&"acc_resonance_knot"],
    &"CH10_03": [&"acc_tower_ward_signet"],
    &"CH10_04": [&"acc_bell_oath_relic"]
}

# ---------------------------------------------------------------------------
# Weapon Unlock Tables
# ---------------------------------------------------------------------------

const CH05_STAGE_WEAPON_UNLOCKS: Dictionary = {
    &"CH05_02": [&"wp_archive_ashblade"],
    &"CH05_04": [&"wp_zero_trace_staff"]
}

const CH06_STAGE_WEAPON_UNLOCKS: Dictionary = {
    &"CH06_05": [&"wp_valtor_command_lance"]
}

const CH07_STAGE_WEAPON_UNLOCKS: Dictionary = {
    &"CH07_05": [&"wp_saria_mercy_staff"]
}

const CH08_STAGE_WEAPON_UNLOCKS: Dictionary = {
    &"CH08_04": [&"wp_houndline_bow"]
}

const CH09A_STAGE_WEAPON_UNLOCKS: Dictionary = {
    &"CH09A_05": [&"wp_standard_breaker_blade"]
}

const CH09B_STAGE_WEAPON_UNLOCKS: Dictionary = {
    &"CH09B_03": [&"wp_keeper_root_staff"]
}

const CH10_STAGE_WEAPON_UNLOCKS: Dictionary = {
    &"CH10_04": [&"wp_eclipse_resonance_blade"]
}

# ---------------------------------------------------------------------------
# Armor Unlock Tables
# ---------------------------------------------------------------------------

const CH03_STAGE_ARMOR_UNLOCKS: Dictionary = {
    &"CH03_03": [&"ar_greenwood_cloak"]
}

const CH04_STAGE_ARMOR_UNLOCKS: Dictionary = {
    &"CH04_05": [&"ar_whiteflow_vestment"]
}

const CH05_STAGE_ARMOR_UNLOCKS: Dictionary = {
    &"CH05_05": [&"ar_archive_smoke_coat"]
}

const CH07_STAGE_ARMOR_UNLOCKS: Dictionary = {
    &"CH07_03": [&"ar_elyor_procession_mail"]
}

const CH08_STAGE_ARMOR_UNLOCKS: Dictionary = {
    &"CH08_03": [&"ar_ruin_tracker_coat"]
}

const CH09A_STAGE_ARMOR_UNLOCKS: Dictionary = {
    &"CH09A_04": [&"ar_capital_witness_plate"]
}

const CH09B_STAGE_ARMOR_UNLOCKS: Dictionary = {
    &"CH09B_04": [&"ar_revision_guard_cloak"]
}

const CH10_STAGE_ARMOR_UNLOCKS: Dictionary = {
    &"CH10_03": [&"ar_bellward_plate"]
}

# ---------------------------------------------------------------------------
# Material Reward Table
# ---------------------------------------------------------------------------

const CHAPTER_MATERIAL_REWARDS: Dictionary = {
    &"ch02": [{"material_id": &"iron_frag", "count": 2}, {"material_id": &"coal", "count": 1}],
    &"ch03": [{"material_id": &"forest_essence", "count": 2}, {"material_id": &"fiber_bundle", "count": 1}],
    &"ch04": [{"material_id": &"sanctified_shard", "count": 2}, {"material_id": &"forest_essence", "count": 1}],
    &"ch05": [{"material_id": &"archive_ash", "count": 2}, {"material_id": &"coal", "count": 1}],
    &"ch06": [{"material_id": &"command_plate", "count": 2}, {"material_id": &"iron_frag", "count": 1}],
    &"ch07": [{"material_id": &"memory_thread", "count": 2}, {"material_id": &"forest_essence", "count": 1}],
    &"ch08": [{"material_id": &"memory_thread", "count": 1}, {"material_id": &"sanctified_shard", "count": 1}],
    &"ch09a": [{"material_id": &"iron_frag", "count": 1}, {"material_id": &"command_plate", "count": 1}],
    &"ch09b": [{"material_id": &"archive_ash", "count": 1}, {"material_id": &"memory_thread", "count": 1}],
    &"ch10": [{"material_id": &"sanctified_shard", "count": 1}, {"material_id": &"command_plate", "count": 1}]
}

# ---------------------------------------------------------------------------
# Interlude / Intro / 결말 Dialogues
# ---------------------------------------------------------------------------

const CH01_INTERLUDE_DIALOGUE: Array[String] = [
    "세린: 네 기억은 제국과 연결돼 있어. 그러니 곧 저들이 너를 찾아올 거야.",
    "리안: 그렇다면 내가 먼저 진실을 찾는다.",
    "세린: 좋아. 이제부터 나는 네 동료다.",
    "Rian: 동료...",
    "세린: 네 과거는 잠시 미뤄도 된다. 지금은 네가 지키기로 한 사람들 곁에 서 있어.",
    "리안: 고맙다.",
    "세린: 인사는 됐어. 대신 죽지만 마, 리안."
]

const CH02_INTRO_DIALOGUE: Array[String] = [
    "브란: 연막선이 아직 무너지지 않았다면, 하드렌은 저 문 뒤에서 아직도 병력을 흘리고 있다는 뜻이다.",
    "리안: 그렇다면 공성이 다시 닫히기 전에 길을 낸다.",
    "세린: 서두르되, 연기 속에 누구도 버려 두진 않는다."
]

const CH02_INTERLUDE_DIALOGUE: Array[String] = [
    "브란: 하드렌이 왜 네 기억에 반응했는지 알 때까지, 내가 직접 널 감시하겠다.",
    "리안: 마음대로 봐라. 나는 어차피 숲으로 간다.",
    "세린: 그럼 함께 움직인다. 의심도 한 챕터쯤은 의무와 나란히 걸을 수 있어."
]

const CH03_INTRO_DIALOGUE: Array[String] = [
    "티아: 한 걸음만 더 오면, 우리 숲을 다 아는 척 걷는 그 낯선 자에게 화살을 꽂겠어.",
    "리안: 그럼 정확히 겨눠라. 나는 나무가 아니라 진실을 찾으러 왔다.",
    "세린: 그린우드 길 끝에 다음 명령이 있다면, 이제 돌아설 수는 없어."
]

const CH03_INTERLUDE_DIALOGUE: Array[String] = [
    "티아: 널 용서한 건 아니야. 다만, 다음 길만큼은 진짜 끝에 닿게 만들겠다는 거지.",
    "리안: 그걸로 충분하다. 내 옆을 걸으며 진실을 놓치지 마.",
    "세린: 그럼 숲의 기억을 안고 수도원으로 간다."
]

const CH04_INTRO_DIALOGUE: Array[String] = [
    "세린: 침수된 회랑이 이렇게까지 비어 있는 소리를 낼 곳은 아니었어.",
    "리안: 그렇다면 물길을 따라 기록실까지 간다.",
    "티아: 이곳이 다음 명령을 숨겼다면, 그건 기도와 돌 아래일 거야."
]

const CH04_INTERLUDE_DIALOGUE: Array[String] = [
    "세린: 믿음은 원래 이름을 지켜야지, 살아 있는 사람에게서 이름을 벗겨내는 게 아니야.",
    "리안: 그렇다면 이 기록을 들고 나가서, 기록보관소가 대답하게 만든다.",
    "티아: 잿빛 기록보관소가 이송 기록을 쥐고 있다면, 다음 길은 거기로 꺾일 거야."
]

const CH05_INTRO_DIALOGUE: Array[String] = [
    "에녹: 잿빛 기록보관소가 아직도 타고 있다면, 우리가 필요한 기록도 지금 이 순간 사라지고 있어.",
    "리안: 그렇다면 마지막 이름이 사라지기 전에 재를 뚫고 들어간다.",
    "세린: 그리고 기록보관소가 널 다시 제로라고 부르더라도, 판단은 전부 읽고 나서 한다."
]

const CH05_INTERLUDE_DIALOGUE: Array[String] = [
    "에녹: 제로는 기록보관소에 적힌 이름일 뿐, 논쟁의 끝은 아니야.",
    "리안: 그럼 장부를 들고 발토르로 가서, 거기 무엇이 아직 남아 있는지 본다.",
    "세린: 좋아. 우린 재가 남긴 것만이 아니라, 지금 살아 있는 자가 무엇을 선택하는지로 판단한다."
]

const CH06_INTRO_DIALOGUE: Array[String] = [
    "브란: 발토르가 아직 서 있는 건, 내가 지키지 못한 이들이 저 포대 뒤에 갇혀 있기 때문이다.",
    "리안: 그렇다면 포대를 부수고 성채를 연다.",
    "에녹: 요새 장부는 다음 진실이 아직 저 벽 안에서 살아 있다고 말하고 있어."
]

const CH06_INTERLUDE_DIALOGUE: Array[String] = [
    "브란: 널 용서한 건 아니다. 다만, 네가 여기서 있었던 일을 외면하지 않는다는 건 안다.",
    "리안: 그럼 발토르의 무게를 안고, 더 많은 이름이 비워지기 전에 다음 의식을 멈춘다.",
    "에녹: 엘리오르는 더 이상 소문이 아니다. 장부가 그걸 명령으로 만들었다."
]

const CH07_INTRO_DIALOGUE: Array[String] = [
    "세린: 엘리오르는 침묵을 대가로 사람들에게 자기 고통을 내놓으라 요구하고 있어.",
    "리안: 그렇다면 아무도 빠져나올 수 없는 기도가 되기 전에 그 줄을 끊는다.",
    "브란: 그 도시에 아직 이름이 남아 있다면, 우린 그걸 지켜야 한다."
]

const CH07_INTERLUDE_DIALOGUE: Array[String] = [
    "세린: 왜 사리아가 망각을 자비라 불렀는지는 이해해. 그래도 난 그걸 거부하겠어.",
    "리안: 그럼 우리가 짊어질 수 있는 모든 이름을 붙든 채, 다음 흔적을 따라 숲으로 간다.",
    "브란: 명령은 이제 충분히 선명하다. 흑견, 숨은 폐허, 그리고 무명을 위한 줄은 더 없다."
]

const CH08_INTRO_DIALOGUE: Array[String] = [
    "티아: 흑견 흔적은 아직 선명해. 내 동생이 살아 있다면, 저 폐허 너머 어딘가에 있을 거야.",
    "리안: 그렇다면 모든 흔적이 사라지기 전에 따라간다.",
    "세린: 이번에는 숲이 명령의 흔적을 감추게 두지 않겠어."
]

const CH08_INTERLUDE_DIALOGUE: Array[String] = [
    "티아: 널 용서하진 않았어. 다만 잊는다고 숨이 쉬어지는 척하는 건 이제 끝이야.",
    "리안: 그럼 폐허가 남긴 것을 들고 카일의 전선으로 곧장 간다.",
    "세린: 좋아. 우린 이름을 앞으로 가져가고, 다음 벽이 그 이름 앞에 답하게 만든다."
]

const CH09A_INTRO_DIALOGUE: Array[String] = [
    "카일: 이 외곽선은 아직 내 명령에 답한다. 그 뒤의 진실이 이미 썩어 버렸더라도.",
    "리안: 그럼 그 선을 넘어, 원래 무엇을 숨기기 위해 세워졌는지 직접 말하게 만든다.",
    "브란: 저 뒤의 병사들이 아직 우리 사람이라면, 검열이 태워 버리기 전에 끌어내야 한다."
]

const CH09A_INTERLUDE_DIALOGUE: Array[String] = [
    "카일: 난 아직 널 판단하는 일을 끝내지 않았다. 다만 이제 무엇이 남을지를 검열이 정하게 두지 않겠다는 거다.",
    "리안: 그럼 우리와 함께 기록보관소로 가서, 거기에 남은 것들을 직접 판단해라.",
    "브란: 좋아. 군기 대신 증언을 들고 와라."
]

const CH09B_INTRO_DIALOGUE: Array[String] = [
    "노아: 문을 여는 건 원래 어려운 일이 아니었어. 어려운 건, 여기까지 올 수 있는 올바른 너를 기다리는 일이었지.",
    "리안: 그럼 이제 기록보관소가 마지막으로 기억해야 할 이유마저 고쳐 쓰기 전에 끝낸다.",
    "에녹: 멜키온은 이미 서가를 움직이고 있어. 더 깊이 갈수록, 싸움은 배열 자체와의 전쟁이 된다."
]

const CH09B_INTERLUDE_DIALOGUE: Array[String] = [
    "노아: 마지막 기억은 면죄가 아니라 맥락을 준다.",
    "리안: 좋아. 나는 그 진실을 탑까지 들고 갈 만큼 날카롭게 다듬어야 한다.",
    "카일: 그럼 기록을 읽는 건 여기까지다. 이제 그 기록을 필요로 했던 왕에게 답하러 간다."
]

const CH10_INTRO_DIALOGUE: Array[String] = [
    "세린: 이게 마지막 오름이다. 여기서 누구도 자기 이름을 두고 내려가지 않아.",
    "리안: 그럼 우리가 지켜 낸 모든 이름을 끝까지 종 앞까지 데려간다.",
    "노아: 탑은 식경을 기억하고 있어. 이제 우리가 사람을 기억하게 만들기만 하면 된다."
]

const CH10_RESOLUTION_DIALOGUE: Array[String] = [
    "세린: 끝난 게 아니야. 리안이 마지막 공명을 자기 쪽으로 끌어안았어. 그래서 우리가 여기 살아남은 거야.",
    "브란: 그렇다면 이 탑을 지나 살아남은 이름들만이 다시 세울 가치가 있는 벽이다.",
    "티아: 아직도 아프다. 그래도 나는 여기 남아 있다.",
    "에녹: 이번 결말에서 지워진 건 기록이 아니라 한 사람의 몫이었어. 우리는 그 결손까지 포함해 진실로 남겨야 한다.",
    "카일: 행군 끝에 이름 하나가 살아남은 게 아니야. 리안이 자기 몫을 태워 우리 이름을 남겼다. 다시 시작한다면 그 빚부터 기억해야 해.",
    "노아: 이번에는 기억이 사람을 쓰러뜨리는 대신, 한 사람에게 몰려들었다. 그러니 남은 사람들은 그가 잊어 가는 이름을 대신 불러야 해."
]

const CH10_TRUE_RESOLUTION_DIALOGUE: Array[String] = [
    "세린: 이번엔 누구도 뒤에 남겨 두지 않았어. 그래서 이 결말은 우리 모두의 이름으로 남아.",
    "브란: 끝까지 버틴 인연이 무너진 질서를 대신해 새로운 벽이 된다.",
    "티아: 숲에서 살아남은 이름, 도시에서 되찾은 이름, 탑에서 붙든 이름이 이제 하나로 이어진다.",
    "에녹: 기록은 더 이상 사람을 지우지 않는다. 우리가 서로를 증언하는 방식으로 남게 된다.",
    "카일: 무너진 군기 대신 함께 선 사람들의 이름이 행군의 기준이 된다.",
    "노아: 마지막 기억은 봉인이 아니라 인계가 된다. 이제부터는 우리가 다음 장을 쓴다."
]

# ---------------------------------------------------------------------------
# Presentation Cards
# ---------------------------------------------------------------------------

const CAMP_PRESENTATION_CARDS: Dictionary = {
    &"CH01": [
        {
            "eyebrow": "동료",
            "title": "세린, 전열에 서다",
            "body": "세린은 더 이상 임시 호위자가 아니다. 캠프 인계는 이제 그녀를 다음 경로와 직결된 정식 동료로 다룬다."
        },
        {
            "eyebrow": "기억",
            "title": "첫 명령이 떠오르다",
            "body": "처음 복구된 명령 파편은 리안의 전장 감각이 단순한 본능이 아니라 실제 지휘 계통과 연결되어 있음을 보여 준다."
        },
        {
            "eyebrow": "증거",
            "title": "하드렌 인장이 북쪽을 가리키다",
            "body": "회수된 인장과 경로 증거는 이제 국경 추적의 기준점이 된다. 다음 인계는 추측이 아니라 증거가 이끈다."
        }
    ],
    &"CH02": [
        {
            "eyebrow": "동료",
            "title": "브란, 전선을 붙들다",
            "body": "브란의 불신은 남아 있지만, 요새 인계는 그를 현역 전열에 고정시키고 부대를 더 거친 군사 리듬으로 밀어 넣는다."
        },
        {
            "eyebrow": "기억",
            "title": "하드렌 경로가 낯설지 않다",
            "body": "리안은 이방인치고는 요새 경로를 너무 빨리 읽는다. 이야기는 이제 그 지식을 구체적인 경고 신호로 다룬다."
        }
    ],
    &"CH03": [
        {
            "eyebrow": "동료",
            "title": "티아, 부대를 시험하다",
            "body": "그린우드 인계는 티아를 경계하던 숲의 접촉자에서, 자신의 시선으로 다음 길을 읽는 정식 동료로 바꿔 놓는다."
        },
        {
            "eyebrow": "증거",
            "title": "불은 계획된 것이었다",
            "body": "분지 경로는 더 이상 단순한 숲길이 아니다. 이번 인계는 산불의 흔적을 의도된 명령의 증거로 드러낸다."
        }
    ],
    &"CH04": [
        {
            "eyebrow": "기억",
            "title": "아크의 연구가 다시 떠오르다",
            "body": "수도원 인계는 회수한 연구를 명시적인 전환 카드로 끌어올려, 실험의 흔적을 배경 설정이 아닌 증거처럼 느끼게 만든다."
        },
        {
            "eyebrow": "증거",
            "title": "잿빛 기록보관소 경로 확정",
            "body": "이송 장부와 봉인은 이제 잿빛 기록보관소를 또렷하게 가리키고, 다음 챕터 인계는 기록을 쫓는 의도된 추격처럼 읽힌다."
        }
    ],
    &"CH05": [
        {
            "eyebrow": "동료",
            "title": "에녹이 제로의 이름을 말하다",
            "body": "기록보관소 인계는 이제 에녹의 등장과 제로의 첫 명시를 단순 요약이 아니라 실제 런타임 반전으로 다룬다."
        },
        {
            "eyebrow": "증거",
            "title": "발토르 장부가 다음 길을 가리키다",
            "body": "공성 장부와 생존 기사 명단은 철성 요새로 향하는 행군을 직접 떠미는 구체적 인계 카드로 드러난다."
        }
    ],
    &"CH06": [
        {
            "eyebrow": "기억",
            "title": "발토르 돌파가 복원되다",
            "body": "요새 돌파의 기억은 이제 의도된 인계 카드로 배치되어, 다음 챕터가 단순 회상이 아니라 군사적 격상으로 읽히게 만든다."
        },
        {
            "eyebrow": "증거",
            "title": "엘리오르 구호 경로 개방",
            "body": "구호 칙령과 민간인 이송 기록은 이제 엘리오르를 또렷하게 가리키며, 도시로의 전환을 캠프에서 분명하게 만든다."
        }
    ],
    &"CH07": [
        {
            "eyebrow": "증거",
            "title": "흑견 명령서가 떠오르다",
            "body": "무명의 도시 인계는 회수한 흑견 명령서를 더 이상 요약문 속에 묻어 두지 않고, 챕터의 핵심 증거물로 전면에 세운다."
        },
        {
            "eyebrow": "경로",
            "title": "숲길이 다시 꺾이다",
            "body": "수도 경로는 이제 숲 폐허 쪽으로 다시 꺾이는 것이 분명해져, 다음 추적이 막연한 연장이 아니라 급격한 전술 전환으로 읽힌다."
        }
    ],
    &"CH08": [
        {
            "eyebrow": "방어선",
            "title": "카일의 외곽선이 특정되다",
            "body": "흑견 추적은 이제 전용 프레젠테이션 카드를 통해 카일의 외곽선으로 인계되어, 전략 축의 전환을 한눈에 보여 준다."
        },
        {
            "eyebrow": "추적",
            "title": "레테의 경로 확정",
            "body": "숲과 폐허의 증거는 이제 이름 붙은 추적 경로로 정리되어, 챕터의 끝을 다음 방어 전선과 매끄럽게 이어 준다."
        }
    ],
    &"CH09A": [
        {
            "eyebrow": "동료",
            "title": "카일이 근원 경로를 열다",
            "body": "카일의 증언과 부서진 군기 인계는 이제 전용 전환 카드로 제시되어, 그의 합류가 캠페인 구조 자체를 바꾸는 사건처럼 느껴지게 한다."
        },
        {
            "eyebrow": "기록보관소",
            "title": "버려진 장교들의 이름이 드러나다",
            "body": "근원 기록보관소로 향하는 길은 이제 버려진 장교 기록의 무게를 명시적인 인계 오브젝트로 함께 짊어진다."
        }
    ],
    &"CH09B": [
        {
            "eyebrow": "동료",
            "title": "노아가 기록보관소 경로를 바로잡다",
            "body": "심연 인계는 이제 노아의 존재와 마지막 기록 경로 정렬을 단순 요약이 아닌 실질적인 도착처럼 느끼게 만든다."
        },
        {
            "eyebrow": "목적지",
            "title": "최종 탑이 확정되다",
            "body": "식경 좌표와 탑 격자는 이제 CH10으로 넘어가는 최종 전환 오브젝트로 제시되어, 인계 흐름을 더 단단히 조인다."
        }
    ]
}

const RESOLUTION_PRESENTATION_CARDS: Dictionary = {
    &"CH10": [
        {
            "eyebrow": "결말",
            "title": "종이 침묵하다",
            "body": "최종 결말은 이제 명확한 런타임 인계처럼 읽힌다. 카르온은 쓰러지고 종은 멈추며, 탑은 더 이상 무엇을 남길지 결정할 권리를 잃는다."
        },
        {
            "eyebrow": "기억",
            "title": "이름은 함께 남는다",
            "body": "엔딩 상태는 이제 지워진 권위가 아니라 함께 붙든 기억을 통한 생존으로 정리되며, 결말을 단순 요약이 아닌 읽히는 종결로 바꾼다."
        }
    ]
}
