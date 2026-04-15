# Community Foundation

*Draft — 2026-04-15 | ASH issue: Define community foundation*

---

## 1. Community Tone Guide

### Who We Are

Ashen Bell Studio is a small team making a tactics RPG about memory, accountability, and moving forward while carrying weight. We believe games can ask hard questions without being cruel, and reward patience without demanding perfection.

### How We Talk to Players

**Core voice attributes:**

| Attribute | Means | Does not mean |
|-----------|-------|---------------|
| Grounded | Honest about what the game is and where it falls short | Overly critical or self-deprecating |
| Respectful | Treat player feedback as signal, not noise | Defensive or dismissive |
| Specific | Name the mechanic, name the chapter, name the bug | Vague platitudes ("we hear you") |
| Restrained | One bell, not a choir | Hype-first, announce-everything culture |

### Tone by Context

| Situation | Tone | Example |
|-----------|------|---------|
| Development update | Factual, specific | "CH02 fortress controls are now runner-verified. Next: CH03–CH06." |
| Community question about mechanics | Concise, design-aware | "망각 stacks are intentional — the healer's kit is the counter." |
| Bug report acknowledgment | Direct, no fluff | "Confirmed. Logged as CH04 spawn issue. No ETA yet but on the list." |
| Negative feedback | Acknowledge + learn | "That's a fair read. We'll look at pacing in that chapter." |
| Speculation about story | Deflect without dismissing | "We can't confirm, but we like where your head is." |
| Celebration (milestone, wishlist, etc.) | Warm, brief | "Thank you. This matters." |

### Things We Don't Do

- We don't hype without receipts
- We don't promise timelines we can't hold
- We don't argue with players in public channels
- We don't ignore a bug report with "we're aware"
- We don't spoil story content in community spaces, ever

---

## 2. Moderation Baseline

### What Is Always Allowed

- Gameplay questions and bug reports
- Feedback (positive and critical)
- Fan art, fan theory, fan writing (with spoiler tags after launch)
- Off-topic conversation in designated spaces

### What Is Never Allowed

- Harassment of any kind (other players, developers, community team)
- Hate speech, slurs, targeted personal attacks
- Unauthorized leaks of unreleased content
- Deliberate spoilers without tags in non-spoiler channels
- Coordinated spam or brigading

### Gray Areas (Handle Case by Case)

| Situation | Default action |
|-----------|---------------|
| Heated feedback about a design decision | Acknowledge; don't delete unless rules are broken |
| Player accuses studio of lying about a feature | Respond once with facts; do not escalate |
| Rampant speculation that spoils real content | Soft discourage; do not confirm or deny |
| Off-topic political content | Redirect; remove only if it escalates |

### Moderation Levels

| Level | Action | Who |
|-------|--------|-----|
| Warning | First offense, clear rules violation | Moderator |
| Temp mute (24h) | Repeat offense or disruptive behavior | Moderator |
| Temp ban (7 days) | Sustained disruption or targeted harassment | Community Director |
| Permanent ban | Hate speech, doxxing, illegal content | Community Director + Studio sign-off |

---

## 3. Escalation Rules

### Escalation Path

```
Player Report
    ↓
Moderator reviews (< 4 hours target)
    ↓
If clear rules violation: action taken immediately
    ↓
If ambiguous: escalate to Community Director (< 24 hours)
    ↓
If involves legal content, developer identity, or press: escalate to Studio Lead
```

### Priority Escalation Triggers

These go immediately to Community Director, not queue:

- Any credible threat (personal safety, legal)
- Coordinated harassment campaign
- Data leak or unauthorized asset distribution
- Press or media inquiry arriving in community channel
- High-visibility player making public accusation about studio conduct

---

## 4. Bug Report Intake Categories

All bug reports should be filed with the following fields where possible:

```
Category: [see below]
Platform: [iOS / Android / Desktop]
Chapter/Stage: [e.g., CH02_04, Tutorial]
Reproducible: [Yes / No / Sometimes]
Description: [What happened]
Expected: [What should have happened]
Attachment: [Screenshot or video if available]
```

### Category Tags

| Tag | Covers |
|-----|--------|
| `BATTLE-CRASH` | Hard crash during battle |
| `BATTLE-LOGIC` | Incorrect unit behavior, wrong damage, AI error |
| `BATTLE-UI` | HUD display errors, missing icons, layout breaks |
| `BATTLE-MAP` | Impassable tiles, wrong spawn positions, terrain errors |
| `CAMP-CRASH` | Hard crash in camp/menu |
| `CAMP-UI` | Camp screen display issues |
| `CAMP-DATA` | Wrong stats, missing items, data inconsistency |
| `PROGRESSION` | Stage not unlocking, memory fragments not triggering |
| `AUDIO` | Missing, wrong, or broken sounds |
| `PERF` | Slowdown, hitching, battery/memory issues |
| `OTHER` | Anything that doesn't fit above |

### Triage Severity

| Severity | Criteria | Target response |
|----------|----------|----------------|
| P0 | Crash on launch or progression blocker | Same-day patch if possible |
| P1 | Crash during normal play | Next patch cycle |
| P2 | Incorrect behavior with workaround | Scheduled fix |
| P3 | Visual glitch, non-blocking | Backlog |

---

## 5. Feedback Loop Into Design and Patch Production

### What Gets Logged

All community feedback is categorized weekly into:

- **Signal:** Recurring complaints or confusion about the same mechanic, chapter, or feature
- **Request:** Feature asks or content suggestions (logged but not committed)
- **Praise:** What players specifically liked (logged for future reference)
- **Bug:** Forwarded directly to engineering via standard intake

### Review Cadence

| Cadence | What happens |
|---------|-------------|
| Weekly | Community team reviews signal and bug categories; forwards to appropriate owner |
| Per milestone | Design reviews signal log for patterns; patches address P0/P1; backlog updated |
| Post-launch | Monthly community health review; tone guide reviewed and updated if needed |

### Feedback Categories That Route to Design

These signals automatically get a design ticket, not just a log:

- "This mechanic is confusing" (2+ reports, same mechanic)
- "This chapter isn't fun" (pattern across multiple sources)
- "The difficulty spike here is unfair" (P2 candidate if widespread)

### Feedback Categories That Stay in Community Log

- "I want more characters"
- "Add PvP"
- "Add save anywhere"
- "Port to [platform]"

These are acknowledged with a standard response and logged, but do not generate design tickets unless studio explicitly scopes them.

---

## 6. Scaling Notes for Launch and Live Service

This foundation is lightweight by design. When the game reaches wider public exposure:

- Add regional moderators (timezone coverage becomes necessary at 1k+ daily active community members)
- Formal appeals process for permanent bans
- Dedicated bug bounty or feedback portal (currently handled via community channels)
- Community digest (weekly summary of what was heard and what was acted on)
- Streaming/content creator policy (rights to use game footage, early access protocol)

Nothing above needs to be built now. The current baseline handles pre-launch and early launch.
