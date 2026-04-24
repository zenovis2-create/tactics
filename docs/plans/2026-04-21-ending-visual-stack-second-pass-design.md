# Ending Visual Stack Second Pass Design

**Scope:** ending/credits visual stack 14차

## Goal

이미 추가된 visual stack이 rail/outcome 중심이므로,
이번 패스에서는 `afterglow`까지 포함해 전환 잔향도 compact summary에 반영한다.

## Recommended Approach

- `get_ending_visual_stack()`에 `afterglow:true_ending|normal_ending`를 추가한다.
- `get_credits_visual_stack()`에 `afterglow:index`를 추가한다.
- 기존 개별 검증은 유지한다.

## Verification

- `ending_cinematic_runner.gd`에서 ending visual stack afterglow 확인
- `postgame_surface_runner.gd`에서 credits visual stack afterglow 확인
