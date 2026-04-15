# CH02~CH06 Stage-Visual Map Production Kit

## Purpose

This document owns map-side production support for `CH02` through `CH06`.

It exists to help gameplay, UI, and environment production promote the current shell stages into readable missions with stronger gimmick identity.

This document defines:

- per-chapter visual identity for battlefield production
- per-map prop kits and landmark priorities
- interaction marker rules for objects, hazards, and objectives
- environmental readability rules that support gameplay gimmicks
- cross-team handoff notes for [ASH-12](/ASH/issues/ASH-12)

Out of scope:

- story rewrites
- dialogue revisions
- combat-system redesign
- marketing or store-facing art direction

Source-of-truth priority:

1. stage shell data in `data/stages/ch02_01_stage.tres` through `ch06_05_stage.tres`
2. chapter canon and rewards in `phase2.md`, `phase3+item.md`, `phase4.md`, `phase5+@.md`, `phase6.md`
3. chapter rule identity in `docs/plans/2026-04-12-systems-chapter-rule-cards.md`
4. this document for map-side production guidance

If this document conflicts with stage IDs, cutscene IDs, or hard win/loss condition wiring, stage data wins.

## Production Goals

- Make each chapter readable in one screenshot.
- Make interactables recognizable before the player taps them.
- Make risk zones legible through environment language even before FX polish lands.
- Give [ASH-12](/ASH/issues/ASH-12) concrete object and terrain guidance instead of abstract gimmick notes.

## Global Marker Language

Use these rules across `CH02` through `CH06`.

| Marker family | Visual rule | Player meaning |
| --- | --- | --- |
| primary objective | tallest silhouette, brightest local contrast, one clear faction color accent | this advances the map |
| optional reward route | visible but offset from main lane; reached through elevation, side corridor, or suspicious prop cluster | this is risky but rewarding |
| interactable machinery | large base plate, simple top shape, readable from zoomed-out camera | this can be activated |
| hazard preview | floor tint plus environmental cause nearby | this tile will become dangerous |
| safe cover / hold tile | clean edge language, waist-high silhouette, unobscured footprint | this is a planned defensive spot |
| rescue / civilian anchor | warm cloth, human-scale props, less militarized silhouette | protect or reach this target |
| investigation / evidence point | focused light, document clutter, deliberate framing object | inspect this, not the whole room |

Marker color hierarchy:

- `amber`: interactable object or machine
- `red`: imminent danger or active hostile zone
- `cyan`: route aid, water control, or tactical state shift
- `white`: evidence, memory, or truth-bearing object
- `green`: rescue, survival, or ally-safe anchor

Do not place two unrelated marker families on the same prop silhouette.

## Interaction Readability Rules

### 1. Every interactable needs a world-shape identity before it gets an icon

- levers should read as vertical handles on anchored housings
- gates should read as destination blockers with visible locking mechanics
- shrines and evidence points should read as tabletop or altar-height focal objects
- artillery, flood controls, and beacon devices need oversized mechanical profiles

### 2. Optional routes need environmental foreshadowing

- use sightline placement, broken walls, ladder reveals, or prop trails
- do not hide reward routes behind blank walls with no clue
- if a route is secret, give at least one of: crack, airflow, glow, or witness dialogue support

### 3. Hazard states must have a cause in the environment

- artillery zone: battery, barrel, aiming frame, or signal post in view
- flood shift: sluice, gate wheel, spill channel, or water stain
- trap field: snare stake, resin patch, tripwire post, or disturbed ground
- ash / fire spread: ember trough, collapsed brazier, smoke vent, or burning shelf

### 4. The player should distinguish cover from clutter

- cover props are broad, chest-high, and aligned to tiles
- clutter props are smaller, noisier, and pushed to cell edges
- never let decorative debris mimic full-tile collision unless it matters tactically

## Chapter Variety Rules

### CH02 Broken Fortress

- Dominant feeling: rescue under smoke and masonry pressure
- Dominant landmark language: broken fortifications, signal posts, chapel remnants, iron gate controls
- Optional route identity: watchtowers, armories, drainage runs, command-room secrets
- Risk language: archery lanes, siege angle, cracked stone, exposed parapets

### CH03 Greenwood Ambush

- Dominant feeling: route doubt, snares, concealed hostility
- Dominant landmark language: roots, thickets, hunter rigs, resin shrines, hidden trail markers
- Optional route identity: lookout trees, game paths, concealed caches, altar-side shortcuts
- Risk language: tripwire stakes, disturbed mud, fresh cuts on bark, resin glow

### CH04 Drowned Monastery

- Dominant feeling: sacred architecture destabilized by water and false mercy
- Dominant landmark language: cloister columns, bells, floodgates, purification basins, relic altars
- Optional route identity: side chapels, submerged store rooms, service ladders, sealed reliquaries
- Risk language: wet stone, tide marks, spill channels, corrupted sanctum residue

### CH05 Gray Archive

- Dominant feeling: collapsing truth under seal pressure and fire
- Dominant landmark language: iron shelving, codex chains, furnace vents, scholar desks, sealing frames
- Optional route identity: side stacks, hidden shelves, caged lifts, reading lofts
- Risk language: smolder lines, seal glyphs, blocked stairwells, ash fall

### CH06 Valtor Iron Fortress

- Dominant feeling: disciplined siege pressure, artillery prediction, stubborn defense
- Dominant landmark language: trenches, batteries, chain gates, armories, oath halls, ramparts
- Optional route identity: bunkers, collapsed towers, hidden armories, officer stores
- Risk language: sighted battery arcs, blast scoring, breached walls, chain-lift mechanisms

## Per-Map Production Kit

### CH02_01 Border Smoke

Map role:

- rescue opener for the fortress chapter

Prop priorities:

- smoke braziers and low-burning cart wrecks
- two isolated militia hold points with broken shields
- northeast signal tower silhouette visible from spawn
- trenchline markers that imply fallback direction

Marker guidance:

- rescue anchors use `green` cloth strips and small lanterns
- signal tower cache route should be visible from early turns
- enemy ranged pressure should be framed by broken crenellation gaps, not hidden off-camera

Environment rules:

- smoke tiles need thin vertical plumes, not opaque fog walls
- protect one clean lane between militia positions so rescue intent is legible
- do not overfill the map with rubble; rescue reading matters more than ruin density

### CH02_02 Broken Outer Wall

Map role:

- outer-wall breach and siege-lane education

Prop priorities:

- disabled ballista frames on raised pads
- west-side ladder or stair access language
- fallen masonry that creates distinct breach mouth
- one visible supply crate behind west battery

Marker guidance:

- batteries should use `amber` machinery bases and `red` firing arcs
- breach route should be the brightest stone break on the board
- west flanking reward route should look tempting but exposed

Environment rules:

- elevated threat positions must have clear shadow/silhouette separation
- reserve the cleanest parapet geometry for true tactical tiles
- decorative wall chunks should not look like climbable stairs unless they are playable

### CH02_03 Remaining Knights

Map role:

- rescue pressure with chapel-side convergence

Prop priorities:

- three stranded knight clusters with unique posture props
- southern armory door or lockbox language
- chapel front as final regroup landmark
- one officer corpse or dropped key trail near south corridor

Marker guidance:

- rescued-knight route should chain toward chapel through repeated shield/blood trail cues
- armory chest needs lock silhouette distinct from generic supply crate
- key-holder clue should be environmental even before dialogue

Environment rules:

- chapel tile should read safer and cleaner than battlefield tiles around it
- preserve multiple rescue vectors; do not let debris imply only one valid path
- use banners or prayer stands to differentiate regroup zone from ordinary cover

### CH02_04 Under the Iron Gate

Map role:

- tunnel-control puzzle and secret-route teaching

Prop priorities:

- three lever or control-node housings with shared design family
- iron gate mechanism visible in center space
- drainage channel or runoff grates at southwest hidden route
- cracked wall panel with airflow cue

Marker guidance:

- control devices use `amber` with iron braces and readable handle tops
- hidden drain-wall route gets no icon until discovered, but does get crack, dripping water, and empty-sound framing
- gate-open progress should feel mechanical, not magical

Environment rules:

- tunnels need strong floor-edge contrast to prevent muddy pathing read
- interactables should sit in shallow alcoves so their tile ownership is obvious
- save the brightest cyan accent for the true central gate machine

### CH02_05 Banner of Hardren

Map role:

- fortress recapture boss stage with side-beacon control

Prop priorities:

- east and west beacon towers
- central plaza flagstone ring for boss space
- command-room door or wall panel that can plausibly hide a secret chest
- defensive statue or banner mast that sells fortress identity

Marker guidance:

- beacon towers should match each other exactly so dual-control logic is intuitive
- central plaza should be more open than prior maps to read boss motion
- secret command-room reward needs a locked-room silhouette even before it opens

Environment rules:

- the plaza must read as a military courtyard, not generic castle floor
- keep beacon approach lanes asymmetric enough that each side feels like a choice
- do not let boss props obscure the visual state of tower ownership

### CH03_01 Lost Forest

Map role:

- forest-entry uncertainty and route doubt

Prop priorities:

- split trail markers with conflicting path comfort
- low hunter totems or cut bark clues
- one obvious chest placed on a path that feels slightly wrong
- canopy holes that create readable light pools

Marker guidance:

- safe route cues should be weaker than in fortress maps; uncertainty is the point
- hazard hints come from bark cuts, bent brush, and recent tracks
- chest route should suggest value but not safety

Environment rules:

- forest clutter must never hide full-tile occupancy
- keep walkable trail edges lighter than impassable thicket edges
- avoid uniform green noise; use lane-specific foliage value shifts

### CH03_02 Snare Line

Map role:

- trap literacy and scouting punishment

Prop priorities:

- snare posts, rope anchors, and disturbed earth clusters
- one side trail with a visible hunter cache
- thicket choke points that imply ambush
- refugee trace props pointing toward the lower trail

Marker guidance:

- trap cues must be readable without requiring icon spam
- use repeated prop grammar so the player learns what a suspicious tile looks like
- cache reward route should sit just past a suspicious zone to reinforce the lesson

Environment rules:

- traps need at least one off-tile tell visible from normal zoom
- do not place decorative sticks that resemble armed snares in safe zones
- keep the lower trail distinct in value so escort/rescue routing reads quickly

### CH03_03 Refugee Column

Map role:

- moving-rescue pressure through muddy lanes

Prop priorities:

- refugee bundles, handcarts, dropped blankets
- mud ruts that suggest the intended movement lane
- one side cache or relief crate on a slower route
- wildfire residue that points toward the basin

Marker guidance:

- civilian route anchors use `green` cloth and domestic prop scale
- mud hazard should read as delay, not instant death
- side reward route needs emotional justification: supplies, not treasure theater

Environment rules:

- foreground clutter should enhance vulnerability, not block touch readability
- keep at least one refuge pocket wide enough for regrouping
- use darker mud centers with cleaner edge stones so movement costs feel fair

### CH03_04 Echo of Wildfire

Map role:

- resin-shrine interaction map with escalating environmental tension

Prop priorities:

- paired shrine devices sharing one visual language
- resin pools with reflective or glowing edge treatment
- burnt tree ribs or charred altar frames
- altar-side shortcut props if a flank route exists

Marker guidance:

- shrine devices use `white` plus `amber`, not pure religious gold; this is investigation under threat
- resin danger gets warm glow beneath surface, distinct from normal water
- interaction points need cleaner surrounding ground to support tap precision

Environment rules:

- resin patches should look sticky and explosive, not like plain swamp
- reserve the strongest white contrast for true shrine objectives
- charred set dressing should frame combat space, not create fake traversable routes

### CH03_05 Resin Shrine

Map role:

- chapter boss altar with hazard memory

Prop priorities:

- central shrine platform
- resin-fed braziers or gutters around the arena
- flank debris that creates partial cover without hiding the boss
- one or two sacrificial posts or hunter trophies

Marker guidance:

- boss floor should be readable even when resin FX layers on top
- flanks should advertise whether they are safe burst windows or bait
- shrine center needs unmistakable sacred-threat silhouette

Environment rules:

- do not overcrowd the arena with roots or hanging props
- maintain one clear perimeter lane for repositioning reads
- boss arena lighting should contrast warm resin threat against cool forest shadow

### CH04_01 Flooded Cloister

Map role:

- water-state introduction inside sacred ruins

Prop priorities:

- toppled cloister columns and half-submerged pews
- shallow-water edge stones
- reliquary chest or supply crate on a dryer ledge
- sightline to the next bell or tower structure

Marker guidance:

- water traversal tiles use `cyan` edge shimmer, not bright fill
- high-ground dry pockets should read as tactical rest points
- optional reward routes should feel like recovered monastery storage, not random loot

Environment rules:

- water depth shifts need obvious tonal bands
- submerged clutter must not hide tile borders
- preserve architectural symmetry where possible so the monastery still feels designed

### CH04_02 Forgotten Belfry

Map role:

- vertical signal map with mist pressure

Prop priorities:

- bell frame or rope mechanism
- stair, ladder, or lift silhouette readable from spawn
- mist vents or incense basins
- side chapel or store room with optional cache

Marker guidance:

- the belfry objective should dominate the skyline
- mist is concealment language, not full obscuration
- side cache should sit where the player chooses height control over speed

Environment rules:

- vertical route choices must be legible through stair geometry
- keep bell machinery visually separate from generic monastery clutter
- mist layers should sit low enough that props still silhouette cleanly

### CH04_03 Floodgate Control

Map role:

- mechanical water-control puzzle

Prop priorities:

- paired floodgate wheels or lever columns
- visible spill channels and retention basins
- bridge or stepping-stone lane that changes meaning once controls are active
- service platform with maintenance props

Marker guidance:

- true flood controls use `cyan` plus worn brass
- water redirection should be hinted by channel layout before activation
- secondary maintenance objects must not look like the main controls

Environment rules:

- channels should visibly connect cause and effect
- wet hazard tiles need different treatment from purified tiles used later
- leave enough negative space around the controls for combat readability

### CH04_04 Relic Chamber

Map role:

- purification chamber with object priority under pressure

Prop priorities:

- relic pedestals or seal nodes
- purification basins with cleaner geometry than earlier flood tech
- side reliquary or chamber niche for hidden bonus
- ceremonial floor rings that imply safe activation spots

Marker guidance:

- purified surfaces should shift toward pale `white/cyan`, clearly separate from corruption tones
- relic targets need strong tabletop read and a small sacred halo
- hidden reward logic should come from mismatched banners, misaligned altar pieces, or overlooked side-chapel geometry

Environment rules:

- chamber floor should feel intentional and puzzle-like, not chaotic ruin
- avoid too many broken columns; line-of-play must stay clear
- keep the best visual contrast for actual purification targets

### CH04_05 Sunken Altar

Map role:

- boss arena where faith-space and flood-space collide

Prop priorities:

- central altar platform with visible water damage
- perimeter channels or collapsing tiles
- ruined statuary framing side lanes
- one relic remnant or bell shard as chapter memory anchor

Marker guidance:

- boss-safe versus flood-risk zones must read from floor pattern alone
- altar center needs enough empty space for animation readability
- flank props should support repositioning, not trap the camera in clutter

Environment rules:

- use reflected light sparingly so boss telegraphs stay legible
- the altar should feel sacred but compromised, not just wet
- keep one memorable silhouette piece behind the boss for encounter identity

### CH05_01 Ash Gate

Map role:

- archive exterior breach with ash pressure

Prop priorities:

- burned gatehouse frame
- ash drifts and scorched archive crates
- one visible side gate or collapsed scribe post
- chained doors hinting at sealed knowledge deeper inside

Marker guidance:

- ash hazard uses desaturated warm tones, not forest-fire orange
- the route inward should feel narrow and urgent
- any chest or side cache should read as archived supplies, not dungeon treasure

Environment rules:

- ash tiles should not erase unit silhouettes
- burned props need stable shape language despite damage
- keep gate breach as the main visual focal line

### CH05_02 Forbidden Stacks

Map role:

- stack maze with seal and fire pressure

Prop priorities:

- tall shelving that creates lane identity
- hanging seal frames or chained catalog markers
- smoldering ladder or stair access
- side reading nook or caged stack with optional reward

Marker guidance:

- sealed zones need `white` glyph structure with hostile edge treatment
- burning stacks should advertise spread direction through ash fall and ember drift
- optional route should be visible through shelf gaps before it is safe

Environment rules:

- shelf tops must not hide targetable spaces from the camera
- lane distinction comes from shelf orientation and floor runners, not color alone
- do not use identical prop density in every aisle

### CH05_03 Burning Stair

Map role:

- vertical escape/advance under spreading ember pressure

Prop priorities:

- staircase silhouette visible across multiple elevations
- collapsed book carts and fallen beams
- ember troughs or broken lantern chains
- side platform with a desperation supply cache

Marker guidance:

- up-route should always be readable even when fire pressure escalates
- ember hazards need directional language, not just red tiles
- side cache should reward timing and bravery, not random detour

Environment rules:

- vertical transitions need clean landing tiles
- smoke or ember FX must not hide stair endpoints
- leave one pause pocket per level so routing decisions are possible

### CH05_04 Truth Shelf

Map role:

- investigation-and-unseal climax for the archive chapter

Prop priorities:

- codex shelf or truth dais as the primary evidence landmark
- paired seal devices with shared silhouette family
- chained documents, index rails, and archival braces
- hidden compartment logic tied to shelf alignment or codex locking

Marker guidance:

- evidence-bearing objects use `white` lighting and cleaner prop staging than combat clutter
- seal devices need unmistakable interaction footprints
- false-interactable archive clutter should be minimized; only a few props can call for attention

Environment rules:

- this map needs more negative space than other archive maps so evidence reads as important
- shelf geometry should create lines of suspicion, not maze fatigue
- save the strongest contrast for the real truth-bearing surface

### CH05_05 Ash Escape

Map role:

- boss or escape climax through a collapsing archive edge

Prop priorities:

- collapsing exit frame or breach corridor
- falling ash vents and broken catalog towers
- side braces or gates that imply alternate movement lanes
- boss arena center with enough open ground to read seal pressure

Marker guidance:

- exit logic and boss pressure must coexist without confusing the player about priorities
- escapeward environmental pull should be strong even before UI guidance
- hazard cues should escalate from falling debris and ash wash, not random tile color shifts

Environment rules:

- keep collapse silhouettes big and directional
- do not let fire VFX overwhelm interactable or boss telegraph reads
- final lane should look barely viable, which supports the chapter tone

### CH06_01 Beyond the Smoke

Map role:

- siegefield opener with artillery literacy

Prop priorities:

- trenchline geometry
- two signal posts or targeting masts
- broken tower cache route
- shield wrecks as true cover landmarks

Marker guidance:

- artillery danger must be foreshadowed by aiming hardware or observers
- observation-tool reward route should be visible but time-costly
- cover props need strong rectangular silhouettes

Environment rules:

- trench edges must read as movement tax, not impassable walls
- bombardment tiles should have scorched perimeter clues even before the preview lands
- keep the battlefield wider and more horizontal than prior chapters

### CH06_02 Battery Line

Map role:

- multi-battery lane control and flanking education

Prop priorities:

- west, center, and east battery emplacements
- chain-lift gate or winch mechanism
- engineer bunker with side reward
- destructible barricades that clearly differ from permanent walls

Marker guidance:

- battery emplacements should be the largest machinery silhouettes in the chapter so far
- chain-lift mechanism must look like a navigation objective, not scenery
- destructible barricades need crack/band/brace language distinct from static masonry

Environment rules:

- route asymmetry is important; each lane should sell a different risk profile
- do not hide the bunker route behind same-value wall clutter
- keep artillery machinery readable from zoomed-out play

### CH06_03 Quartermaster Depths

Map role:

- prison-storehouse rescue and push-cart problem solving

Prop priorities:

- prison doors and control console
- supply carts that can plausibly be pushed
- fuel barrels or oil stores for fire creation
- hidden smithy storage behind thin iron wall

Marker guidance:

- movable carts need chunkier wheels and handle bars than static carts
- prison-control objects use `amber` and iron cage silhouettes
- hidden storage route should be foreshadowed by hollow-wall treatment and old smithing props

Environment rules:

- tight corridors need clean floor separation for touch precision
- pushable objects must not blend with cover clutter
- rescue targets should sit in human-readable cells, not behind heavy overlay noise

### CH06_04 Oath Hall

Map role:

- inner-fortress record seizure and emotional confrontation map

Prop priorities:

- oath standards, old banners, or lance racks
- paired document vaults or map cases
- side vow room / oath chamber with hidden compartment logic
- central gate or seal door that is visibly ceremonial

Marker guidance:

- evidence targets should feel official and historical, not magical loot
- banner or standard alignment can telegraph hidden logic without UI text
- the central hall should read as politically important space before combat starts

Environment rules:

- maintain strong axial symmetry through the main hall
- decorative standards cannot obscure unit occupancy around key objects
- hidden chamber reveal should come from pattern mismatch, not random suspicion

### CH06_05 Oath of Iron

Map role:

- chapter boss siege resolution in reclaimed fortress space

Prop priorities:

- central keep platform
- side counterweight machinery
- surviving battery or wall-break remnants
- hidden armory door that opens on optional objective completion

Marker guidance:

- counterweights need huge readable silhouettes because they govern the optional objective
- boss zone should be austere and militarily clean compared with earlier rubble-heavy maps
- hidden armory entrance should feel plausible as a fortress store room

Environment rules:

- preserve wide boss read lanes despite fortress clutter
- optional objective props must remain visible during combat effects
- keep the keep interior geometry disciplined; this is ordered power, not chaos

## Cross-Team Handoff Notes

For [ASH-12](/ASH/issues/ASH-12):

- promote gimmicks using object families that match the chapter identity before adding new raw enemy count
- if a mechanic needs a lever, shrine, battery, seal frame, or counterweight, use the prop families above instead of reusing `CH01` tutorial silhouettes unchanged
- when adding interaction state, reserve the first read for shape and placement; icons are confirmation, not discovery

For UI and FX partners:

- this document assumes icons and telegraphs can layer on top later, but the map should already communicate intent through world shapes and floor treatment
- hazard previews should align with the color hierarchy in this document unless a stronger global combat language is already locked elsewhere

For environment production:

- every chapter should reuse a small prop family aggressively so the player learns chapter grammar fast
- optional routes should feel like authored temptation, not filler dead ends

## Review Checklist

- Can each chapter be identified from landmark shapes alone?
- Does each optional reward route have a visible environmental clue?
- Do interactables look tappable before an icon appears?
- Are hazard tiles supported by a visible environmental cause?
- Can [ASH-12](/ASH/issues/ASH-12) implement stronger gimmick read without needing new story work?
