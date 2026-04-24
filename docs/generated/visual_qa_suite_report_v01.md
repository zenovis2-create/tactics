# Visual QA Suite Report V01

- total runners: `8`
- passed: `8`
- failed: `0`

## Runner Results

### `res://scripts/dev/chapter_visual_alignment_runner.gd`
- status: `pass`
- return code: `0`
- stdout:
```text
Godot Engine v4.6.2.stable.official.71f334935 - https://godotengine.org

[TelemetryService] Battle started: tutorial_stage
[TelemetryService] Battle started: CH03_01
[TelemetryService] Battle started: tutorial_stage
[TelemetryService] Battle started: CH06_02
[TelemetryService] Battle started: tutorial_stage
[TelemetryService] Battle started: CH07_01
[TelemetryService] Battle started: tutorial_stage
[TelemetryService] Battle started: CH09B_01
[TelemetryService] Battle started: tutorial_stage
[TelemetryService] Battle started: CH10_01
[PASS] chapter_visual_alignment_runner validated preview-to-battle family alignment.
```

### `res://scripts/dev/battle_visual_qa_runner.gd`
- status: `pass`
- return code: `0`
- stdout:
```text
Godot Engine v4.6.2.stable.official.71f334935 - https://godotengine.org

[TelemetryService] Battle started: tutorial_stage
[TelemetryService] Battle started: CH03_01
[TelemetryService] Battle started: tutorial_stage
[TelemetryService] Battle started: CH06_02
[TelemetryService] Battle started: tutorial_stage
[TelemetryService] Battle started: CH07_01
[TelemetryService] Battle started: tutorial_stage
[TelemetryService] Battle started: CH09B_01
[TelemetryService] Battle started: tutorial_stage
[TelemetryService] Battle started: CH10_01
[PASS] battle_visual_qa_runner validated live chapter battle visual contracts.
```

### `res://scripts/dev/representative_battle_visual_runner.gd`
- status: `pass`
- return code: `0`
- summary:
```json
{
  "representative_battles": [
    {
      "camera": {
        "position": [
          827.933349609375,
          238.266677856445
        ],
        "zoom": [
          0.899999976158142,
          0.899999976158142
        ]
      },
      "case": "ch07",
      "object_proximity": {
        "ch07_05_city_seal": 1,
        "ch07_05_prayer_dais": 1
      },
      "surface_family": "city"
    },
    {
      "camera": {
        "position": [
          709.166687011719,
          207.83332824707
        ],
        "zoom": [
          0.910000026226044,
          0.910000026226044
        ]
      },
      "case": "ch09b",
      "object_proximity": {
        "ch09b_05_archive_lectern": 1
      },
      "surface_family": "archive"
    },
    {
      "camera": {
        "position": [
          813.613342285156,
          275.680023193359
        ],
        "zoom": [
          0.879999995231628,
          0.879999995231628
        ]
      },
      "case": "ch10",
      "object_proximity": {
        "ch10_05_anchor_chain": 1,
        "ch10_05_bell_dais": 1
      },
      "surface_family": "final_bell"
    }
  ]
}
```
- stdout:
```text
Godot Engine v4.6.2.stable.official.71f334935 - https://godotengine.org

[TelemetryService] Battle started: CH07_05
[TelemetryService] Battle started: CH09B_05
[TelemetryService] Battle started: CH10_05
VISUAL_QA_SUMMARY={"representative_battles":[{"camera":{"position":[827.933349609375,238.266677856445],"zoom":[0.899999976158142,0.899999976158142]},"case":"ch07","object_proximity":{"ch07_05_city_seal":1,"ch07_05_prayer_dais":1},"surface_family":"city"},{"camera":{"position":[709.166687011719,207.83332824707],"zoom":[0.910000026226044,0.910000026226044]},"case":"ch09b","object_proximity":{"ch09b_05_archive_lectern":1},"surface_family":"archive"},{"camera":{"position":[813.613342285156,275.680023193359],"zoom":[0.879999995231628,0.879999995231628]},"case":"ch10","object_proximity":{"ch10_05_anchor_chain":1,"ch10_05_bell_dais":1},"surface_family":"final_bell"}]}
[PASS] representative_battle_visual_runner validated chapter-local landmark usage in representative battles.
```

### `res://scripts/dev/ch07_ritual_city_preview_runner.gd`
- status: `pass`
- return code: `0`
- summary:
```json
{
  "chapter_props": [
    "bell_frame_01",
    "city_seal_dais_01"
  ],
  "expected_animated_characters": 5,
  "family": "city",
  "preview_case": "ch07"
}
```
- stdout:
```text
Godot Engine v4.6.2.stable.official.71f334935 - https://godotengine.org

VISUAL_QA_SUMMARY={"chapter_props":["bell_frame_01","city_seal_dais_01"],"expected_animated_characters":5,"family":"city","preview_case":"ch07"}
[PASS] ch07_ritual_city_preview_runner validated ritual-city preview loading.
```

### `res://scripts/dev/ch09b_root_archive_preview_runner.gd`
- status: `pass`
- return code: `0`
- summary:
```json
{
  "chapter_props": [
    "archive_lectern_01",
    "revision_core_01",
    "truth_dais_01"
  ],
  "expected_animated_characters": 5,
  "family": "archive",
  "preview_case": "ch09b"
}
```
- stdout:
```text
Godot Engine v4.6.2.stable.official.71f334935 - https://godotengine.org

VISUAL_QA_SUMMARY={"chapter_props":["archive_lectern_01","revision_core_01","truth_dais_01"],"expected_animated_characters":5,"family":"archive","preview_case":"ch09b"}
[PASS] ch09b_root_archive_preview_runner validated root-archive preview loading.
```

### `res://scripts/dev/ch10_final_bell_preview_runner.gd`
- status: `pass`
- return code: `0`
- summary:
```json
{
  "chapter_props": [
    "anchor_chain_01",
    "bell_dais_01"
  ],
  "expected_animated_characters": 5,
  "family": "final_bell",
  "preview_case": "ch10"
}
```
- stdout:
```text
Godot Engine v4.6.2.stable.official.71f334935 - https://godotengine.org

VISUAL_QA_SUMMARY={"chapter_props":["anchor_chain_01","bell_dais_01"],"expected_animated_characters":5,"family":"final_bell","preview_case":"ch10"}
[PASS] ch10_final_bell_preview_runner validated final-bell preview loading.
```

### `res://scripts/dev/attack_camera_timing_runner.gd`
- status: `pass`
- return code: `0`
- stdout:
```text
Godot Engine v4.6.2.stable.official.71f334935 - https://godotengine.org

[TelemetryService] Battle started: tutorial_stage
[PASS] attack_camera_timing_runner validated melee, ranged, and support camera timing signatures.
```

### `res://scripts/dev/movement_animation_runner.gd`
- status: `pass`
- return code: `0`
- stdout:
```text
Godot Engine v4.6.2.stable.official.71f334935 - https://godotengine.org

[TelemetryService] Battle started: tutorial_stage
[PASS] movement_animation_runner validated visible path-step walk on player move.
```
