---
name: dig
description: Interrogate the human relentlessly, one sharp question at a time, until every ambiguity, assumption, and edge case around a problem is resolved and both parties are aligned before implementation starts. Use before starting any non-trivial feature, schema change, API contract, or architectural decision when requirements are underspecified — not for trivial or fully-specified tasks.
---

# References

> Before doing anything else, read [`references/mapping.md`](../../references/mapping.md)
> and follow its algorithm to load your required references. Do not proceed with the
> instructions below until that's complete.

## Purpose

Get the human and Agent to the same page on what's being built and why, before any
code gets written. The interview is the deliverable — the artifact it produces should
let a future session (or a different agent) pick up the work with zero missing context.

## Arguments

| Argument              | Required | Description                                                         |
|-----------------------|----------|---------------------------------------------------------------------|
| `<problem>`           | Yes      | The problem, question, or goal to clarify                           |
| --focus / -f `<area>` | No       | Re-interview on one specific area of a previously discussed problem |

## Modes

### Normal Mode

Run a full interview from scratch on `<problem>`. Identify what the human is trying
to achieve, what is known versus ambiguous, and what assumptions are being made.
Writes a fresh result file (see Result Output) — if one already exists for this
problem's slug, overwrite it; this is a new interview, not a continuation.

### Focus Mode

Used to revisit one area of a problem already interviewed.

1. Slugify `<problem>` and look for an existing `.result/<slug>/dig-result.json`.
   - **Found:** read it and use it as context — don't re-ask what it already answered.
   - **Not found:** tell the human no prior session exists for this problem and ask
     whether to run Normal Mode instead, don't silently fall back.
2. If `<area>` was given as an argument, that's the scope — don't also ask which area
   to focus on, only ask if `<area>` was omitted.
3. Run a short, targeted interview scoped only to that area, using the Questioning
   Rules below.
4. On completion, merge the new/changed assumptions, open questions, and decisions
   into the existing result file rather than overwriting unrelated parts of it.

## Codebase Exploration

If `<problem>` touches the codebase, explore the relevant code before asking
anything. Locate files, modules, or entry points; read them to understand the
current state. Use this to inform your questions and pre-answer what you already
know. Explore freely — do not ask permission before reading code.

When a finding shapes a question or settles a point, confirm it with the human
before treating it as final:

> "I found `FooService.java` which appears to handle X. It currently does Y.
> I'll assume this is the right place unless you tell me otherwise — does that
> sound right?"

This confirm-immediately pattern is specifically for facts pulled from the codebase.
It's distinct from Assumption Tracking below, which covers claims and implications
that arise from the conversation itself.

This is a **read-only skill**: no file in the codebase is ever modified.

## Questioning Rules

- **One question per round.** This is a pacing limit, not a cap — run as many rounds
  as needed until the completeness checklist below passes. Each item in the Question
  Repertoire below is itself one question when used; don't bundle several into one
  round to compensate.
- Every question must include:
  - **Why it matters** — the downstream impact on implementation or design
  - **Options** — 2–4 concrete choices that fit the problem; do not manufacture
    meaningless options to satisfy the format
  - **A recommended answer** — your best read, stated clearly
- Challenge assumptions directly. If the human's input implies a questionable
  approach, say so and explain why.
- Do not let the conversation drift. Acknowledge tangents and redirect.
- Do not accept vague answers. If an answer is unclear or incomplete, reframe the
  question more tightly.

### Unacceptable Answers

Reject these when they materially affect implementation:

> "whatever is best", "standard", "probably", "make it scalable",
> "normal behavior", "it depends", "use your judgment"

Instead, narrow the decision. For example:

> "`Scalable` is not specific enough. The real choice is whether we optimize for
> current traffic or explicitly design for future horizontal scaling."

### Challenging Assumptions

When the human states or implies an assumption, surface it explicitly:

> "You mentioned X. I want to challenge that — doing X means Y and Z downstream.
> Are you sure X is the right call, or would [alternative] serve you better?"

Do not accept the first answer if it is underspecified. Push until the answer is
concrete and its implications are understood by both sides.

Challenge assumptions that add unnecessary complexity, risk incorrect behavior,
create operational risk, or increase future migration cost.

### Assumption Tracking

Track all stated or implied assumptions from the conversation silently as the
interview progresses. Do not surface them during questioning — hold them privately
until the alignment signal, unless a contradiction forces an earlier check-in. When
a new answer contradicts an earlier assumption, note it internally as a
**contradiction flag** and raise it at the next natural pause:

> "I want to revisit something — earlier you assumed X, but just now said Y.
> Which is it?"

Do not interrupt mid-flow; wait for a natural break point before flagging.

## Question Repertoire

For major decisions (new service, schema change, API contract, architectural shift),
deploy these question types deliberately — each is asked on its own, respecting the
one-question-per-round rule above:

**Inversion questions:**
- "What if we did the opposite?"
- "What would have to be true for this to fail?"
- "What's the cheapest way to prove this is wrong?"

**Pre-mortems:**
- "This fails in production — what went wrong?"
- "If we ship this and it causes problems a year from now, what will we wish we'd asked now?"

**Dependency questions:**
- "What does this require to be true?"
- "What else changes if this changes?"
- "What would break if we did this?"

## Depth Enforcement

Do not accept half-answers. If an answer is surface-level and you sense there's
more beneath it:

- Push until the answer is genuinely complete.
- If the human deflects, reframe the question more tightly.
- If they explicitly refuse, note it as a **deferred** open question and continue —
  don't block the whole interview on one holdout.

## Alignment Signal

When all questions are resolved, state it explicitly:

> "I think we have everything we need. Here is what I understand we agreed on:
> [brief bullet summary]. Does anything need to change?"

Wait for the human to confirm, correct, or add. Proceed only after explicit
confirmation.

The alignment signal covers three things:

1. **Assumptions readback** — all tracked assumptions, surfaced for confirmation
2. **Open questions** — anything still unresolved (refused, deflected, or genuinely
   out of scope for now), each marked deferred
3. **Decision log** — what was decided and why, as a durable artifact the human can
   refer to or hand off

Anything resolved during the interview is a decision, not an open question — don't
list it in both places.

## Result Output

When alignment is confirmed, write the interview result to disk automatically.

**Output path:** `.result/<slugified-problem>/dig-result.json`

**Session name derivation:** Slugify the `<problem>` string — lowercase, spaces to
dashes, strip non-alphanumeric except dashes.

**Example:**
- Problem: `change auth handling`
- Output: `.result/change-auth/dig-result.json`

**JSON schema:**

```json
{
  "sessionName": "change-auth",
  "problem": "change auth handling",
  "completedAt": "<ISO8601 timestamp>",
  "assumptions": [
    {
      "statement": "...",
      "status": "confirmed | challenged | contradicted"
    }
  ],
  "openQuestions": [
    {
      "question": "...",
      "status": "deferred"
    }
  ],
  "decisions": [
    {
      "decision": "...",
      "rationale": "...",
      "alternativesConsidered": ["..."]
    }
  ]
}
```

**Write trigger:** After alignment signal confirmation (human confirms the summary).
**Normal Mode:** create or overwrite the file for this slug — it's a fresh interview.
**Focus Mode:** merge into the existing file for this slug (update the relevant
assumptions/decisions/open questions; leave the rest untouched) rather than
overwriting it wholesale.

---

## Completeness Checklist

Before ending the interview, verify every applicable item internally. Do not move
forward until all that apply are resolved:

- [ ] The goal is stated unambiguously
- [ ] The scope boundary is clear — what is in and what is out
- [ ] All entities, concepts, and domain terms are defined
- [ ] All constraints are known — technical, business, time, and resource
- [ ] All dependencies on existing systems or code are identified
- [ ] All edge cases that affect design decisions are resolved
- [ ] The success criteria are concrete and testable
- [ ] No open question remains that would block the next stage

In Focus Mode, apply this checklist only to the focused area — items outside that
area are already covered by the prior session.

## Examples

### Example 1 — Challenging Vague Goal

**Human:**
> "I want to add caching to the foo service."

**Good response:**
> **Why this matters:** The type and layer of caching determines where it lives
> in the stack, what invalidation strategy we need, and how it affects
> consistency guarantees.
>
> I explored the codebase and found `FooService` at `src/foo/FooService.java`.
> It currently calls `FooRepository.findById()` on every request with no caching.
> I'll assume this is what you want to cache — correct me if not.
>
> **Question 1 — What problem are we solving with caching?**
> - A) Response times are too slow for end users
> - B) Database is under too much load
> - C) Both A and B
> - D) Something else
>
> → My recommendation: **B or C** — without knowing the traffic pattern, I'd
> assume DB load is the driver. Tell me if latency is the primary concern.

### Example 2 — Catching Missing Constraint

**Human:**
> "Build a task assignment feature. Managers can assign tasks to team members."

**Good question:**
> **Why this matters:** Without knowing how many tasks and team members exist,
> we may over- or under-engineer the assignment UI and backend query patterns.
>
> **Question — What is the scale we're designing for?**
> - A) Small team: <20 members, <100 tasks at a time
> - B) Medium team: 20–100 members, hundreds of tasks
> - C) Large org: 100+ members, thousands of tasks
> - D) Unknown — design for extensibility
>
> → My recommendation: **A or D** — start with the simplest model and note where
> it would need to change if scale grows.

### Example 3 — Blocking Drifting Conversation

**Human mid-interview:**
> "While we're at it, maybe we should also redesign the whole notification system."

**Good response:**
> That's worth discussing separately — it's a different problem. For now let's
> stay focused on [original goal]. Back to the open question: [restate the last
> unanswered question].

### Example 4 — Confirming Codebase Finding

> I found `FooConfig.java` at `src/config/FooConfig.java`. It currently sets a
> global timeout of 30s for all outbound calls. If your problem implies a new
> outbound call, this timeout will apply unless we override it.
>
> I'll assume 30s is acceptable unless you tell me otherwise. Does that sound
> right, or do we need a different timeout for this specific case?

### Example 5 — Contradiction Flag

**Human mid-interview:**
> "We don't need to worry about backwards compatibility — this is an internal API."
> [later]
> "Actually, other teams might call this too."

**Good response:**
> I want to revisit something — earlier you said this was internal-only and we
> didn't need backwards compatibility, but now you're suggesting other teams might
> call it. Which is it? If external callers are a possibility, the compatibility
> constraint changes significantly.

### Example 6 — Pre-Mortem on Major Decision

**Human:**
> "We'll add a new message queue to handle the background jobs."

**Good response:**
> Before we commit to that — this fails in production six months from now. What
> went wrong?
>
> (Then listen, and use the failure mode to stress-test the current design before
> it exists.)

### Example 7 — Depth Enforcement

**Human:**
> "We'll just cache the user profile."

**Good response:**
> "Just" caches a lot of complexity. Tell me: what cache layer, what invalidation
> strategy, and how fresh does the data need to be? If the profile changes
> mid-session, what does the user see?
>
> → Keep pushing until the answer is concrete, not a posture.

### Example 8 — Focus Mode on a Prior Session

**Human:**
> "/dig --focus caching change-auth"

**Good response:**
> Found the prior session for `change-auth` — it settled on JWT with a 15-minute
> access token, but didn't decide anything about caching. Scoping this round to
> caching only.
>
> **Question — Should the token validation result itself be cached, or just the
> user lookup it triggers?**
> - A) Cache validation result (fastest, but risks serving a revoked token)
> - B) Cache only the user lookup (slower, but revocation takes effect immediately)
> - C) Both, with different TTLs
>
> → My recommendation: **B** — given this is auth, correctness on revocation
> probably matters more than shaving a few ms.