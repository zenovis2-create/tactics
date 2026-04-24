# Rhino Production Rules

## Purpose

These rules define how Rhino should be used for Farland Tactics asset work.
Rhino is not being used as a final sculpting vanity tool. It is being used as a repeatable
shape, turntable, and rendering workbench for readable game assets.

## Working Principles

- Block out large forms first.
- Preserve editability over clever construction.
- Keep naming consistent.
- Prefer stable layer, view, and export conventions over ad hoc scene organization.
- Each asset should be easy to reopen, adjust, and rerender.

## Default Character Workflow

1. Start from spec sheet.
2. Block the body in simple masses.
3. Add armor and equipment as separate readable components.
4. Assign layer groups by material and function.
5. Create named views.
6. Render `front`, `side`, and `3/4`.
7. Save review notes before moving to finer revision.

## Modeling Rules

- No micro-detail during blockout.
- No decorative edge damage during base pass.
- No tiny floating ornaments.
- No geometry that exists only for close-up beauty shots.
- Use thick readable forms for armor edges and shield rims.
- Avoid topology complexity unless it supports silhouette or render readability.

## Layer Rules

Required top-level layers for character work:

- `CHAR_BODY`
- `CHAR_ARMOR`
- `CHAR_CLOTH`
- `CHAR_LEATHER`
- `CHAR_WEAPON`
- `CHAR_SHIELD`
- `CHAR_ACCENT`
- `GUIDES`
- `LIGHTS`

## View Rules

Every anchor character file must contain these named views:

- `CHAR_FRONT`
- `CHAR_SIDE`
- `CHAR_THREE_QUARTER`

Optional:

- `CHAR_BACK`
- `CHAR_CLOSE_HEAD`

## Render Rules

- Background should be plain and non-distracting.
- Render output should emphasize silhouette and material separation.
- Use consistent framing across revisions.
- Do not hide readability problems with dramatic lighting.
- Favor one soft key light and one weak fill before adding any stylized extras.

## File Naming

For anchor character:

- Rhino file: `character_anchor_knight_v01.3dm`
- Render folder: `renders/character_anchor_knight/v01/`
- Export folder: `exports/character_anchor_knight/v01/`

## Revision Rules

- Increment render folders by version.
- Log what changed and why.
- Keep rejected versions if they help style comparison.
- If a render looks good at close range but fails at reduced size, it fails review.

## Review Questions

- Does the class read instantly at small size?
- Is the silhouette stronger than the surface detail?
- Are the material zones obvious?
- Is the shield large enough to matter visually?
- Does the asset still feel like part of the same world as existing props and tiles?

