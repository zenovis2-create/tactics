# Character Anchor Knight Generation README

## Purpose

This file explains how to generate the missing `source` image for `character_anchor_knight`.

## Files

- spec: `/Volumes/AI/tactics/assets/characters/character_anchor_knight/spec.md`
- prompt pack: `/Volumes/AI/tactics/assets/characters/character_anchor_knight/prompt_pack_v01.md`
- prompt file: `/Volumes/AI/tactics/assets/characters/character_anchor_knight/generation_prompt_v01.txt`
- source output target:
  - `/Volumes/AI/tactics/assets/characters/character_anchor_knight/source/character_anchor_knight_sheet_source_v01.png`

## Execution

Use:

```bash
/Volumes/AI/tactics/scripts/dev/run_character_anchor_knight_generation.sh
```

## Requirement

This wrapper uses the CLI fallback image generator:

- `/Users/daehan/.codex/skills/imagegen/scripts/image_gen.py`

It requires:

- `OPENAI_API_KEY`

## Post-Generation Rule

After the source image exists:

1. create the `clean` derivative if needed
2. derive `runtime` outputs if the lane is promoted further
3. rerun:

```bash
/Volumes/AI/tactics/scripts/dev/refresh_missing_image_generation_backlog.sh
```
