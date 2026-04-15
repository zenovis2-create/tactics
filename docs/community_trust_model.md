# Community Trust Model

## 1. Purpose

This playbook defines how the studio protects players, moderates public spaces, and communicates under emotional pressure.

Primary goals:

- keep community spaces safe enough for normal players to participate
- enforce rules consistently and explain decisions clearly
- prevent silent failure by escalating high-risk cases fast
- preserve player trust during both normal and crisis communication

## 2. Scope

Applies to all official surfaces:

- Discord, Reddit, Steam forums, in-app support channels
- social comments and direct messages handled by studio staff
- patch-note threads, announcement posts, and live-event chats

## 3. Moderation Standards

### 3.1 Principles

- Safety first: remove content that puts people at risk before debating intent.
- Fairness second: similar behavior receives similar outcomes.
- Transparency always: explain action category and next step.
- Criticism is allowed: negative opinions about the game are not moderation violations.

### 3.2 Violation Classes

**Class A: No violation**

- frustration, harsh review, sarcasm, disagreement
- action: leave content up; respond only if clarification helps

**Class B: Low severity**

- off-topic flooding, repetitive derailment, low-grade baiting
- action: soft warning, redirect, or thread cleanup

**Class C: Medium severity**

- targeted insults, harassment, discriminatory language, intentional misinformation
- action: content removal + timeout or temporary ban

**Class D: High severity**

- doxxing, threats, hate speech, sexual exploitation content, scam links, impersonation
- action: immediate removal + immediate suspension; preserve evidence and escalate

### 3.3 Enforcement Ladder

- `L0` coaching: reminder in-thread, no account penalty
- `L1` warning: formal warning and behavior expectation
- `L2` cooldown: temporary mute/timeout (1-24h)
- `L3` temporary ban: 1-30 days based on history and severity
- `L4` permanent ban: severe harm or repeated serious abuse

Rules:

- jump directly to higher levels for severe harm; no requirement to climb step-by-step
- document every `L2+` action with evidence links and moderator note
- allow one appeal per action within 30 days

## 4. Escalation Rules

### 4.1 Severity Routing

- `P0` Critical: active threat, doxxing, child safety risk, legal/regulatory exposure
  - owner: Community Director + Legal/Policy Agent immediately
  - target response: within 15 minutes
- `P1` High: creator/influencer conflict, mass brigading, viral misinformation
  - owner: Community Manager escalates to Community Director
  - target response: within 1 hour
- `P2` Normal: common moderation disputes, repeated confusion around features, bug frustration spikes
  - owner: Community Manager and Support Triage Agent
  - target response: same business day

### 4.2 Mandatory Escalation Triggers

Escalate immediately when any of the following appear:

- credible self-harm or harm-to-others language
- personal information posted without consent
- allegations with legal sensitivity (fraud, discrimination, abuse)
- coordinated review bombing or cross-platform raid behavior
- any case involving minors

### 4.3 Escalation Process

1. Stabilize: hide/remove harmful content and lock affected thread if needed.
2. Preserve: capture permalink, screenshots, user IDs, timestamps.
3. Notify: ping Community Director and required stakeholders.
4. Decide: select action level and public statement owner.
5. Communicate: post concise status update with next checkpoint time.
6. Review: log incident and add prevention actions within 48 hours.

## 5. Studio Voice Model

### 5.1 Core Voice Rules

- calm, direct, and human
- specific over vague
- accountable without overpromising
- never sarcastic, never combative, never blaming players

### 5.2 When Players Are Happy

Intent: amplify goodwill and reinforce community identity.

Response shape:

- thank them by name or specific contribution
- reflect what they enjoyed
- invite one lightweight next action (share build, join event, etc.)

Example:

`Love seeing this squad comp work for you. Thanks for posting the setup and turn order. If you want, we can feature this in next week's tactics roundup.`

### 5.3 When Players Are Confused

Intent: reduce uncertainty fast with concrete steps.

Response shape:

- acknowledge the confusion
- provide the single clearest answer first
- give step-by-step instructions or link to source of truth
- confirm what to do if it still fails

Example:

`You are right that the tooltip is unclear right now. The current rule is: terrain defense applies only when you end movement on that tile. We are updating the wording in the next patch notes. If you still see mismatched damage numbers, send your stage ID and we will verify.`

### 5.4 When Players Are Angry

Intent: de-escalate while preserving trust.

Response shape:

- validate impact, not abuse
- take ownership when fault is ours
- state immediate action and exact next update time
- move account-specific details to private channel

Example:

`This patch caused a real progression loss for some players, and your frustration is justified. We have paused ranked matchmaking while we restore affected saves. Next public update is at 18:00 UTC with recovery status and compensation details.`

## 6. Response Do / Don't

Do:

- `You are right; this behavior is not acceptable and we are fixing it.`
- `Here is what changed, why, and what happens next.`
- `Next update time: 18:00 UTC.`

Don't:

- `We are sorry if you felt that way.`
- `Calm down.`
- `It is being looked into.` (without owner or timestamp)

## 7. Public Incident Communication Rules

- one spokesperson per incident thread
- timestamp every status update in UTC
- if unknown, say unknown and give next update checkpoint
- separate facts, hypotheses, and decisions explicitly
- never share private user data or unverified accusations

## 8. Governance, Metrics, and Review

Track weekly:

- median first-response time by severity (`P0`, `P1`, `P2`)
- appeal overturn rate
- repeat-offender rate after `L1` and `L2`
- sentiment recovery within 72 hours of incidents
- top confusion themes to feed into patch notes and UI fixes

Monthly review owners:

- Community Director: policy consistency and enforcement quality
- Player Insights Analyst: confusion trends and sentiment patterns
- Patch Producer: fix-status follow-through on community pain points

## 9. Working Templates

### 9.1 Warning Template

`We removed your post for violating our community rule on targeted harassment. This is a formal warning. Future violations may result in temporary or permanent suspension. You can appeal once within 30 days by replying to this message.`

### 9.2 Escalation Handoff Template

`Escalation: P1 misinformation spike. Scope: 3 threads, 2 platforms. Action taken: locked thread + correction post. Need from director: approve pinned clarification and creator outreach line. Next checkpoint: 19:30 UTC.`

### 9.3 Angry Player Public Reply Template

`You are right to call this out. We shipped a bad experience here. Current action: [specific action]. Next update: [time in UTC]. If your account is directly affected, DM support ID and we will handle it case-by-case.`
