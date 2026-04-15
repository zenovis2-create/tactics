# CampHub Records M2 Design

## Goal

Add a minimal `records` layer to the Chapter 1 CampHub so the M2 shell shows actual memory, evidence, and letter content instead of only party and inventory summaries.

## Scope

- Keep the existing CampHub structure lightweight.
- Add one new top-level section: `records`.
- In `records`, show three grouped lists:
  - `memory`
  - `evidence`
  - `letters`
- Populate the lists with Chapter 1 data only.

## Why this shape

- It matches the current M2 shell without forcing a full archive system.
- It satisfies the current `camp_ui_spec.md` requirement that camp acts as a story hub.
- It avoids premature save/load, pagination, filtering, or post-MVP content systems.

## Data source

- The CampHub payload should come from `CampaignController`, not UI-local hardcoding.
- Chapter 1 entries can be represented as small in-controller constants gated by reached stage.
- The current M2 shell only needs the final Chapter 1 camp payload:
  - `mem_frag_ch01_first_order`
  - `flag_evidence_hardren_seal_obtained`
  - one Serin letter entry

## Verification

- `m3_ui_runner.gd` should assert:
  - `memory_entries`
  - `evidence_entries`
  - `letter_entries`
  exist and are non-empty in camp mode.
