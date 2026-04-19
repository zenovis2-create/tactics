# Farland Tactics — Phase 4 Feature Specs (Ideas 1-10)

## Completion Checklist

---

### SPEC-P4-01: Ghost Battle System (유령 전투)
- [x] **P4-01-1** `scripts/battle/ghost_battle_manager.gd` — ghost ID generation + cross-player matching
- [x] **P4-01-2** `scripts/battle/ghost_formation_extractor.gd` — extract patterns from Chronicle battle logs
- [ ] **P4-01-3** ChronicleGenerator에 `extract_ghost_pattern() -> GhostFormationData` 추가
- [x] **P4-01-4** `GhostFormationData.gd` Resource: formation[], avg_turns, preferred_terrain, player_tag
- [ ] **P4-01-5** battle_controller에 ghost boss spawn 로직 추가
- [x] **P4-01-6** "홍길동의 전략" 네이밍 + 익명 옵션
- [x] **P4-01-7** 격파 시 "XXX의 전략을 격파했다" 메시지
- [x] **P4-01-8** 챔피언 보드 시스템 stub (순위 아님, 명예의 전당)
- [x] **P4-01-9** `scripts/dev/ghost_battle_runner.gd` 작성
- [ ] **P4-01-10** Runner 검증 — godot headless 통과

---

### SPEC-P4-02: Replay Market / Guild System (전투 길드)
- [x] **P4-02-1** `scripts/battle/replay_data.gd` — 저장을 위한 리플레이 데이터 Resource
- [x] **P4-02-2** `scripts/battle/replay_manager.gd` — CRUD operations for replays
- [x] **P4-02-3** `scripts/battle/guild_system.gd` — 길드 생성/가입/탈퇴
- [x] **P4-02-4** 길드 랭킹 계산: 길드원 평균 전투 등급
- [x] **P4-02-5** 길드 커뮤니티 탭 UI (encyclopedia_panel.gd TAB_GUILD)
- [x] **P4-02-6** 길드 배너 커스터마이즈 (5가지 심볼)
- [x] **P4-02-7** 온라인 스텁: `upload_replay_to_server()`, `download_replay()`, `is_online()`
- [x] **P4-02-8** `scripts/dev/guild_system_runner.gd` 작성
- [x] **P4-02-9** Runner 검증 — 37/37 PASS (commit `4bb23a1`)

---

### SPEC-P4-03: Scenario Creator (시나리오 창작자) ⭐ 최우선
- [x] **P4-03-1** `scripts/editor/scenario_editor.gd` — 시나리오 에디터 코어
- [x] **P4-03-2** `scripts/data/scenario.gd` — 시나리오 Resource: chapter_id, stage_id, spawns[], dialogues[], objectives[]
- [ ] **P4-03-3** `scripts/editor/scenario_stage_picker.gd` — 기존 맵 선택 위젯
- [ ] **P4-03-4** `scripts/editor/scenario_dialogue_editor.gd` — 대사 편집기
- [ ] **P4-03-5** `scripts/editor/scenario_spawn_editor.gd` — 적/아군 배치 편집기
- [ ] **P4-03-6** CampaignController에 "시나리오 모드" 진입 포인트
- [x] **P4-03-7** EncyclopediaTabs에 "사용자 창작" 탭 (6번째 탭)
- [x] **P4-03-8** 시나리오 공유: `scripts/dev/scenario_loader.gd` — 파일에서 로드
- [x] **P4-03-9** Steam Workshop stub (게시/다운로드 메서드만 존재)
- [x] **P4-03-10** `scripts/dev/scenario_creator_runner.gd` 작성
- [ ] **P4-03-11** Runner 검증 — godot headless 통과

---

### SPEC-P4-04: Living Soundtrack (생존하는 사운드트랙)
- [ ] **P4-04-1** `scripts/audio/layered_music.gd` — Music autoload, 레이어드 오디오 엔진
- [ ] **P4-04-2** project.godot에 AudioBus 추가: MusicBase, MusicDrums, MusicStrings, MusicVocal, MusicAmbience
- [ ] **P4-04-3** `activate_layer(layer_name, fade_time)` / `deactivate_layer(layer_name, fade_time)`
- [ ] **P4-04-4** `trigger_spotlight_music(spotlight_type)` — 4가지 spotlight별 레이어 트리거
- [ ] **P4-04-5** `scripts/audio/emotional_layer_controller.gd` — Spotlight/BondDeath 신호 리스닝
- [ ] **P4-04-6** `_on_spotlight_triggered()` → Music.trigger_spotlight_music()
- [ ] **P4-04-7** `_on_bond_death_started()` → vocal chorus layer 추가
- [ ] **P4-04-8** 전투 종료 시 모든 레이어 페이드아웃 (fade_time=2.0)
- [ ] **P4-04-9** 전투 시작 시 레이어드 트랙 재생 (기존 BGM에서 레이어 분리)
- [ ] **P4-04-10** `scripts/dev/living_soundtrack_runner.gd` 작성
- [ ] **P4-04-11** Runner 검증 — godot headless 통과 (오디오 파일 불필요)

---

### SPEC-P4-05: Adaptive Narrative Engine (적응형 서사)
- [ ] **P4-05-1** `scripts/battle/adaptive_dialogue_filter.gd` — DialogueTree 필터링
- [ ] **P4-05-2** ChronicleGenerator 패턴 → NPC 성격 매핑 (aggressive/defensive/merciful)
- [ ] **P4-05-3** campaign_controller에 `adapt_dialogue_by_chronicle()` 메서드
- [ ] **P4-05-4** 레오니카 대화 variants: ruthless/pragmatic/compassionate 트랙
- [ ] **P4-05-5** "_CH10_LEONIKA_RUTHLESS", "_CH10_LEONIKA_COMPASSIONATE" 등 dialogue key 추가
- [ ] **P4-05-6** Bond Death 직후 NPC가追悼 대사 자동 출력
- [ ] **P4-05-7** NPC 표정 아이콘 변경 시스템 (campaign_shell_dialogue_catalog.gd 확장)
- [ ] **P4-05-8** `scripts/dev/adaptive_narrative_runner.gd` 작성
- [ ] **P4-05-9** Runner 검증 — godot headless 통과

---

### SPEC-P4-06: Cross-Faction Music Warfare (세력별 음악)
- [x] **P4-06-1** 세势 음악 ID 정의: FARLAND_EMPIRE / LEONICA_RESISTANCE / NEUTRAL_MERCENARIES
- [x] **P4-06-2** `scripts/audio/faction_music.gd` —势별 테마 트랙 관리
- [x] **P4-06-3** 전투 시작 시势 기반 BGM 선택 (campaign_controller에서 호출)
- [x] **P4-06-4**势 교차 전투: 테마 Cross-fade 로직 (2.0s blend)
- [x] **P4-06-5** CH10 Final: 세势 테마 동시 재생 → 다중화음
- [ ] **P4-06-6** 필드 맵势 영역 진입/이탈 시 BGM 전환
- [x] **P4-06-7** `scripts/dev/faction_music_runner.gd` 작성
- [x] **P4-06-8** Runner 검증 — 39/39 PASS (commit `1676c06`)

---

### SPEC-P4-07: Observer Mode (관전 모드)
- [x] **P4-07-1** `scripts/ui/observer_camera.gd` — 자유 시점 카메라 컨트롤
- [x] **P4-07-2** 전투 중 관전 모드 토글 버튼 (battle_hud.gd에 추가)
- [x] **P4-07-3** 관전용 HUD: 유닛별 위치/HP/상태 표시
- [x] **P4-07-4** 자동 전술 해설 텍스트 생성 (패턴 기반 Dictionary rule engine)
- [x] **P4-07-5** 하이라이트 자동 감지 + 클립 저장
- [x] **P4-07-6** 스트리머 오버레이 stub (시청자 수도 표시)
- [x] **P4-07-7** Twitch/YouTube 연동 stub (OAuth + 채팅 읽기 메서드만 존재)
- [x] **P4-07-8** `scripts/dev/observer_mode_runner.gd` 작성
- [x] **P4-07-9** Runner 검증 — godot headless 통과 (59/59 PASS, commit `1e1be4d`)

---

### SPEC-P4-08: Moral Consequence Engine (도덕적 결과 엔진) ⭐ 단기 우선
- [ ] **P4-08-1** `scripts/battle/ethics_tracker.gd` — Ethics autoload
- [ ] **P4-08-2** ethics_score: float (-100 ~ +100), decision_log[], 기본값 0
- [ ] **P4-08-3** 결정 가중치 테이블: spared_enemy(+5), burned_bridge(-10), saved_supply(+8), ignored_warning(-5), recruited_hidden(+10), left_unit_to_die(-15)
- [ ] **P4-08-4** `record_decision(chapter_id, key, weight)` → ethics_score 업데이트
- [ ] **P4-08-5** `get_ethics_bracket() -> String` — ruthless(<-30) / pragmatic(-30~30) / compassionate(>30)
- [ ] **P4-08-6** `scripts/battle/moral_consequence_service.gd` — MoralConsequence autoload
- [ ] **P4-08-7** DecisionPoint.decision_made → Ethics.record_decision 자동 연결
- [ ] **P4-08-8** `apply_consequences_to_boss(boss_id) -> BossModifier` — ruth/comp影响 보스 스탯
- [ ] **P4-08-9** `get_boss_dialogue_variant(boss_id) -> String` — Ethics별 대사 variants
- [ ] **P4-08-10** battle_controller.gd: 보스 스폰 시 MoralConsequence 적용
- [ ] **P4-08-11** battle_result_screen.gd: 엔딩 분기 시 MoralConsequence 적용
- [ ] **P4-08-12** 세 가지 엔딩 variants: Conqueror( ruthless) / Guardian(compassionate) / Survivor(pragmatic)
- [ ] **P4-08-13** `scripts/dev/moral_consequence_runner.gd` 작성
- [ ] **P4-08-14** Runner 검증 — godot headless 통과

---

### SPEC-P4-09: Persistent World Consequences (전장의 기억)
- [ ] **P4-09-1** progression_data.gd에 `terrain_damage_map: Dictionary` 추가
- [ ] **P4-09-2** `terrain_damage_map[chapter_id] = {tile_pos: damage_level}` 형태
- [ ] **P4-09-3** battle_controller: 전투 중 지형 손상 → terrain_damage_map 기록
- [ ] **P4-09-4** StageData 로드 시 terrain_damage_map 적용 → 손상된 타일 시각화
- [ ] **P4-09-5** 반복 플레이 시 누적 손상: 3회 이상 전투된 위치에 memorial marker
- [ ] **P4-09-6** memorial_scene.gd에 "전장의자국" 섹션 추가
- [ ] **P4-09-7** NG+에서 terrain_damage_map 영구 저장 + world map 표시
- [ ] **P4-09-8** "전장의museum" 건립: 가장 많은 전투가 벌어진 위치에特殊 구조물
- [ ] **P4-09-9** `scripts/dev/persistent_world_runner.gd` 작성
- [ ] **P4-09-10** Runner 검증 — godot headless 통과

---

### SPEC-P4-10: Destiny System (운명의 선택) ⭐终极
- [x] **P4-10-1** NG+ 3회차에서만解锁: "제3의 눈" 클리어 조건 — `966d69f`
- [x] **P4-10-2** `scripts/battle/destiny_manager.gd` — Destiny autoload — `966d69f`
- [x] **P4-10-3** 이중세계관 데이터 구조: `{current_world: Dict, past_world: Dict}` — `966d69f`
- [ ] **P4-10-4** 과거 결정 변경 UI: Chronicle에서 특정 선택지를 다시 고르기
- [x] **P4-10-5** 과거 변경 시 현재 세계 동기화: `resync_world_with_past_change()` — `966d69f`
- [ ] **P4-10-6** "역사의 기록자" 스킬 트리: CH10 최종전에서 선택지 확장
- [x] **P4-10-7** Encyclopedia에 "역사의 기록자" 탭 (7번째 탭) — 모든 과거 변경 이력 — `966d69f`
- [ ] **P4-10-8** HeirloomLegacy와 통합: 3회차 가문血脉이 "역사를 바꾼 가문" 배지
- [ ] **P4-10-9** "운명이 선택한 사람들" True Ending 엔딩 크레딧
- [x] **P4-10-10** `scripts/dev/destiny_system_runner.gd` 작성 — `966d69f`
- [x] **P4-10-11** Runner 검증 — godot headless 통과 — `966d69f` (21/21 PASS)

---

## Implementation Priority Order

```
1. [P4-08] Moral Consequence Engine   — 기존 Cascade/Decision 시스템 확장, 스토리 깊이 즉시 향상
2. [P4-04] Living Soundtrack         — AudioBus만 설정하면 동작, 몰입도 급상승
3. [P4-09] Persistent World          — Terrain Remembers 확장, NG+ 의미 부여
4. [P4-05] Adaptive Narrative        — Dialogue System 확장, NPC 개성 부여
5. [P4-01] Ghost Battle             — 커뮤니티 유리, 콘텐츠 무한 확장
6. [P4-03] Scenario Creator         — 장기적 생명주기관리, Steam Workshop
7. [P4-06] Cross-Faction Music     — 기존 BGM 재활용, 구현 난이도 낮음
8. [P4-07] Observer Mode            — Twitch 연동 stub만, 콘텐츠 크리에이터 유입
9. [P4-02] Guild System            — 온라인 의존 stub, 커뮤니티 형성
10. [P4-10] Destiny System          —终极目标, 모든 시스템 통합
```

## Cross-Spec Dependencies

```
P4-10 (Destiny) requires: P4-08, P4-09, SPEC-J (Heirloom), SPEC-H (Chronicle)
P4-01 (Ghost Battle) requires: SPEC-H (Chronicle), SPEC-B (Cascade)
P4-05 (Adaptive Narrative) requires: SPEC-B (Cascade), SPEC-H (Chronicle)
P4-09 (Persistent World) requires: SPEC-B (Cascade), SPEC-J (Heirloom)
P4-04 (Living Soundtrack) standalone — 의존성 없음, 즉시 구현 가능
P4-08 (Moral Consequence) extends: SPEC-B (DecisionPoint)
```

## Runner Pattern (공통)

모든 SPEC에는 반드시:
1. `scripts/dev/[feature]_runner.gd` 작성
2. `godot --headless --path . --script scripts/dev/[feature]_runner.gd` 통과
3. 커밋 전 모든 previous runners 재실행确认

---

**Total: 110 checklist items across 10 Phase 4 specs**
