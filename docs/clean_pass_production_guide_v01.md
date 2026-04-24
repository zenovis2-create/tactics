# Clean Pass Production Guide V01

## Purpose

This document defines what `clean/` means in the Farland Tactics art pipeline.

Use it after a lane already has a usable `source/` image and before any runtime extraction,
frame slicing, icon extraction, or promotion work begins.

It exists to keep cleanup work consistent across:

- character sprite sheets
- anchor character reference sheets
- prop sheets
- terrain tiles

## Stage Definition

`source/` is allowed to look like concept output.

`clean/` is not final runtime polish, but it must already be:

- structurally stable
- background-clean
- free of generation artifacts
- readable at gameplay scale
- safe to promote into downstream runtime derivatives

If a source image still depends on paper background, layout text, poster framing, or soft concept haze,
it is not ready for `runtime/`.

## Top-Level Rule

Clean pass must preserve the lane's approved silhouette and class or gameplay read.

Do not use cleanup to redesign the asset.

Allowed:

- remove background
- remove text, numbering, and panel artifacts
- stabilize proportions across frames
- reduce clutter
- tighten contour readability
- reduce FX dominance
- clarify value separation between major material zones

Not allowed:

- invent new props
- add ornament that was not in the chosen source
- repaint the asset into a different style family
- compensate for a broken silhouette with more glow or effects
- push close-up beauty treatment at the expense of map readability

## Shared Readability Rules

Every cleaned asset must satisfy all of these:

- large shapes read before medium details
- material zones separate in one glance
- contours survive size reduction
- visual noise is lower than in the source
- the asset still belongs to the same world as the current anchors

If a cleanup makes the image prettier but less legible at combat scale, it fails.

## Background Rules

- remove white, paper, poster, or concept-board backgrounds completely
- keep only the grounded shadow that is necessary for form read
- do not leave faded halos or soft residue at the contour edge
- use transparent background for cleaned outputs unless the lane-specific guide says otherwise

## Artifact Removal Rules

Always remove:

- numbering
- poster marks
- accidental letters
- layout dividers
- AI-generated duplicate fragments
- broken extra fingers, straps, or edge fragments
- unintentional object doubling

Do not keep an artifact just because it is subtle.

## Value And Material Rules

Cleanup should improve separation between the asset's main zones.

Typical target:

- primary structure reads first
- support material reads second
- accent reads last

Avoid:

- flattening the whole asset into one value block
- making accents brighter than the main shape
- adding micro-texture to compensate for weak structure

## Character Sprite Rules

For sprite sheets:

- keep one shared frame box across a lane
- keep foot pivot stable
- keep head size, weapon scale, and major silhouette hooks consistent
- reduce FX until the body still reads without spectacle
- do not let per-frame cleanup drift into a redraw of the character

The body must explain the class before any spell ring, trail, or projectile does.

## Character Sheet Rules

For turnaround or anchor sheets:

- preserve the intended `front`, `side`, and `3/4` relationship
- keep stance neutral and modeling-friendly
- remove concept-board clutter
- keep one plain studio backdrop only if the lane requires a non-transparent reference sheet

If a character sheet is meant for Rhino blockout reference, silhouette and material separation matter more than painterly flourish.

## Prop And Tile Rules

For props and terrain:

- remove illustration residue that prevents runtime reuse
- simplify outer haze and soft edge buildup
- preserve the dominant gameplay cue
- keep the cleaned asset reusable for multiple derivatives

Examples:

- shield should stay defense-first
- altar should keep one sacred focal zone
- tile should stay readable under units

## Naming Rules

Use this pattern:

- `clean/<asset_or_state>_clean_v01.png`

Examples:

- `clean/serin_idle_clean_v01.png`
- `clean/paladin_shield_clean_v01.png`
- `clean/forest_tile_01_clean_v01.png`

Do not invent new naming patterns inside a lane unless the lane already uses one consistently.

## Acceptance Checklist

A `clean/` output is acceptable only if:

- background is correctly removed or normalized
- artifacts are removed
- silhouette is tighter than the source
- gameplay or class read is stronger than the source
- material or value separation is clearer than the source
- downstream runtime extraction can start without another structural paint pass

## Priority Rule

When the backlog shows:

- missing `source`, generate first
- existing `source` but missing `clean`, do not regenerate by default

Default action for a lane with valid source is:

1. choose the best existing source
2. create the clean output
3. derive runtime outputs

Only regenerate source when the existing source fails the lane spec or cannot survive cleanup.
