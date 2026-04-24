# Ending Visual Stack Eleventh Pass Design

**Scope:** ending/credits visual stack snapshot 11차

## Goal

ending/credits overlay layer가 많아졌으므로,
runner와 QA가 현재 overlay surface를 한 번에 확인할 수 있는 compact visual stack snapshot을 추가한다.

## Recommended Approach

- `main.gd`에 `get_ending_visual_stack()`을 추가한다.
- `main.gd`에 `get_credits_visual_stack()`을 추가한다.
- active rail/outcome/source/progress layer를 compact string 배열로 노출한다.

## Verification

- `ending_cinematic_runner.gd`에서 true ending visual stack 확인
- `postgame_surface_runner.gd`에서 final credits visual stack 확인
