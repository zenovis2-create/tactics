추천 조합

가장 추천하는 조합은 Godot 4 + GDScript + Codex CLI 또는 Codex IDE extension이다. Codex CLI는 로컬 터미널에서 저장소를 읽고, 파일을 수정하고, 명령을 실행할 수 있고, IDE extension은 VS Code뿐 아니라 Cursor/Windsurf에서도 쓸 수 있다. Codex Cloud도 있지만, Godot 초반 개발은 장면과 타일을 바로 보면서 반복 수정하는 흐름이 많아서 시작은 로컬이 더 편하다.

모바일 배포 기준으로도 이 조합이 현실적이다. Godot는 Android/iOS export 경로를 공식 문서로 제공하고, iOS export는 macOS + Xcode가 필요하다. 반면 Godot 4의 C# 모바일 export는 Android/iOS 모두 experimental이라, 빠르게 프로토타입을 밀어붙일 때는 GDScript가 더 안전하다.

SRPG 장르 자체도 Godot 기본 기능과 잘 맞는다. 현재 문서는 deprecated된 TileMap보다 TileMapLayer 사용을 권장하고, AStarGrid2D는 2D 그리드 경로탐색용으로 준비돼 있으며, TileSet custom data layer로 타일마다 이동비용·지형타입 같은 값을 넣을 수 있다. 모바일 입력은 InputEventScreenTouch로 받고, 개발 중에는 Emulate Touch From Mouse로 데스크톱에서 터치를 흉내 내며 테스트할 수 있다.

C#가 꼭 우선이면 Unity 6 + C#도 대안이다. Unity는 Tilemap 워크플로, Android APK/AAB 빌드, iOS 세팅, Input System의 touch support를 공식 문서로 갖추고 있다. 다만 “솔로 개발 + 빠른 바이브코딩 + 전술 RPG 프로토타입” 기준에서는 Godot 쪽이 더 가볍다.

처음 범위는 이 정도가 맞다

여기까지가 1차 목표다.

8x8 또는 10x10 정사각 탑다운 그리드 맵
아군 2명, 적 2명
선택 → 이동 → 공격 or 대기
간단한 지형 3종: 평지(1), 숲(2), 벽(막힘)
적 AI 1종: 가장 가까운 적에게 접근 후 공격
승리/패배 UI
세이브, 장비, 성장, 직업변경, 캠페인, 가챠, 네트워크는 전부 나중

여기서 중요한 건 등각(isometric)으로 시작하지 않는 것이다.
첫 프로토타입은 직교형 square grid로 가야 Codex도 덜 흔들리고, 모바일 터치 UX도 훨씬 단순해진다.

프로젝트 구조

이 정도로 시작하면 된다.

project/
  scenes/
    battle/
      BattleScene.tscn
      Unit.tscn
      GridCursor.tscn
      BattleHUD.tscn
  scripts/
    battle/
      battle_controller.gd
      turn_manager.gd
      path_service.gd
      range_service.gd
      combat_service.gd
      ai_service.gd
      input_controller.gd
    data/
      unit_data.gd
      skill_data.gd
      stage_data.gd
  data/
    units/
    skills/
    stages/
  docs/
    game_spec.md
    engineering_rules.md

설계는 이렇게 잡는 편이 좋다.

BattleController: 전투 상태머신
TurnManager: 턴 순서, 행동 종료
PathService: AStarGrid2D 기반 경로 계산
RangeService: 이동/공격 가능 칸 계산
CombatService: 데미지 계산
AIService: 적 행동 결정
UnitData / SkillData / StageData: 수치와 콘텐츠 데이터

핵심은 코드와 데이터를 분리하는 것이다.
유닛 스탯, 이동력, 공격 사거리, 스킬값을 씬이나 스크립트 하드코딩으로 박아버리면 Codex가 나중에 계속 꼬인다.

Codex에 일을 맡기는 방식

Codex는 “게임 전체를 만들어줘”라고 던지면 결과가 흔들린다.
대신 작은 기능 단위 + 명확한 완료 조건으로 줘야 한다.

먼저 docs/game_spec.md를 만들어 둔다. 예시는 이 정도면 충분하다.

# Game Pillars
- Mobile-first single-player tactics RPG
- Original IP inspired by classic SRPG feel
- Top-down square grid, not isometric
- One battle lasts 5~10 minutes

# Core Loop
- Player phase -> Enemy phase
- Select unit -> Move -> Attack or Wait
- Units act once per turn

# MVP
- 1 stage
- 2 ally units / 2 enemy units
- 3 terrain types
- 1 simple enemy AI
- Victory: defeat all enemies
- Defeat: all allies down

그리고 docs/engineering_rules.md도 둔다.

- Use Godot 4.x
- Use GDScript only
- Use TileMapLayer, not deprecated TileMap
- Use Resource files for UnitData / SkillData / StageData
- Mobile-first UI: large tap targets and simple HUD
- Do not add plugins unless explicitly requested
- Do not refactor unrelated files
- Keep the project runnable after each task

Codex 프롬프트에는 “빨리 대충”보다 정확성/안정성 우선을 넣는 게 좋다. OpenAI의 Codex prompting guide도 일반 작업에서 medium reasoning을 기본값으로 추천하고, 더 큰 구조 변경에는 high/xhigh를 권한다. 또 risky shortcut보다 correctness와 reliability를 우선하라고 권한다.

첫 Codex 프롬프트

아래처럼 시작하면 된다.

Read docs/game_spec.md and docs/engineering_rules.md first.

We are building a mobile-first 2D tactics RPG in Godot 4.
Constraints:
- GDScript only
- Use TileMapLayer, not TileMap
- Use Resource-based data for UnitData, SkillData, and StageData
- Use AStarGrid2D for pathfinding
- Keep the project runnable after changes
- Do not add plugins

Task:
Create the first vertical slice of the battle prototype.

Required features:
- One BattleScene with an 8x8 square grid
- 2 ally units and 2 enemy units
- Click/tap a unit to select it
- Show reachable tiles
- Move to a selected tile
- Attack an adjacent enemy
- Wait to end the unit's action
- Enemy phase with simple nearest-target AI
- Victory and defeat popup UI

Acceptance criteria:
- The project opens without script errors
- One full battle can be played from start to finish
- Balance values are stored in data resources, not hardcoded in scene nodes
- Changed files are summarized at the end
- Remaining TODOs are listed separately

After making changes, run available checks and fix syntax/runtime issues you can reproduce.

그다음 프롬프트는 이런 순서가 좋다.

TileSet custom data 기반으로 move_cost, terrain_type, defense_bonus 반영
적 AI를 “가장 가까운 적”에서 “사거리/위험도 고려”로 확장
모바일 HUD 버튼 크기 키우기, 취소 버튼/대기 버튼 정리
스테이지 데이터와 유닛 배치 데이터를 Resource 파일로 외부화
Android export용 설정 정리
실전 팁
Android 먼저 가라. iOS는 결국 macOS/Xcode가 필요하니, 첫 검증은 Android가 낫다.
데스크톱에서 먼저 전투 루프를 완성하고, 그다음 터치 UX를 다듬어라.
Codex에는 한 번에 한 기능만 시켜라.
매 작업마다 “완료 조건”을 꼭 적어라.
전투 시스템이 안정화되기 전에는 아트/연출에 시간을 너무 쓰지 마라.
“파랜드택틱스 같은 감성”만 참고하고, 이름/스토리/대사/맵/아트/UI는 자체 IP로 가야 한다.

지금 기준으로 가장 좋은 출발점은
Godot 4 + GDScript + Android 우선 + 전투 1판 vertical slice다.
이렇게 가면 Codex가 흔들리지 않고, 실제로 완성 가능한 범위로 게임이 잡힌다.

스토리 + 주인공+ 적들 + 서사 + 배경 + 최종 목표 등을 만들어줄 수 있을까?
방향성은.. 기억을 잃은 주인공이 동료들을 하나 하나 모아가면서 모험을 하다가 기억을 찾게 되고, 최종 보스를 물리쳐야하는 스토리로

인물, 세계관, 전투 동기까지 한 번에 맞물리게 짜보겠다. 기억을 되찾을수록 주인공의 위험한 진실이 드러나는 구조로 잡으면 훨씬 강해진다.

Thought for 12m 46s

좋다. 아래는 정통 판타지 SRPG 톤으로 바로 써먹을 수 있는 세계관과 메인 스토리 원안이다.

가제: 잿빛의 기억

한 줄 줄거리:
이름조차 잃은 주인공이 대륙 곳곳에 흩어진 자신의 기억과 동료들을 하나씩 되찾아가며, 모든 사람의 기억을 지워 세계를 구원하려는 왕을 막는 이야기.

1. 배경 세계관

무대는 대륙 메리디아.
이 세계에서는 사람이 죽으면 그 사람의 기억과 감정이 거대한 성수 아르카로 돌아가, 세계의 역사와 혼이 이어진다고 믿는다.

하지만 수백 년간 이어진 전쟁과 학살 때문에 성수 아르카는 점점 오염되었고, 그 여파로 사람의 이름과 과거를 조금씩 지워버리는 재앙, 공백이 퍼지기 시작한다. 공백에 잠식된 사람은 가족의 얼굴도, 자신이 왜 살아가는지도 잊어버리고, 결국 감정 없는 껍데기 같은 존재인 무명병이 된다.

이 혼란 속에서 떠오른 세력이 무명 제국이다.
그들의 왕 카르온은 “고통도, 증오도, 복수도 결국 기억에서 시작된다”는 결론에 도달했고, 세계 전체의 기억을 지워버리는 의식 무명의 종을 준비하고 있다.
그가 꿈꾸는 평화는 전쟁 없는 세계지만, 동시에 이름도 과거도 사랑도 없는 세계다.

2. 오프닝

이야기는 불타버린 사당에서 시작된다.

주인공은 피투성이 몸으로 깨어나지만, 자신의 이름도, 어디서 왔는지도, 왜 여기 있는지도 전혀 기억하지 못한다.
그가 가진 것은 금이 간 칼집 하나와, 거기에 희미하게 새겨진 글자 “RIAN” 뿐이다.

사당을 지키던 치유사 세린은 그 글자를 보고 주인공을 임시로 리안이라 부른다.
그 순간 마을에 무명 제국의 병사와 무명병들이 들이닥치고, 리안은 이유도 모른 채 놀라운 전술 감각으로 사람들을 구해낸다.

이렇게 플레이어는 처음부터 느끼게 된다.
“이 사람은 분명 평범한 사람이 아니었다.”

3. 주인공
리안

겉으로는 차분하고 과묵하지만, 남을 위험에 두는 걸 유난히 싫어한다.
기억은 없는데도 지형을 읽고, 적의 움직임을 예상하고, 최소 희생으로 승리하는 방법을 본능처럼 안다.

처음엔 “내가 누구였는지”를 알고 싶어서 여행을 시작하지만, 점점 목적이 바뀐다.
자신 때문에 고통받는 사람들을 보면서, 그는 단순히 기억을 찾는 것이 아니라 세계가 무너지는 걸 막아야 한다는 책임감을 갖게 된다.

중반 이후 밝혀지는 진실은 이렇다.

리안은 원래 무명 제국의 왕 카르온이 길러낸 양자이자, 제국 최강의 전략가 **“제로”**였다.
그는 수많은 전장을 승리로 이끌었고, 그 과정에서 많은 마을과 성소가 무너졌다.
그러나 카르온의 최종 계획이 “전쟁을 멈추는 것”이 아니라 “인간이라는 존재 자체를 텅 비게 만드는 것”임을 깨닫고 반기를 든다.

그는 카르온을 막기 위해 스스로 자신의 기억을 여러 조각으로 찢어 대륙 곳곳에 숨겼고, 마지막으로 자기 자신마저 기억을 잃게 만든다.
즉, 이 모험은 우연이 아니라 과거의 리안이 미래의 자신에게 남긴 마지막 저항이다.

4. 동료들

동료는 단순히 파티원이 아니라, 각각 리안의 과거를 증언하는 사람들이다.
그래서 기억을 찾는 과정과 동료 모집이 자연스럽게 하나로 묶인다.

세린 — 치유사 / 첫 동료
작은 사당의 수호자. 공백으로 사람들의 기억이 무너지는 모습을 지켜보며, 어떻게든 생명을 살리려 한다.
리안의 현재 모습을 가장 먼저 믿어주는 인물이다.
그녀는 “네 과거가 무엇이었든, 지금의 선택은 네가 하는 것”이라는 서사의 중심축이 된다.

브란 — 중장 기사 / 탱커
국경 요새의 전 기사단장.
제국의 “기억 소거 작전”을 거부했다가 반역자로 몰렸다.
리안의 전술을 보고 그가 과거 제국의 핵심 인물이었음을 가장 먼저 의심한다.
처음에는 감시하려고 동행하지만, 점점 리안이 과거와 다른 선택을 하는 걸 보며 신뢰하게 된다.

티아 — 궁수 / 정찰형 딜러
숲의 유격대 소속.
동생이 무명 제국에 끌려가 무명병이 되었고, 그 얼굴조차 잊혀져 가는 중이다.
가볍고 장난스러운 성격이지만, 누구보다 “잊는다는 것”의 공포를 안고 있다.
리안에게 가장 날카롭게 죄를 묻는 동료다.

에녹 — 마도학자 / 마법사
제국의 서고에서 일하던 기억술 연구자.
과거 자신도 공백 연구에 관여했기 때문에 죄책감을 품고 있다.
리안의 기억 조각과 성수 아르카, 무명의 종의 구조를 해석하는 핵심 인물이다.
진실을 숨기지 않고 드러내려는 성격이라, 파티 내 갈등을 일으키는 역할도 한다.

카일 — 창기사 / 라이벌, 후반 합류
무명 제국의 젊은 장군.
과거에는 리안을 “제로”라 부르며 진심으로 존경했다.
초반에는 리안을 잡으러 오는 적이지만, 제국이 충성스러운 병사들조차 결국 이름 없는 도구로 만들려 한다는 사실을 보고 무너진다.
후반부에 가장 극적으로 아군이 되는 인물이다.

노아 — 기억 공명자 / 서포터
사람과 물건에 남은 기억의 잔향을 들을 수 있는 아이.
겉보기엔 연약하지만, 사실 리안이 마지막 기억 조각을 맡겨둔 존재다.
노아는 리안이 완전히 진실을 받아들일 준비가 될 때까지 그 조각을 숨기고 있었다.
후반 서사의 열쇠다.

5. 적들
최종 보스: 무명왕 카르온

한때는 전쟁을 끝낸 영웅왕이었다.
하지만 가족과 나라를 지키려 했던 모든 기억 끝에 남은 것이 끝없는 증오와 복수뿐이라는 사실에 절망한다.
그래서 그는 결론을 내린다.
“사람들이 기억하기 때문에 서로를 미워한다면, 차라리 모두가 잊는 편이 낫다.”

카르온은 악당이지만, 단순한 파괴자가 아니다.
그는 세계를 사랑했지만, 결국 사람을 믿지 못하게 된 왕이다.
그래서 리안과 카르온의 대립은 선과 악의 싸움이라기보다,
**“고통을 없애기 위해 인간성을 버릴 수 있는가”**라는 질문이 된다.

카르온 아래에는 각 장의 보스로 쓰기 좋은 적 장군들이 있다.

발가르 — 철성 장군
무력과 질서를 중시하는 요새형 보스.
브란과 대립한다.

레테 — 흑견 암살자
기억을 훔치는 암살자.
안개 맵, 잠입 맵에 잘 어울린다.

사리아 — 백성녀
“망각은 자비”라고 믿는 제국의 성녀.
세린과 세계관적으로 정면 충돌한다.

멜키온 — 서고의 마도장
역사를 기록하는 자이면서, 가장 능숙하게 역사를 조작하는 인물.
에녹과 깊은 악연이 있다.

초반에는 적이지만 후반에 아군이 되는 카일이 있어, 적 진영도 단순한 괴물 집단이 아니라는 느낌을 줄 수 있다.

6. 전체 서사 구조
프롤로그: 이름 없는 새벽

리안이 사당에서 깨어난다.
세린과 함께 마을을 지키고, 무명 제국이 공백을 퍼뜨리고 있다는 사실을 알게 된다.
리안은 칼집의 글자만을 단서로 자기 이름을 붙잡고 길을 떠난다.

1막: 잔향을 쫓는 자들

브란, 티아가 차례로 합류한다.
각 지역을 구하며 기억 조각 하나씩을 되찾는데, 그 조각들은 리안이 영웅이 아니라 제국의 전쟁을 이끌던 남자였음을 보여준다.
플레이어는 이 시점부터 “기억을 찾는 게 정말 좋은 일인가?”라는 불안을 느끼게 된다.

2막: 거짓된 영웅

에녹이 합류하고, 무명의 종의 진실이 드러난다.
제국은 단지 세상을 지배하려는 것이 아니라, 아예 모든 이름과 감정을 지워 완전한 정적의 세계를 만들려 한다.
리안은 자신이 과거에 그 계획을 도왔다는 사실까지 알게 된다.

여기서 동료들과 큰 균열이 생긴다.
특히 티아와 브란은 “네가 우리 원수였다”고 말하며 등을 돌릴 뻔한다.
하지만 세린은 리안을 감싸지 않는다. 대신 말한다.
“네 과거를 부정하지 마. 대신 지금, 어떤 사람이 될지 선택해.”

3막: 되찾은 이름

카일이 제국의 진실을 보고 이탈해 합류한다.
노아가 마지막 기억 조각을 건네고, 리안은 모든 걸 기억해낸다.

진실은 이렇다.
리안은 카르온을 막을 방법이 거의 없다는 걸 알고, 과거의 자신이 다시 무너질 가능성까지 계산해 두었다.
그래서 자신의 기억을 신뢰하지 않고, 미래에 만날 동료들을 더 믿는 선택을 했다.
즉, 동료들은 우연히 모인 파티가 아니라, 리안이 마지막 순간에 남긴 희망 그 자체다.

종장: 무명의 탑

월식의 밤, 카르온이 무명의 종을 울리려 한다.
리안 일행은 무명의 탑으로 진격하고, 각 장군과 결전을 치른다.
최상층에서 카르온은 리안에게 마지막 제안을 한다.

“모든 슬픔을 끝내자.
네 죄도, 내 후회도, 이 세계의 상처도 전부 잊게 만들자.”

리안은 그 제안을 거절한다.
기억은 고통의 원인이기도 하지만, 동시에 사랑과 책임의 증거이기 때문이다.
그는 **“잊어서 평화로운 세계”가 아니라, “기억한 채로도 다시 선택할 수 있는 세계”**를 택한다.

7. 최종 목표

이 이야기의 최종 목표는 단순히 카르온을 죽이는 것이 아니다.

무명의 종을 막는다.
리안의 진짜 기억을 되찾는다.
제국이 빼앗은 사람들의 기억을 원래 주인에게 돌려준다.
고통을 지우는 방식이 아니라, 고통을 안고도 앞으로 나아갈 수 있다는 답을 제시한다.

즉 최종 목표는 “최종 보스 처치”보다 조금 더 크다.
세계를 구하는 동시에, ‘기억이란 왜 필요한가’에 대한 이야기를 완성하는 것이다.

8. 엔딩 방향

엔딩은 두 갈래로 가면 좋다.

일반 엔딩
카르온을 막지만, 성수 아르카를 안정시키기 위해 리안이 다시 자신의 기억 대부분을 희생한다.
세상은 구해지지만, 그는 동료들의 이름을 또렷하게 기억하지 못한다.
슬프지만 아름다운 엔딩.

진엔딩
모든 동료의 개인 서사와 기억 조각을 완성하면, 리안 혼자 희생하는 대신 모두가 기억의 부담을 함께 나눈다.
리안은 죄와 사랑을 모두 기억한 채 살아남고, 동료들과 함께 공백으로 무너진 땅을 다시 세우는 길을 택한다.
SRPG로 만들면 이 쪽이 훨씬 여운이 크다.