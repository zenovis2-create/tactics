# Art Runtime Review Phase Transition V01

## Purpose

This document records the decision to keep current runner shutdown warnings as
non-blocking and to return the main working lane to art/runtime review.

It exists so the project does not keep mixing:

- primary art/runtime production work
- secondary engineering-hygiene investigation

as if they had the same priority.

## Current Decision

Decision:

- continue treating the current shutdown warnings as `non-blocking`
- return the main lane to `art/runtime review`

This is a prioritization decision, not a claim that the warnings are solved.

## Why This Is The Correct Transition

### 1. Functional validation still passes

The affected runners still complete their intended validation:

- [ch07_procession_control_runner.gd](/Volumes/AI/tactics/scripts/dev/ch07_procession_control_runner.gd)
- [ch08_route_pressure_runner.gd](/Volumes/AI/tactics/scripts/dev/ch08_route_pressure_runner.gd)

### 2. The warning investigation has already reduced the problem space

Current weaker suspects:

- root-level battle lifetime
- direct battle child/service lifetime
- `BattleArtCatalog` as a sole cause
- `BattleBoard` local cache ownership
- `BattleHUD` direct ownership

Current stronger suspects:

- broader non-battle-root resource ownership
- remaining static or singleton-style cache owners

That is enough narrowing for now.

### 3. Art/runtime work has a clearer immediate payoff

The repository already has:

- live runtime family expansion
- production icon promotion
- chapter landmark coverage
- clean/runtime asset completion

Those are the main production gains.

The shutdown warnings are real, but they are not currently blocking:

- family promotion
- routing validation
- stage objective validation

## What Stays Active

Active primary lane:

- art/runtime review

Active secondary lane:

- shutdown warning follow-up as engineering hygiene

## What This Means In Practice

From this point:

1. do not stop art/runtime review work because of the current warnings alone
2. only reopen deep warning investigation when:
   - warnings expand
   - warnings affect non-test flows
   - or a dedicated engineering hygiene pass is explicitly chosen

## Companion References

- [runner_shutdown_warning_review_v01.md](/Volumes/AI/tactics/docs/generated/runner_shutdown_warning_review_v01.md)
- [runner_shutdown_warning_followup_v01.md](/Volumes/AI/tactics/docs/generated/runner_shutdown_warning_followup_v01.md)
- [live_runtime_family_summary_v01.md](/Volumes/AI/tactics/docs/generated/live_runtime_family_summary_v01.md)

## Working Conclusion

The current shutdown warnings should stay tracked, but they should not own the
main lane.

The main lane is back to art/runtime review.
