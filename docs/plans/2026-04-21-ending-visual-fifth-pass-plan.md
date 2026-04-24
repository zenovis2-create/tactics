# Ending Visual Fifth Pass Plan

1. runner에 phase label 기대값을 먼저 추가해 실패를 확인한다.
2. `Main.tscn`에 ending/credits phase label 노드를 추가한다.
3. `main.gd`에서 ending type, credits section index에 맞는 phase text를 연결한다.
4. ending/postgame runner를 다시 실행해 PASS를 확인한다.
