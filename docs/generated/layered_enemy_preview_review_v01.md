# Layered Enemy Preview Review V01

## Scope

Review targets:

- `Enemy Raider`
- `Enemy Skirmisher`

Reference board:

- `/Volumes/AI/tactics/docs/generated/roster_layered_preview_board_v01.png`

## Verdict

Do not continue enemy-lane generation blindly from the current preview set.

Current enemy outputs are usable as exploratory proof, but not yet acceptable as
stable hostile baselines inside the same rendering family as:

- `Rian`
- `Serin`
- `Tia`
- `Bran`

## Findings

### 1. `Enemy Raider` drifted into oversized defender-machine mass

The current `Enemy Raider` composite reads too large, too mechanical, and too
dominant relative to the ally roster.

Problems:

- front read is closer to a heavy crossbow-wall or mobile barricade than a
  compact melee raider
- weapon silhouette is too large and too front-facing
- upper armor mass reads closer to siege or defender gear than hostile melee
  infantry pressure

Required correction:

- keep `Raider` compact
- reduce front-facing gear dominance
- return to `hostile melee pressure first`
- keep `rigid authority infantry second`

### 2. `Enemy Skirmisher` drifted into rogue/brawler exposure

The current `Enemy Skirmisher` composite does not stay in the same world-space
grammar as the ally lanes.

Problems:

- torso exposure is too high
- silhouette reads closer to a rogue or arena brawler than a disciplined hostile
  skirmisher
- current weapon and outfit combination pushes the lane away from `pursuit
  hunter` and toward `edgy disposable outlaw`

Required correction:

- keep the hostile agile threat
- keep the silhouette lighter than `Raider`
- but restore disciplined hostile cloth coverage
- move away from bare-torso rogue coding

### 3. Enemy detail density is no longer aligned with the player set

Across both enemy lanes, detail concentration and material complexity are too
high in the wrong places.

Problems:

- `Raider` front view reads too gear-heavy
- `Skirmisher` contrast between exposed body and dark gear is too loud
- both enemy lanes feel less modular and less disciplined than the player
  layered baselines

Required correction:

- reduce silhouette noise
- keep large shapes first
- preserve tactical readability over ornament

## Immediate Rule Changes

### `Enemy Raider`

Keep:

- `base_body`
- `base_outfit`

Redo:

- `weapon_overlay`
- `upper_armor_overlay`

Target:

- compact sword-led hostile infantry
- no barricade-like front mass
- no defender-machine read

### `Enemy Skirmisher`

Keep provisionally:

- `anchor`
- `base_body`

Redo:

- `base_outfit`
- `weapon_overlay`
- `upper_armor_overlay`

Target:

- hostile agile pursuit hunter
- not `Tia`
- not rogue/brawler
- not exposed-arena fighter

## Working Conclusion

The enemy lanes have crossed the minimum structure threshold, but their current
visual outputs are still exploratory.

Next correct move:

1. redo `Enemy Raider` `weapon_overlay` and `upper_armor_overlay`
2. redo `Enemy Skirmisher` `base_outfit`, `weapon_overlay`, and
   `upper_armor_overlay`
3. regenerate enemy composite previews
4. review again before promoting any enemy baseline
