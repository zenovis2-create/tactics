# Status Icon Drift Eighth Pass Plan

1. `status_visual_runner.gd`에 icon drift 기대값을 먼저 추가한다.
2. `unit_actor.gd`에 icon tween/profile/snapshot surface를 추가한다.
3. 상태별 cadence를 최소 범위로 분기한다.
4. runner를 다시 실행해 PASS를 확인한다.
