# 2026-04-20 Save-Load Status Clarification

## Purpose

This document reconciles the "save/load frozen" declaration in the 2026-04-14 freeze gate review with the actual implementation state as of 2026-04-20.

---

## Why the 2026-04-14 Freeze Review Was Correct At the Time

The freeze gate review (`2026-04-14-save-load-freeze-gate-review.md`) was authored during a period when:

- A large tranche of shell, gimmick, UI, FX, and runtime asset hookup integration had just landed.
- The release-confidence sweep was validating the playable shell and runtime surfaces, not persistence semantics.
- The active risk was persistence schema churn polluting a codebase still absorbing presentation changes.
- No dedicated persistence runner or narrow save contract existed yet.

The "keep frozen" decision was sound given that context.

---

## What Has Been Implemented Since Then

The following files confirm that save/load was opened as a full tranche after the freeze period ended:

### `scripts/battle/save_service.gd`

Full disk persistence service. Implemented and complete:

- `save_progression(data, slot)` — writes `ProgressionData` to `user://saves/slot_N.tres` via `ResourceSaver`, plus a JSON sidecar for inspection.
- `load_progression(slot)` — reads slot from disk, returns fresh default on missing/corrupt data.
- `delete_slot(slot)` — removes both `.tres` and `.json` sidecar files.
- `slot_exists(slot)` — existence check via `ResourceLoader`.
- `peek_slot(slot)` — reads the JSON sidecar only (lightweight metadata preview: `exists`, `chapter`, `burden`, `trust`, `ending_tendency`, `saved_at`).

### `scripts/ui/save_load_panel.gd`

Full 3-slot save/load UI panel. Implemented and complete:

- `open_save_mode()` / `open_load_mode()` — mode switching with title update.
- `refresh_slots()` — rebuilds slot cards from `save_service.peek_slot()` data.
- Per-slot cards display: slot index, chapter, burden, trust, ending tendency, saved-at timestamp.
- Save / Load / Delete buttons with two-press delete confirmation (`_pending_delete_slot` guard).
- Signals: `save_requested`, `load_requested`, `delete_requested`, `panel_closed`.
- Null-safe: all operations guard against `save_service == null`.

### `scripts/dev/save_load_runner.gd`

Dedicated validation runner (Sprint 5-E). Covers:

- Panel snapshot key contract.
- Null service safety (no crash when `save_service` is absent).
- Save → load round-trip: verifies `burden`, `trust`, `recovered_fragments`, `unit_progression`, `snapshot_unlock_state()` semantics.
- Delete flow with two-press confirmation.
- `peek_slot()` metadata contract for both empty and populated slots.
- `save_service_connected` flag in panel layout snapshot.

### Auto-save integration in `campaign_controller.gd`

`_autosave_progression()` is wired at every inter-chapter camp transition (at least 10 trigger points across chapters CH01–CH07+). It saves to **slot 0** automatically. The method guards against null `save_service` and null `progression_service`.

### `main.gd` wiring

`SaveService` is instantiated in `_ready()` and injected into:

- `SaveLoadPanel` (`save_load_panel.save_service`)
- `TitleScreen` (via `setup_save_service()`)
- `DefeatScreen` (via `setup_save_service()`)

### `title_screen.gd` and `camp_hud.gd`

Both accept `SaveService` injection and use `slot_exists()` / `peek_slot()` to populate continue/load UI state.

### `ProgressionData` persisted schema

`progression_data.gd` is a `Resource` with full `@export` coverage. Everything serialized to disk via `ResourceSaver`:

- `burden`, `trust`, `ending_tendency`, `last_completed_ending`
- `recovered_fragments`, `unlocked_commands`
- `unit_progression`, `bond_levels`, `support_ranks`, `shared_battles`
- `ng_plus_available`, `ng_plus_run`
- `material_entries`, `stage_star_ratings`, `total_stars`
- Snapshot fields: `previous_fragment_count/ids`, `previous_command_count/ids`

This substantially exceeds the narrow schema the freeze review defined as a future precondition (chapter id + stage progress + roster + equipment + memory records). The implementation went further.

---

## Current Status by Item

| Item | Status | Notes |
|---|---|---|
| `SaveService` disk persistence | **Implemented** | save/load/delete/exists/peek — all complete |
| JSON sidecar for slot inspection | **Implemented** | written on every save |
| 3-slot `SaveLoadPanel` UI | **Implemented** | save mode, load mode, two-press delete confirm |
| Auto-save on camp transition | **Implemented** | slot 0, triggered at all inter-chapter camps |
| `SaveService` → TitleScreen injection | **Implemented** | continue/load flow wired |
| `SaveService` → CampHud injection | **Implemented** | camp save tab wired |
| `SaveService` → DefeatScreen injection | **Implemented** | defeat → load flow wired |
| Dedicated save/load runner | **Implemented** | `save_load_runner.gd`, Sprint 5-E |
| `SaveLoadPanel.tscn` scene | **Present** | `scenes/ui/SaveLoadPanel.tscn` exists |
| Chapter ID persisted in sidecar | **Partial** | `chapter` field written as empty string `""` in `_write_sidecar()`; not populated from active chapter data |
| Full shell restore verification | **Not verified** | No integration runner confirms camp/battle handoff state restores correctly end-to-end after a manual load |
| Stage progress slot differentiation | **Not visible** | Slot cards show burden/trust/ending but not stage index; multi-slot manual saves lack stage context |
| NG+ flow validation | **Not confirmed** | `ng_plus_available` and `ng_plus_run` are serialized but no runner confirms NG+ transitions survive a full save/load cycle |

---

## Remaining Verification Items

1. **Chapter ID in sidecar** — `_write_sidecar()` sets `"chapter": ""` unconditionally. A caller that passes chapter context or a post-save hook that fills it is missing. UI slot cards currently display an empty chapter field.

2. **End-to-end shell restore** — a runner or manual test confirming that loading a slot correctly restores `CampaignController` state (active chapter, stage index, camp vs battle mode) does not appear to exist yet.

3. **NG+ cycle** — `ng_plus_available` / `ng_plus_run` are exported but no runner exercises the flag transition across a save/load boundary.

4. **Slot 0 auto-save vs manual slot collision** — slot 0 is reserved for auto-save by `_autosave_progression()`, but `SaveLoadPanel` exposes all three slots (0, 1, 2) for manual operations. No guard prevents a user from manually saving over the auto-save slot. Policy should be documented or enforced.

---

## Summary

The 2026-04-14 freeze gate was correct and appropriate at the time it was written. The save/load tranche was subsequently opened and is now substantially implemented: service layer, UI panel, auto-save wiring, and a validation runner are all present. The official status as of 2026-04-20 is **implemented with known gaps** in chapter-id metadata population, end-to-end shell restore verification, and NG+ transition coverage.
