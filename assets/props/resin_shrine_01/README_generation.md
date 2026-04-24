# Resin Shrine 01 Generation README

## Purpose

This file explains how to generate the first `source` image for `resin_shrine_01`.

## Files

- spec: `/Volumes/AI/tactics/assets/props/resin_shrine_01/spec.md`
- prompt file: `/Volumes/AI/tactics/assets/props/resin_shrine_01/generation_prompt_v01.txt`
- source output target:
  - `/Volumes/AI/tactics/assets/props/resin_shrine_01/source/resin_shrine_01_source_v01.png`

## Requirement

Use the project image-generation flow to create one CH03 forest-landmark baseline.

## Post-Generation Rule

After the source image exists:

1. create the `clean/` derivative
2. derive `runtime/` outputs
3. rerun:

```bash
/Volumes/AI/tactics/scripts/dev/refresh_missing_image_generation_backlog.sh
```
