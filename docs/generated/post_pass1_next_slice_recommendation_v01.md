# Post Pass 1 Next Slice Recommendation V01

## Current Position

`live family usage expansion` pass 1 is complete.

That means the project is no longer deciding whether the first authored usage
gap should be closed.

It is deciding what the next slice should be.

## Recommended Default

Recommended default:

- do not automatically start pass 2

Instead:

- treat the current state as a stable checkpoint
- choose the next slice deliberately

## Valid Next Slices

### 1. Selective Expansion Pass 2

Use this only if the project wants more surface coverage for:

- `well`
- `shrine`
- `keeper_lectern`
- `route_marker`
- `latch`

This is the right choice only if there is a concrete destination in mind.

### 2. Runtime/UI Polish Slice

Use this if the goal is:

- presentation cleanup
- surface consistency
- handoff polish

This is the lowest-risk continuation.

### 3. Engineering Hygiene Slice

Use this if the goal is:

- shutdown warning investigation
- runner cleanup
- runtime ownership debugging

This should remain separate from art/runtime production unless explicitly chosen.

## Recommended Priority

If no new product constraint has appeared, use this order:

1. runtime/UI polish
2. selective expansion pass 2
3. engineering hygiene

## Working Conclusion

The best next move is not to continue pass 1 indefinitely.

The best next move is to start a new slice on purpose.
