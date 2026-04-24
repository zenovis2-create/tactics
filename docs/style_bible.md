# Farland Tactics Art Style Bible

## Purpose

This document defines the visual rules that all game assets must share.
It exists to keep character, equipment, props, and environment pieces inside one readable
world instead of drifting into separate art styles.

## Core Direction

- Style family: original hybrid inspired by classic tactical RPG readability
- Asset priority: tactical-map readability first, close-up appeal second
- Tone: painterly diorama
- Rendering target: stylized non-photoreal 3D with soft hand-painted character
- Visual promise: every asset should look like it belongs to the same handcrafted war-table set

## Surface Split

This project uses different production lanes by surface:

- Characters may use a dedicated `2D sprite-sheet` pipeline when that improves gameplay readability and production speed.
- Props, tiles, maps, and environment support art remain compatible with the `Rhino + Krita + Godot` pipeline.

The art direction must stay shared even when the toolchain differs.

## Global Shape Language

- Start from 3 major masses before any secondary detail.
- Silhouette must read in thumbnail size.
- Forms should be broader, thicker, and simpler than realistic equivalents.
- Avoid thin, delicate, or high-frequency details unless they survive map-scale reduction.
- Armor, weapons, and props should favor strong outside contour over internal patterning.

## Proportion Rules

- Character proportion: medium stylized between chibi and semi-real
- Head: slightly enlarged for readability
- Torso: broad and compact
- Legs: shortened relative to realistic anatomy
- Hands, boots, shields, pauldrons, and weapons may be slightly oversized if it improves class readability

## Material Language

Limit each asset to a small material family.

- Primary hard material: iron, steel, bronze, stone, or wood
- Secondary support material: leather or cloth
- Accent material: gem, enamel, or painted heraldic mark

Rules:

- One dominant material, one support material, one accent is preferred.
- Material zones must be easy to separate by eye.
- Surface breakup should come from large wear patterns, not micro-noise.

## Color Rules

- Base palette: muted, low-to-mid saturation
- Accent policy: one strong accent color per asset
- Current anchor accent: deep navy
- Avoid rainbow distribution inside a single asset
- Neutral metal and leather should carry most of the design load

## Detail Rules

Allowed:

- Large heraldic forms
- Big panel breaks
- Controlled edge wear
- One focal emblem
- Thick cloth folds

Disallowed by default:

- Fine chain links
- Tiny scripture
- Lace-like filigree
- Hair-width straps
- Dense trim patterns
- Overlapping micro-plates that read as visual noise

## Character Rules

- Class readability must survive at combat-map scale.
- Face design is secondary to posture, silhouette, and gear profile.
- Every class should have one dominant silhouette hook.
- Hair should read in simple clumps.
- Cloth should reinforce motion or rank, not become the main silhouette.
- Sprite characters should favor clean line discipline and restrained shading over glossy anime polish.
- Character FX should support the body silhouette, not replace it.

## Equipment Rules

- Weapons should read by class in one glance.
- Shields should be bold enough to act as a class identifier.
- Ornament should be concentrated in one focal area, not spread evenly.
- Gear should look manufacturable inside the same world as the environment art.

## Environment And Prop Rules

- Architecture and props should reuse the same material discipline as characters.
- Interactive objects need a bigger iconographic read than realistic scale would suggest.
- Props should feel like they were made by the same cultures that made the armor and weapons.

## Render Rules

- Neutral studio or plain backdrop for modeling reference renders
- Soft directional key light with readable shadow planes
- No heavy bloom, no dramatic rim-light dependency
- Present forms clearly in `front`, `side`, and `3/4`
- Use painterly, restrained material response rather than glossy realism

## First Anchor Character

- Type: worn veteran knight
- Loadout: one-handed sword and large shield
- Hair: short dark hair
- Face: clean-shaven, restrained, tired
- Armor: heavy armor
- Accent color: deep navy

This anchor character is the baseline for future human-scale assets.
