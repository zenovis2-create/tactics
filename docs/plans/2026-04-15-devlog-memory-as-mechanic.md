# Devlog: Memory as Mechanic, Not Just Lore

*Draft — 2026-04-15 | ASH issue: Draft devlog angle*

---

## 1. Headline Options

**Option A — System-first angle**
> "In Ashen Bell, forgetting is a status effect."

**Option B — Design-philosophy angle**
> "We made memory a verb. Here's what that means for tactics."

**Option C — Tension angle**
> "Most RPGs let you collect memories. In Ashen Bell, you fight to keep them."

**Recommended:** Option A leads, Option B as subtitle. Cleaner for algorithm reach; converts to long-form naturally.

---

## 2. Long-Form Devlog Outline

### Title
*"Memory as Mechanic: How We Made Forgetting the Real Enemy"*

### Opening hook (~150 words)
Rian, the protagonist, wakes up in a burning shrine with no name, no past, and—somehow—a perfect tactical instinct. The first question the player asks is "who is he?" The second question, which we want players to ask, is: "what does it mean that he can't remember?"

Most games use amnesia as a plot device. We use it as a design constraint. This devlog explains how.

### Section 1: The Problem with Memory in RPGs (~300 words)
- Memory in most narrative RPGs = cutscene delivery system
- Players receive story passively; lore rarely feeds back into gameplay
- We wanted: every time Rian recovers a memory fragment, something in the battle system changes
- Thesis: if memory matters to the story, it has to cost something in the game

### Section 2: 망각 — Forgetting as a Status Effect (~400 words)
- Enemy-inflicted debuff, not just a story theme
- Stacks reduce accuracy, evasion, skill availability
- At high stacks: signature skills are temporarily sealed
- Design intent: the game's central threat (forgetting) has to be felt in every fight, not read about
- The player is managing Rian's coherence in real-time
- Serin's kit exists specifically to counter 망각 — her healing is literally about helping allies stay themselves
- Contrast with conventional SRPG debuffs: silence, poison, burn — they affect action economy; 망각 affects identity

### Section 3: 기억 조각 — When Narrative Rewards Are Also Mechanical Rewards (~400 words)
- Each chapter ends with Rian recovering a memory fragment
- But the fragment doesn't just play a cutscene — it unlocks a tactical command
- Examples: Chapter 1 fragment → unlocks "Tactical Shift" (swap position with an ally, both get brief buff)
- The reveal structure: early fragments make Rian look complicit in atrocities; later context reframes them
- So the player is incentivized to unlock uncomfortable truths because they also unlock better combat options
- Design problem this solves: players skip cutscenes. If the cutscene IS the mechanical unlock, they watch it.
- Rule we set for ourselves: no memory fragment that doesn't also change something in how you play the next battle

### Section 4: 인연 보조 — Trust as a Tactical Variable (~300 words)
- SRPG support systems are common (Fire Emblem, etc.)
- Ours is tied explicitly to: "believing in someone enough to share the weight"
- Mechanical expression: adjacency bonuses (support attack, damage sharing, status resistance)
- Narrative lock: highest bond level requires completing that ally's personal story arc
- Final boss relevance: the True Ending only fires if key bonds are at max — not because we gated it artificially, but because the final gimmick (Name Anchor) requires allies who trust you enough to call your name under pressure
- The mechanic literalizes the theme: you cannot carry memory alone

### Section 5: What This Asks of the Player (~200 words)
- Rian is not a hero. He's a recontextualized atrocity.
- The game asks players to unlock worse and worse truths about him — mechanically rewarded
- This is uncomfortable on purpose
- The True Ending is not "Rian is forgiven." It's "he remembers everything, the team carries it together, and they move forward anyway."
- We believe players who feel that through the mechanics will feel it more than any cutscene could deliver

### Closing (~100 words)
- Current status: vertical slice, battle loop running, CH01–CH10 stage chain live
- Representative screenshots (attach contact sheet)
- What's next: production art replacement sprint, gimmick promotion CH02–CH06

---

## 3. Short Social Post Variants

**Variant A — Hook post (X / Bluesky)**
> Forgetting is a status effect in our tactics RPG.
>
> Stack enough 망각 (Forgetting) and your signature skills go dark. The whole system is built around one question: what does it cost to remember who you are?
>
> Devlog incoming. 🧵

**Variant B — Design philosophy post**
> In Ashen Bell, every story reveal also unlocks a new battle command.
>
> We didn't want players to skip the cutscenes. So the cutscenes ARE the mechanical reward.
>
> Memory as mechanic. Not just lore.

**Variant C — Tension/curiosity post**
> The protagonist has no name. Perfect tactical instinct. A past that makes him worse the more you learn.
>
> And every truth you unlock gives you a new way to fight.
>
> Devlog: how we made memory a verb.

---

## 4. Dependencies and Blockers

| Item | Status | Note |
|------|--------|------|
| Representative screenshots | ✅ Ready | Contact sheet at `.codex-representative-snaps/` |
| Production art | ⏳ Pending | Using generated art for now; swap before public post |
| Chapter gimmick promotion (CH02–CH06) | 🔄 In progress | Can describe design intent without full implementation |
| Public reveal timing | ❓ Needs publishing input | ASH-13 defines reveal constraints — confirm window before posting |
| Localization of Korean terms (망각, 기억 조각, 인연 보조) | ❓ Needs decision | Keep Korean + parenthetical? Translate fully? |
