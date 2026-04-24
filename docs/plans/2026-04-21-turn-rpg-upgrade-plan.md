# Turn RPG Upgrade Plan

1. `Risk Forecast Cards`용 stage metadata / extraction contract를 정한다.
2. battle-start overlay 또는 briefing surface에 risk card를 추가한다.
3. dedicated runner로 risk card 노출을 검증한다.
4. action preview payload에 state-change labels를 추가한다.
5. interaction preview와 telegraph detail에 objective/pressure delta를 추가한다.
6. runner에서 damage 외 state preview가 보이는지 확인한다.
7. reward/progression path에 post-battle bonus EXP pool 계산을 추가한다.
8. low-participation / low-level unit 우선 자동 분배를 구현한다.
9. battle-end 또는 camp summary surface에 bonus EXP 결과를 노출한다.
10. progression/save runner에서 보너스 EXP persistence를 검증한다.
11. campaign summary에 narrative axis gauges용 data model을 추가한다.
12. battle / cutscene / camp 결과가 axis 변화량을 기록하게 만든다.
13. camp shell에서 gauge/band를 읽을 수 있게 노출한다.
14. camp runner에서 axis gauge 노출과 갱신을 검증한다.
15. story milestone -> combat passive card schema를 정의한다.
16. unlock payload와 camp display surface를 추가한다.
17. battle resolver에 passive card hook를 연결한다.
18. runner에서 unlock -> battle effect exposure를 검증한다.
19. 전장 규칙 template taxonomy 문서를 작성한다.
20. stage metadata 또는 authoring tag에 template id를 추가한다.
21. objective / hint / result summary phrasing을 template 기준으로 정리한다.
22. existing boss runners가 template stage에서도 PASS하는지 확인한다.
23. stage-level replay metrics schema를 정의한다.
24. telemetry/report output에 turn count / objective rate / phase timing / failure causes를 추가한다.
25. metrics export 또는 markdown summary를 추가한다.
26. benchmark/report runner에서 required keys를 검증한다.
27. hidden reward / hint cadence contract를 정의한다.
28. scout affinity / proximity / turn cadence reveal logic를 구현한다.
29. battle surface와 summary에 hint/reveal text를 연결한다.
30. runner에서 reveal timing과 hint escalation을 검증한다.
31. 모든 Wave A 기능에 대해 compact/mobile readability를 확인한다.
32. 모든 Wave A 기능에 대해 shared regression runner를 다시 실행한다.
