# Imagegen Adapter

AssetOps v1 treats image generation as an upstream source, not as a promotion
authority.

Required handoff:

- generated candidate frames must be persisted under a source candidate folder
- generated files must enter AssetOps through `intake`
- generated files must pass the same QA and policy gates as manual edits
- generated files must not be copied directly to runtime folders
