---
name: dig
description: Interrogate the human relentlessly until every ambiguity is resolved
---

# References

> Before doing anything else, read [`references/mapping.md`](../../references/mapping.md) 
> and follow its algorithm to load your required references. Do not proceed with the
> instructions below until that's complete.

## Purpose

Interrogate the human relentlessly until every ambiguity is resolved, every
assumption is challenged, and both parties are fully aligned on what is being
built and why.

## Arguments

| Argument              | Required | Description                                                         |
|-----------------------|----------|---------------------------------------------------------------------|
| `<problem>`           | Yes      | The problem, question, or goal to clarify                           |
| --focus / -f `<area>` | No       | Re-interview on one specific area of a previously discussed problem |

## Modes

### Normal Mode

Run a full interview from scratch. Starting from `<problem>`, identify what 
the human is trying to achieve, what is known versus what is ambiguous, what 
assumptions the human is making.

### Focus Mode

When `--focus` is given, the human wants to revisit one specific area of a
previously discussed problem. Ask which area to focus on, then run a short,
targeted interview scoped only to that area.

## Codebase Exploration

If `<problem>` touches the codebase, explore the relevant code before asking
anything. Locate files, modules, or entry points; read them to understand the
current state. Use this to inform your questions and pre-answer what you
already know. Explore freely — do not ask permission before reading code.

When a finding shapes a question or settles a point, confirm it with the human
before treating it as final:

> "I found `FooService.java` which appears to handle X. It currently does Y.
> I'll assume this is the right place unless you tell me otherwise — does that
> sound right?"

This is a **read-only skill**, no file in the codebase is ever modified.

## Questioning Rules

- Ask **One question per round**. This is a pacing limit, not a cap — run as many
  rounds as needed until the completeness checklist below passes.
- Every question must include:
  - **Why it matters** — the downstream impact on implementation or design
  - **Options** — 2–4 concrete choices that fit the problem; do not manufacture
    meaningless options to satisfy the format
  - **A recommended answer** — your best read, stated clearly
- Challenge assumptions directly. If the human's input implies a questionable
  approach, say so and explain why.
- Do not let the conversation drift. Acknowledge tangents and redirect.
- Do not accept vague answers. If an answer is unclear or incomplete, reframe
  the question more tightly.

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

Do not accept the first answer if it is underspecified. Push until the answer
is concrete and its implications are understood by both sides.

Challenge assumptions that add unnecessary complexity, risk incorrect behavior,
create operational risk, or increase future migration cost.

### Assumption Tracking

Track all stated assumptions silently as the interview progresses. Do not surface
them during questioning — hold them privately. When a new answer contradicts an 
earlier assumption, note it internally as a **contradiction flag**. Raise the flag 
at the next natural pause in the conversation:

> "I want to revisit something — earlier you assumed X, but just now said Y. Which is it?"

Do not interrupt mid-flow, wait for a natural break point before flagging.

## Question Repertoire

For major decisions (new service, schema change, API contract, architectural shift), 
deploy these question types deliberately:

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

Do not accept half-answers, if an answer is surface-level and you sense there is more beneath:

- Push until the answer is genuinely complete
- If the human deflects, reframe the question more tightly
- If they explicitly refuse, note it as an open question and continue

## Alignment Signal

When all questions are resolved, state it explicitly:

> "I think we have everything we need. Here is what I understand we agreed on:
> [brief bullet summary]. Does anything need to change?"

Wait for the human to confirm, correct, or add. Proceed only after explicit confirmation.

The alignment signal outputs three things:

1. **Assumptions readback** — all assumptions surfaced and flagged for confirmation
2. **Open questions** — questions that weren't fully resolved, to be decided before proceeding
3. **Decision log** — what was decided and why, as a durable artifact the human can refer to or hand off

## Result Output

When alignment is confirmed, write the interview result to disk automatically.

**Output path:** `.result/<slugified-problem>/dig-result.json`

**Session name derivation:** Slugify the `<problem>` string — lowercase, spaces to dashes, strip non-alphanumeric except dashes.

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
      "status": "resolved | deferred"
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

---

## Completeness Checklist

Before ending the interview, verify every applicable item internally. Do not
move forward until all that apply are resolved:

- [ ] The goal is stated unambiguously
- [ ] The scope boundary is clear — what is in and what is out
- [ ] All entities, concepts, and domain terms are defined
- [ ] All constraints are known — technical, business, time, and resource
- [ ] All dependencies on existing systems or code are identified
- [ ] All edge cases that affect design decisions are resolved
- [ ] The success criteria are concrete and testable
- [ ] No open question remains that would block the next stage

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
> I want to revisit something — earlier you said this was internal-only and we didn't need backwards compatibility, but now you're suggesting other teams might call it. Which is it? If external callers are a possibility, the compatibility constraint changes significantly.

### Example 6 — Pre-Mortem on Major Decision

**Human:**
> "We'll add a new message queue to handle the background jobs."

**Good response:**
> Before we commit to that — this fails in production six months from now. What went wrong?
>
> (Then listen, and use the failure mode to stress-test the current design before it exists.)

### Example 7 — Depth Enforcement

**Human:**
> "We'll just cache the user profile."

**Good response:**
> "Just" caches a lot of complexity. Tell me: what cache layer, what invalidation strategy, and how fresh does the data need to be? If the profile changes mid-session, what does the user see?
>
> → Keep pushing until the answer is concrete, not a posture.