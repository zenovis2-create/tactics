# Manual Edit Adapter

Manual pixel edits enter AssetOps through the same source candidate contract as
generated images.

Required handoff:

- keep original edit exports untouched
- export one PNG per frame
- use deterministic frame ordering in filenames
- run `intake` before QA or promotion planning
