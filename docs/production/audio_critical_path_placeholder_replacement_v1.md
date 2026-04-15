# Critical Path Placeholder Replacement v1

## Purpose

This brief narrows the game sound identity to the demo-critical cues covered by [ASH-71](/ASH/issues/ASH-71).
It sets the replacement direction for the first cues most likely to distort player perception when they still sound temporary.

Scope in this pass:

- boss warning and threat-payoff cues
- hit and miss readability
- menu confirm and cancel inside battle utility flow
- the camp-to-battle recommit cue

## Sound Identity North Star

- Battle should sound deliberate, material, and tactical before it sounds dramatic.
- Camp should sound safe enough to think in, but never sleepy or sentimental.
- The project identity is ash-memory ritual, not glossy sci-fi and not heroic fantasy brass.
- Short cues must carry meaning first. Flourish only exists where the game state truly changes.

## Music Direction

Music is not being implemented in this issue, but the replacement cues should align with the future score direction:

- Battle music: low ostinato pressure, dry percussion, restrained bowed texture, no oversized trailer pulses.
- Camp music: sparse harmonic bed, warm dust-and-paper intimacy, slower breath, reduced transient density.
- Narrative reveal music: sacred but controlled, with ember glow and memory-fracture textures rather than choir bombast.

## Emotional Audio Beats

### Boss marks a unit

- Emotion: hunted, designated, tactically exposed.
- Read: a stamped command landed on the player state.
- Avoid: monster roar, magic sparkle, reward shimmer.

### Boss pressure escalates

- Emotion: field order tightening.
- Read: the enemy plan just constrained the next decision.
- Avoid: broad cinematic rise that masks subsequent UI or hit feedback.

### Boss charge pays off

- Emotion: threat fulfilled.
- Read: a warned danger has converted into force.
- Avoid: overlong sub-heavy boom that muddies mobile playback.

### Player attack lands

- Emotion: precise execution.
- Read: contact confirmed, not celebration.
- Avoid: bright UI-like chime tails.

### Player attack misses

- Emotion: lost conversion.
- Read: action spent, no contact.
- Avoid: comedic whiff or a gesture larger than a landed hit.

### Player confirms or cancels a utility action

- Emotion: control and intent.
- Read: forward commitment or measured withdrawal.
- Avoid: any pitch contour that can be mistaken for damage or danger.

### Player leaves camp for the next battle

- Emotion: resolve after reflection.
- Read: recommitment from safety into pressure.
- Avoid: using the same attack-forward transient weight as battle hit confirms.

## Critical Cue Direction

| Cue ID | Runtime role | Direction | Clarity rule |
| --- | --- | --- | --- |
| `battle_boss_mark_warn_01` | target designation | seal stamp plus narrow ember rise | must outrank every non-boss cue in urgency |
| `battle_boss_command_warn_01` | tactical pressure | clipped barred pulse | should read as field command, not impact |
| `battle_boss_charge_impact_01` | threat payoff | forward thrust into compact impact | heavier than `battle_hit_confirm_01`, shorter than a cinematic stinger |
| `battle_hit_confirm_01` | strike landed | compact material impact with tiny bright edge | must stay tighter and more grounded than any UI confirm |
| `battle_miss_01` | strike failed | thin scrape-through or filtered air pass | must stay lighter than hit confirm |
| `ui_common_confirm_01` | battle utility confirm | restrained forward confirm | must never be brighter than hit confirm |
| `ui_common_cancel_01` | battle utility cancel | soft downward tick | must never imply punishment or danger |
| `camp_next_battle_confirm_01` | leave camp and recommit | confirm plus low pulse | should bridge safety to pressure without sounding like a hit |

## Battle Clarity Guardrails

- Boss warnings own the sharpest upper-mid presence.
- Hit confirm owns the clearest short-contact transient.
- Miss stays lower-mass and less bright than hit confirm.
- Menu confirm and cancel sit behind combat in both brightness and transient weight.
- Camp recommit can carry a warmer low pulse, but it must not impersonate hostile pressure.

## Verification

- The critical-path manifest entries should resolve to `res://assets/audio/sfx/placeholders/...` assets instead of the legacy `res://audio/sfx/*.wav` set.
- Runtime verification should exercise boss warning, hit/miss, confirm/cancel, and camp recommit cues directly.
- Any future replacement for these cue IDs should preserve the same semantic ordering and urgency hierarchy.
