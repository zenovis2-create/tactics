# Bark Package-only Staging Approval Packet — 2026-05-05

- 기준 시각: 2026-05-05 12:46:32 KST
- 작업 루트: `/Volumes/AI/tactics`
- 목적: f61/f62 bark package-only staging 전 승인용 1-page packet
- 수행 제한: 문서 작성만. `git add`, commit, 코드 수정, 삭제 없음.

## 결론

bark package는 현재 **BLOCKED**입니다. 실제 staging은 index mutation이므로 별도 승인 후에만 진행합니다. 승인 시에도 broad add 금지, bark-package-only 89개 boundary만 대상으로 합니다.

## 현재 blocker

`python3 scripts/dev/check_post_battle_bark_payload_package.py` 결과:

```text
manifest_paths=89 stages=54 runners=7 docs=18 direct_object_dependencies=8
cached_bark_stage_coverage=0/54
unstaged_bark_stage_deltas=54
untracked_manifest_paths=33
unstaged_manifest_paths=56
BLOCKED:
- unstaged bark stage deltas remain: 54 files
- cached bark stage coverage is 0/54 files
- partially staged files in manifest: data/stages/ch03_04_stage.tres, data/stages/ch04_01_stage.tres, data/stages/ch04_02_stage.tres
- untracked manifest paths remain: 33 files
- unstaged manifest paths remain: 56 files
```

## 승인 대상 boundary

총 89개:
- stage payload: 54개
- runner/guard: 7개
- direct object dependencies: 8개
- support: 2개
- review docs: 18개

## 승인 후 실행 순서

1. partial staged 3개 해소
   - `data/stages/ch03_04_stage.tres`
   - `data/stages/ch04_01_stage.tres`
   - `data/stages/ch04_02_stage.tres`

2. stage payload 54개 전체 파일 단위 정렬
   - `data/stages/ch01_02_stage.tres` ~ `data/stages/ch10_05_stage.tres`
   - chapter ranges: ch01_02~05, ch02_01~05, ch03_01~05, ch04_01~05, ch05_01~05, ch06_01~05, ch07_01~05, ch08_01~05, ch09a_01~05, ch09b_01~05, ch10_01~05

3. support 2개 포함
   - `scripts/data/stage_data.gd`
   - `scripts/dev/ch06_ch10_boss_surface_runner.gd`

4. direct object dependencies 8개 포함
   - `data/objects/ch05_04_truth_shelf_index.tres`
   - `data/objects/ch05_04_zero_transfer_ledger.tres`
   - `data/objects/ch09a_04_east_censor_pike.tres`
   - `data/objects/ch09a_04_west_cell_witness.tres`
   - `data/objects/ch10_02_east_crest_control.tres`
   - `data/objects/ch10_02_west_crest_control.tres`
   - `data/objects/ch10_03_east_corridor_anchor.tres`
   - `data/objects/ch10_03_west_corridor_anchor.tres`

5. runner/guard 7개 포함
   - `scripts/dev/post_battle_bark_queue_runner.gd`
   - `scripts/dev/post_battle_bark_queue_runner.gd.uid`
   - `scripts/dev/post_battle_handoff_runner.gd`
   - `scripts/dev/post_battle_handoff_runner.gd.uid`
   - `scripts/dev/post_battle_readability_runner.gd`
   - `scripts/dev/post_battle_readability_runner.gd.uid`
   - `scripts/dev/check_post_battle_bark_payload_package.py`

6. review docs 18개 포함
   - `docs/reviews/2026-05-05-f44-ch03-04-ch03-05-post-battle-bark-release-qa.md`
   - `docs/reviews/2026-05-05-f45-ch04-01-ch04-03-post-battle-bark-release-qa.md`
   - `docs/reviews/2026-05-05-f46-ch04-04-ch04-05-post-battle-bark-release-qa.md`
   - `docs/reviews/2026-05-05-f47-ch05-01-ch05-03-post-battle-bark-release-qa.md`
   - `docs/reviews/2026-05-05-f48-ch05-04-ch05-05-post-battle-bark-release-qa.md`
   - `docs/reviews/2026-05-05-f49-ch06-01-ch06-03-post-battle-bark-release-qa.md`
   - `docs/reviews/2026-05-05-f50-ch06-04-ch06-05-post-battle-bark-release-qa.md`
   - `docs/reviews/2026-05-05-f51-ch07-01-ch07-03-post-battle-bark-release-qa.md`
   - `docs/reviews/2026-05-05-f52-ch07-04-ch07-05-post-battle-bark-release-qa.md`
   - `docs/reviews/2026-05-05-f53-ch08-01-ch08-03-post-battle-bark-release-qa.md`
   - `docs/reviews/2026-05-05-f54-ch08-04-ch08-05-post-battle-bark-release-qa.md`
   - `docs/reviews/2026-05-05-f55-ch09a-01-ch09a-03-post-battle-bark-release-qa.md`
   - `docs/reviews/2026-05-05-f56-ch09a-04-ch09a-05-post-battle-bark-release-qa.md`
   - `docs/reviews/2026-05-05-f57-ch09b-01-ch09b-03-post-battle-bark-release-qa.md`
   - `docs/reviews/2026-05-05-f58-ch09b-04-ch09b-05-post-battle-bark-release-qa.md`
   - `docs/reviews/2026-05-05-f59-ch10-01-ch10-03-post-battle-bark-release-qa.md`
   - `docs/reviews/2026-05-05-f60-ch10-04-ch10-05-post-battle-bark-release-qa.md`
   - `docs/reviews/2026-05-05-f61-post-battle-bark-payload-packaging-qa.md`

## 명시 제외

- Scout/Rian Asset Forge package
- `.gitignore` cleanup
- `tmp/`, `output/`, `.codex/`, `.claude/`, `.worktrees/`
- signing/codesign/notarization
- gameplay UX 변경
- package manifest 문서들

## PASS 조건

- `cached_bark_stage_coverage=54/54`
- `unstaged_bark_stage_deltas=0`
- `untracked_manifest_paths=0`
- `unstaged_manifest_paths=0`
- partial staged manifest file 없음
- guard 최종 출력 PASS

## 위험도

- 이 packet 작성: safe local doc
- 실제 `git add`: index mutation, 별도 승인 필요
- 삭제/clean: destructive, 별도 승인 필요
- signing/custody: credential custody, 별도 승인 필요
