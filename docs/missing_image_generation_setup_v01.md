# Missing Image Generation Setup V01

## Purpose

This setup makes missing image work discoverable and repeatable.

It does not generate all missing images automatically.
It prepares the project so missing lanes can be identified and queued immediately.

## Added Tools

- [build_missing_image_generation_backlog.py](/Volumes/AI/tactics/scripts/dev/build_missing_image_generation_backlog.py)
- [refresh_missing_image_generation_backlog.sh](/Volumes/AI/tactics/scripts/dev/refresh_missing_image_generation_backlog.sh)

## What The Scanner Does

It scans asset lanes under:

- `/Volumes/AI/tactics/assets/characters`
- `/Volumes/AI/tactics/assets/environment`
- `/Volumes/AI/tactics/assets/props`

For each lane with `spec.md`, it reports:

- whether source images exist
- whether clean images exist
- whether runtime images exist
- whether prompt pack exists
- whether the lane is immediately ready for source-image generation

## Outputs

Generated backlog files:

- `/Volumes/AI/tactics/docs/generated/missing_image_generation_backlog_v01.json`
- `/Volumes/AI/tactics/docs/generated/missing_image_generation_backlog_v01.md`

## How To Refresh

```bash
/Volumes/AI/tactics/scripts/dev/refresh_missing_image_generation_backlog.sh
```

## Working Rule

Before generating a new missing image:

1. refresh the backlog
2. pick only lanes marked as missing and generation-ready
3. generate into the lane's `source/`
4. derive `clean/` and `runtime/`
5. rerun the relevant runner and the headless suites
