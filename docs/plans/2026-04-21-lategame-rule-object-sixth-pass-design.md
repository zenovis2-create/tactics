# Lategame Rule Object Sixth Pass Design

**Scope:** control object 이후 phase rewrite dampening 6차

## Goal

late-game control object를 잡은 뒤에는 보스가 phase effect를 다시 켜더라도
전장 rewrite가 완전판이 아니라 `약화된 버전`으로만 재적용되게 만든다.

## Recommended Approach

- 레테: deeper shadow pursuit cell을 다시 닫지 않고 front lane만 남긴다.
- 멜키온: central revision tile은 다시 덮지 않고 flank만 남긴다.
- 카르온: bell choke를 다시 닫지 않고 bell lane move cost도 약화한다.

## Verification

- `lategame_boss_pattern_runner.gd`에 weakened rewrite assertions 추가

