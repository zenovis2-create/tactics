# Ending Memory Stamp Sixth Pass Design

**Scope:** ending/credits source memory stamp 6차

## Goal

ending/credits overlay가 색과 phase만 보여 주는 수준을 넘어서,
`어떤 결말/어떤 전환 원천`에서 나온 화면인지 source stamp로 남기게 만든다.

## Recommended Approach

- `EndingOverlay`에 `EndingSourceStampLabel` 추가
- `CreditsOverlay`에 `CreditsSourceStampLabel` 추가
- `main.gd`에서 ending type과 credits section index에 따라 stamp text 분기

## Verification

- `ending_cinematic_runner.gd`에서 `TRUE / CH10 Resolution` 확인
- `postgame_surface_runner.gd`에서 `TRUE / Witness Roll` 확인
