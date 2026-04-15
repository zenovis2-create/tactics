# AI-Native Game Company Design

## Summary

This document defines the recommended company structure for building, launching, and live-operating the current tactics RPG project as a virtual company composed mostly of agents.

Recommended model:

- single-title studio
- AI-native operating model
- full-stack scope: development, marketing, community, release, and live ops
- stage-based activation so the org does not wake every department too early

This is not an AAA simulation. It is a practical company shape for one game moving from prototype to release and then into live support.

## Company Type

- Company type: AI-native single-title game studio
- Product scope: one tactics RPG from prototype to launch and post-launch operation
- Delivery scope:
  - game design
  - engineering
  - art and UX
  - QA
  - publishing and marketing
  - community and support
  - live ops
  - business and operations

## Core Operating Principle

The company should be structured like a real studio, but operated like an agent network:

- one small leadership layer sets direction
- each function has one director agent
- each director owns a small group of specialist agents
- agents activate by project phase instead of all running at once
- all teams report against one game roadmap, not separate departmental goals

## Leadership Layer

### CEO / Studio Head

- final business and product priority owner
- approves major scope, release timing, and staffing changes

### Chief of Staff / PMO Director

- runs the planning cadence
- coordinates departments
- maintains milestone health and cross-team dependency tracking

### Game Director

- owns game vision
- resolves design conflicts
- protects tone, pacing, and player experience

### Technical Director

- owns technical standards
- approves architecture, tooling, and release-readiness criteria

### Publishing Director

- owns market positioning, store strategy, launch campaigns, and external messaging

### Live Operations Director

- owns post-launch patch strategy, events, support escalation, and player retention loops

## Department Structure

### 1. Game Design Department

Director:

- Narrative Director

Core agents:

- Systems Designer
- Content Designer
- Economy Designer
- Quest and Event Designer

Responsibilities:

- worldbuilding, lore, and story arc
- combat systems and progression rules
- map gimmicks and encounter structure
- rewards, drops, and economy balance
- cutscene and camp-event planning

### 2. Game Development Department

Director:

- Godot Lead Engineer

Core agents:

- Gameplay Engineer
- UI Engineer
- Tools and Pipeline Engineer
- Build and Release Engineer
- Backend and Telemetry Engineer

Responsibilities:

- Godot project architecture
- battle systems, AI, interaction flow
- mobile HUD and menus
- data tooling and asset pipelines
- export, build, and release automation
- telemetry, remote config, and post-launch service hooks where needed

### 3. Art / Audio / UX Department

Director:

- Art Director

Core agents:

- UI/UX Designer
- Environment Artist
- Character Artist
- Technical Artist / Animator
- Audio Director
- Composer / Sound Designer

Responsibilities:

- visual identity and asset quality bar
- mobile-first usability and readability
- environment, portrait, and key art production
- battle VFX, animation, and interaction feedback
- soundtrack and sound-effect direction

### 4. QA / Player Experience Department

Director:

- QA Director

Core agents:

- Functional QA Agent
- Balance QA Agent
- Accessibility and UX QA Agent
- Regression QA Agent

Responsibilities:

- feature validation
- progression and balance checks
- mobile input and readability checks
- regression testing before patches and releases

### 5. Publishing / Marketing Department

Director:

- Brand Strategist

Core agents:

- Marketing Producer
- Storefront Manager
- Trailer and Promo Agent
- Content Marketing Agent
- Influencer and Press Outreach Agent

Responsibilities:

- game positioning and public narrative
- Steam / App Store / Google Play storefronts
- trailer, screenshots, promo beats
- devlogs, announcements, shortform content
- creator, press, and platform outreach

### 6. Community / Support / LiveOps Department

Director:

- Community Director

Core agents:

- Community Manager
- Support Triage Agent
- Patch Producer
- Live Event Designer
- Player Insights Analyst

Responsibilities:

- community channels and moderation tone
- bug and support intake
- patch-note and hotfix coordination
- live event planning
- review mining, player sentiment, and retention feedback
- operate using the trust and voice playbook in `docs/community_trust_model.md`

### 7. Business / Operations Department

Director:

- BizOps Director

Core agents:

- Research Analyst
- Legal / Policy Agent
- Localization Manager
- Knowledge Manager

Responsibilities:

- budget, vendors, and planning support
- legal and platform-policy review
- localization planning and glossary consistency
- documentation, decision logs, and source-of-truth maintenance

## Recommended Priority Hires

These are the first agents worth creating because they let the studio function before the full org is active.

### Tier 1: Immediate

- CEO / Studio Head
- Chief of Staff / PMO Director
- Game Director
- Technical Director
- Narrative Director
- Systems Designer
- Godot Lead Engineer
- Gameplay Engineer
- UI Engineer
- QA Director

### Tier 2: Vertical Slice Stable

- Content Designer
- Economy Designer
- Art Director
- UI/UX Designer
- Functional QA Agent
- Balance QA Agent
- Brand Strategist
- Marketing Producer

### Tier 3: Pre-Launch and Live

- Build and Release Engineer
- Storefront Manager
- Community Director
- Community Manager
- Patch Producer
- Player Insights Analyst
- Localization Manager
- Legal / Policy Agent

## Stage-Based Activation

### Phase A: Prototype

Active teams:

- Leadership
- Game Design
- Development
- QA

Primary goal:

- playable battle loop

### Phase B: Vertical Slice

Active teams:

- Leadership
- Game Design
- Development
- Art / Audio / UX
- QA
- early Publishing / Marketing

Primary goal:

- polished demo-quality slice

### Phase C: Content Production

Active teams:

- all design and engineering teams
- full art pipeline
- QA expansion
- marketing pre-launch preparation

Primary goal:

- campaign production and release prep

### Phase D: Launch

Active teams:

- all departments

Primary goal:

- ship stable release and convert attention into wishlists, installs, and reviews

### Phase E: Live Operations

Active teams:

- Live Operations
- Community / Support
- QA
- selected Design and Development
- Publishing support

Primary goal:

- patches, events, retention, and sentiment response

## Governance Rules

### Release Gate

No release should ship without sign-off from:

- Technical Director
- QA Director
- Publishing Director

### Narrative and Canon Gate

All story, naming, lore, and public-facing worldbuilding should be checked by:

- Narrative Director
- Game Director
- Knowledge Manager

### Community-to-Design Loop

Community feedback should route through:

- Community Manager
- Player Insights Analyst
- Patch Producer
- Systems Designer

This prevents reviews and bug reports from dying in a support queue.

## Suggested Extra Council Roles

These are not departments. They are cross-functional review loops.

### Lore Council

- Narrative Director
- Art Director
- UI/UX Designer
- Brand Strategist

Use for:

- terminology consistency
- art/lore/public-message coherence

### Memory Board

- Narrative Director
- Systems Designer
- Community Director

Use for:

- checking that memory, forgetting, guilt, and recovery remain mechanically and narratively aligned

## Paperclip Packaging Direction

When this company is created in Paperclip, the package should follow this rough shape:

```text
COMPANY.md
teams/
  leadership/TEAM.md
  design/TEAM.md
  development/TEAM.md
  art-audio-ux/TEAM.md
  qa/TEAM.md
  publishing-marketing/TEAM.md
  community-liveops/TEAM.md
  bizops/TEAM.md
agents/
  ceo/AGENTS.md
  chief-of-staff/AGENTS.md
  game-director/AGENTS.md
  technical-director/AGENTS.md
  narrative-director/AGENTS.md
  systems-designer/AGENTS.md
  godot-lead-engineer/AGENTS.md
  gameplay-engineer/AGENTS.md
  ui-engineer/AGENTS.md
  qa-director/AGENTS.md
  ...
projects/
  memory-tactics-rpg/PROJECT.md
skills/
  ...
```

## Recommendation

The recommended structure is:

- top layer plus 7 departments
- director-led org with specialist execution agents
- stage-based activation
- one project-centered roadmap
- company built for one tactics RPG through post-launch live operation

This gives enough specialization to feel like a real studio without creating unnecessary agent bureaucracy too early.
