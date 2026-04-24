# Sprite Anchor Tia Spec

## Identity

- Asset ID: `sprite_anchor_tia_01`
- Working name: `Sprite Anchor Tia`
- Character type: playable
- Class or archetype: ranger / skirmisher / ranged hunter
- Chapter or faction: Greenwood ally roster, forest survival lane

## Purpose

- Primary use: establish the 2D battle-sprite production standard for ranged and agile ally classes
- Runtime surface: battle sprite, move baseline, ranged attack baseline
- Production role: style anchor for ranger and skirmisher-class sprites

## Sprite Pipeline Mode

- Production mode: 2D sprite sheet
- Source method: AI concept -> Krita cleanup -> Godot sprite import
- Proportion target: chibi-adjacent tactical sprite with leaner silhouette than Rian and clearer asymmetry than Serin
- Camera read target: battle-map first, portrait support second

## Visual Summary

- One-sentence pitch: a wary forest skirmisher whose bow, hood break, and asymmetrical gear make her read as a ranged hunter before personality
- Emotional read: caution, sharpness, guarded resolve
- First-read silhouette: bow curve, asymmetrical hood or shoulder break, slimmer stance
- Must-read class signal: ranged forest hunter, not a support mage and not a heavy frontline unit

## Style Rules

- Line character: clean and controlled, slightly sharper than Serin
- Shading style: restrained cel-style shading with soft painterly warmth
- Detail budget: low-to-medium; asymmetry and gear profile should do most of the work
- Chibi/stylization level: classic tactical JRPG sprite with slightly enlarged head and compact tactical body
- Forbidden polish: assassin-glamour excess, oversized cape flutter, heavy armor mass, FX-led identity

## Proportion

- Head size note: slightly oversized for expression readability
- Torso note: lean torso with asymmetrical shoulder or hood break
- Leg note: compact but agile stance
- Hand / weapon exaggeration: bow may be slightly enlarged for class readability

## Loadout

- Primary weapon: short or medium tactical bow
- Secondary item: light quiver or forest utility gear
- Shield:
- Signature prop: hood break, ranger straps, or asymmetrical cloak fragment

## Material And Color Plan

- Primary materials: practical cloth, leather straps, wood bow, light trim armor
- Accent material: small metal fastener or hunter charm
- Base palette: muted forest green, ash brown, dark leather, subdued cloth neutrals
- Accent color: restrained moss-green or moonlit green
- Forbidden colors: saturated emerald glow, bright luxury gold, neon ranger FX

## Animation Set

- Required states: `idle`, `move`, `attack`, `hit`
- Minimum states: `idle`, `attack`
- One-shot actions: `attack`, `hit`
- Looping actions: `idle`, `move`
- FX handled in character sheet or separated: projectile read is weapon-led; keep FX minimal

## Sheet Layout

- Required views or framing: front-facing gameplay sprite sequence only
- Sheet type: action sheet plus movement baseline
- Target frame count: 8-frame idle, 8-frame move, 8-frame attack
- Background: transparent or plain neutral backdrop during concept stage
- Transparent export needed: yes

## Runtime Readability

- Zoomed-out read goal: instantly distinguish Tia from Serin and Rian through bow silhouette and asymmetrical ranger posture
- Token/icon implication: bow curve and hood/shoulder shape should remain readable in token-size derivatives
- Failure conditions: reads like generic fantasy archer girl, reads like dagger rogue, silhouette collapses without green accents

## AI Image Generation Brief

- Use case: stylized-concept
- Prompt seed: classic tactical JRPG ranger sprite sheet, wary female forest skirmisher with compact tactical proportions, short bow, asymmetrical hood or mantle break, muted forest palette, readable ranged silhouette
- Must include: clear bow read, lean silhouette, ranger asymmetry, restrained forest utility gear
- Must avoid: giant cloak arcs, long dramatic sniper bow, glossy anime hunter styling, hyper-detailed straps, oversized FX trails

## Krita Notes

- Cleanup tasks: unify bow angle, head scale, and asymmetrical cloth read across frames
- Separation tasks: keep bow silhouette clearly separated from body and background
- Text removal or label cleanup: remove any generated numbering or poster-like arrangement marks
- Frame consistency risks: drifting bow size, unstable hood silhouette, inconsistent hand spacing

## Godot Notes

- Import target: battle character sprite sheet
- Sprite slicing plan: fixed frame box and fixed foot-center pivot
- Animation names: `idle`, `move`, `attack`, `hit`
- Loop/non-loop notes: `idle` and `move` loop
- Test scene: battle scene next to Serin and Rian over forest and plain tiles

## Review Checklist

- Does Tia read as ranged hunter first?
- Is the bow visible at gameplay scale?
- Does the asymmetry help without becoming noisy?
- Are the frames stable without depending on FX?
- Does the sprite still belong to the same world as Serin and Rian?

