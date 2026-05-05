# Scout Guard Package Candidate Manifest — 2026-05-05

- 기준 시각: 2026-05-05 12:46:32 KST
- 작업 루트: `/Volumes/AI/tactics`
- 목적: Scout guard v02.1 package candidate의 최종 후보 경계 고정
- 수행 제한: 문서 작성만. 이미지 생성, 삭제, `git add/commit` 없음.

## 결론

Scout guard v02.1은 package candidate입니다. 단, runtime 본체와 evidence/provenance를 분리해야 하며, Rian WIP, bark f61/f62, signing, gameplay UX 변경은 이 package에 섞지 않습니다.

## Evidence 판정

확인된 기준:
- `tmp/imagegen/scout_guard_v021_imagegen/package_scout_guard_result.json`
  - `ok=True`
  - `character_id=scout`
  - `frame_count=448`
- `tmp/imagegen/scout_guard_v021_imagegen/scout_guard_v02_1_imagegen_processing_report.json`
  - `source_cols=12`
  - `output_cols=16`
  - `footline_y=238`
- runtime frame count
  - 7 states x 4 facings x 16 png = 448 png
  - 누락 없음

## Runtime package 포함 후보

반드시 포함:
- `assets/characters/sprite_anchor_scout/runtime_contract_v02.json`
- `assets/characters/sprite_anchor_scout/runtime/scout_sprite_frames.tres`
- `assets/characters/sprite_anchor_scout/runtime/facing_frames/**`

조건부 포함:
- `assets/characters/sprite_anchor_scout/source/sheets/scout_idle_64f_sheet_v02_1_guard_imagegen.png`
- `assets/characters/sprite_anchor_scout/source/sheets/scout_idle_64f_sheet_v02_1_guard_imagegen.png.import`
- `assets/characters/sprite_anchor_scout/source/sheets/scout_idle_64f_sheet_v02_1_guard_imagegen_manifest.json`

조건:
- runtime contract 또는 `scout_sprite_frames.tres`가 source sheet provenance를 요구하면 포함합니다.
- 요구하지 않으면 runtime 본체가 아니라 evidence/provenance 참조로 둡니다.

## Evidence / provenance 참조

runtime package 본체와 분리합니다.

- `tmp/imagegen/scout_guard_v021_imagegen/package_scout_guard_result.json`
- `tmp/imagegen/scout_guard_v021_imagegen/scout_guard_v02_1_imagegen_processing_report.json`
- `tmp/validation/qa_evidence_20260505_f79_f81_asset_split/asset_scout_guard_runtime_contract.json`
- `tmp/validation/qa_evidence_20260505_f79_f81_asset_split/asset_scout_guard_runtime_contract.log`
- `tmp/validation/qa_evidence_20260505_f79_f81_asset_split/asset_battle_integration_preview.log`
- `docs/reviews/2026-05-05-qa-evidence-f79-f81-ux-rian-scout-asset-split.md`
- `docs/package_manifests/2026-05-05_asset_forge_package_manifest.md`
- `docs/package_manifests/2026-05-05_scout_rian_asset_boundary_checklist.md`

## 명시 제외

이 package candidate에서 제외:
- `assets/characters/sprite_anchor_rian/**`
- `tmp/imagegen/rian_guard_v021_imagegen/**`
- `tmp/imagegen/scout_guard_v021_imagegen/**` raw/scratch 전체
  - 단, 위 JSON 2개는 evidence/provenance 참조 가능
- `tmp/imagegen/**`
- `output/imagegen/**`
- f61/f62 bark package 관련 89개 boundary
- Android/macOS signing/codesign/notarization 관련 변경
- gameplay UX 변경
- `.gitignore` cleanup 변경

## 읽기 전용 검증 명령

```bash
cd /Volumes/AI/tactics

git status --short -- \
  assets/characters/sprite_anchor_scout \
  tmp/imagegen/scout_guard_v021_imagegen \
  tmp/validation/qa_evidence_20260505_f79_f81_asset_split \
  docs/reviews/2026-05-05-qa-evidence-f79-f81-ux-rian-scout-asset-split.md

python3 - <<'PY'
from pathlib import Path
root = Path('/Volumes/AI/tactics/assets/characters/sprite_anchor_scout/runtime/facing_frames')
states = ['attack','cast','defeat','guard','hit','idle','move']
facings = ['front_right','front_left','back_right','back_left']
ok = True
for state in states:
    for facing in facings:
        n = len(list((root/state/facing).glob('*.png')))
        print(f'{state}/{facing}: {n}')
        ok = ok and n == 16
raise SystemExit(0 if ok else 1)
PY
```

## 승격 조건

- runtime package 포함 후보만 staged/review 대상이 됩니다.
- Rian 파일 0개가 포함됩니다.
- `tmp/imagegen/**` raw/scratch는 runtime package 본체에 포함되지 않습니다.
- f61/f62 bark package와 같은 commit/package로 묶지 않습니다.
