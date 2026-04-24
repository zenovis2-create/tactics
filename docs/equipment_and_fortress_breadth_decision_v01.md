# Equipment And Fortress Breadth Decision V01

## Decision Summary

Two decisions are now locked:

1. `field_sword_01` should stay at its current support level for now.
2. `fortress family` should keep its current breadth for now.

## Field Sword Decision

### Current Live Destinations

`field_sword_01` already has:

- sword-class weapon preview routing
- `Rian` party/detail support surface
- `CH01` camp presentation card surface

### Decision

Do **not** add another field-sword-specific UI destination immediately.

### Why

The family already proves its read in three places:

1. preview-scale equipment support
2. party/detail support
3. camp/interlude presentation

Adding another surface now would increase UI breadth before there is evidence that the current surfaces are insufficient.

### Working Rule

Keep `field_sword_01` at the current support level until one of these becomes true:

- a new equipment-specific UI surface is introduced
- a chapter-specific surface needs sword-family emphasis that current support surfaces cannot provide
- another sword-family variant appears and comparison becomes necessary

## Fortress Breadth Decision

### Current Family

The fortress family currently includes:

- `fortress_tile_01`
- `fortress_tile_02`
- `fortress_edge_01`

### Decision

Do **not** add another fortress structural support asset immediately.

### Why

The family already has:

1. ground baseline
2. ground variation
3. structural edge support

That is enough to count as a real first-pass terrain family.
The next useful evidence is chapter breadth, not asset count.

### Working Rule

Use the current fortress family in more chapter-specific surfaces first.

Only add another structural support surface if:

- repetition becomes obvious in new chapter surfaces
- a new composition needs taller or more vertical fortification language
- a route or siege mechanic cannot be communicated with the current family

## Combined Priority Rule

Until new evidence appears:

- widen **usage**
- do not widen **families**

This keeps the runtime lane from bloating faster than the validation layer.
