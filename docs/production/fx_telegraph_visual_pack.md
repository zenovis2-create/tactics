# FX And Telegraph Visual Pack

## Purpose

This document defines the in-game FX and telegraph look for `잿빛의 기억`.
It turns the approved character portrait direction into a battlefield-readable visual effects grammar.

This is an in-game production pack.
It is not a cinematic VFX brief.

## Direction Lock

`Retro tactical telegraph clarity`

- FX should feel compatible with `/Volumes/AI/tactics/artifacts/ash15/ash15_portrait_sheet_v3.png`.
- The target is classic tactics readability first:
  - clean warning states
  - low noise
  - symbol-led effects
  - restrained warmth and controlled danger color

## Core Principles

1. `Information before spectacle`
2. `Color is never enough on its own`
3. `Effects must belong to the same world as portraits and icons`
4. `Every major state gets one dominant read`

## Layer Logic

### Targeting And Danger

- Use three-layer read:
  - low-opacity fill
  - crisp outer edge
  - simple symbol or pattern reinforcement

### Mark

- Should read as a stamped pursuit warning, not a magic aura.
- Use ring, seal, map-tick, or mark-line logic.
- Keep the mark readable over terrain without flooding the screen.

### Charge

- Should read as directional threat.
- Favor lane arrows, broken wedges, or forward-line pressure.
- Avoid giant energy trails or anime speed-line overload.

### Buff / Command

- Should read as tactical reinforcement, not spell fireworks.
- Use compact signal shapes:
  - short arcs
  - seal flashes
  - command bars
  - clean pulse rings

### Healing / Protection

- Use pale blue, gold, and soft ring geometry.
- Favor shield arcs, ward circles, and stabilizing hand-like motifs.
- Keep support FX calm and legible.

## Material And Finish

- FX edges should feel illustrated, not volumetric.
- Glow should be restrained and only used to clarify state.
- Keep effects cleaner and flatter than modern action-RPG spell VFX.
- Avoid smoke spam, bloom spam, and particle soup.

## Palette Rules

- ally support: pale blue + vow gold
- neutral information: parchment / ash / soft white
- hostile telegraph: ember red
- erasure / null states: clipped dark gray or void black used carefully
- avoid generic purple fantasy energy

## Pattern Rules

- map rings
- seal breaks
- fracture wedges
- lane arrows
- clipped circles
- stamped marks

These are preferred over vague magical swirls.

## Production Sheet Format

- Preferred output: one internal review sheet with grouped telegraph samples.
- Include:
  - move danger
  - mark
  - charge
  - command buff
  - heal / protect
- Neutral ground or parchment backing only.
- No cinematic splash framing.

## Prompting Rules

- Ask for `classic tactical JRPG telegraph concept sheet`.
- Ask for `clean readable 2D tactical overlays`, `slightly flatter illustrated finish`, and `symbol-led warning language`.
- Forbid:
  - generic purple magic
  - cinematic particle explosions
  - glossy live-service combat UI polish
  - VFX that overpower unit portraits or terrain

## Initial Production Scope

- CH01 boss mark / charge / command visual cleanup
- reusable ally support telegraphs
- reusable danger-zone overlays that match CampHub and icon grammar

## Current Production Outputs

- Hostile telegraph pack v1 implementation handoff:
  - `docs/production/hostile_telegraph_concept_pack_v1.md`
