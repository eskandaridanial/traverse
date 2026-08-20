# Problem Framing

Problem framing is the discipline of defining a problem clearly before attempting to solve it. A well-framed problem is half-solved; a poorly framed one leads to the wrong solution entirely.

## Why Framing Matters

The way a problem is stated shapes the solution space. A poorly framed problem:

- Misses root causes while treating symptoms
- Leads to solutions that create new problems
- Draws resources toward the wrong goals
- Prevents discovery of simpler or better solutions

## The Framing Checklist

Before any solution discussion, verify:

**Is the goal stated unambiguously?**
- What specifically needs to happen?
- What does success look like?
- What does failure look like?

**Is the scope clear — what's in and what's out?**
- What is explicitly NOT being solved?
- What assumptions are we making about scope?

**Are all entities and domain terms defined?**
- Does "user" mean the same thing to everyone?
- Are technical terms being used precisely?

**Are constraints known?**
- Technical constraints (what can and cannot be changed)
- Business constraints (time, budget, political)
- Resource constraints (who owns what, who decides)

**Are dependencies identified?**
- What else must be true for this to work?
- What does this touch that we haven't discussed?

**Are edge cases that affect design surfaced?**
- What happens at boundaries?
- What are the failure modes?

## Problem Statement Structure

A good problem statement answers:

1. **Who** has the problem
2. **What** the problem is (specifically)
3. **When/Where** it occurs
4. **Why** it matters (stakes)
5. **What** has been tried (if anything)

Template:

> "[Stakeholder] has a problem where [problem description]. This happens when [context]. The impact is [consequence]. We've tried [prior attempts]. The goal is [desired outcome]."

## Common Framing Errors

**Solution-first thinking** — "I need to add caching" before understanding the actual problem
**Symptom treatment** — solving what appears broken without asking why it broke
**Scope creep** — the problem keeps expanding because the boundary wasn't set
**Vague goals** — "make it better" or "improve performance" without measurable criteria
**Assumed causes** — stating the cause before verifying it

## The Five Whys Technique

When the stated problem might be a symptom, dig deeper:

- Ask "why" five times, each answer becoming the next question
- Stop when reaching a root cause that is actionable
- If a "why" answer is "because that's how it works" — you've found a constraint

Example:
- Problem: "The build is slow"
- Why? "Because the tests take 20 minutes"
- Why? "Because there are 5,000 tests"
- Why? "Because we added tests for every feature over 3 years"
- Why? "Because we never differentiated between unit and integration tests"
- Why? "Because the original team didn't set testing standards"
- Root cause: No testing standards → fix: differentiate unit/integration

## Connection to Dig

Dig's Completeness Checklist is directly derived from problem framing principles. The checklist items are the output of a properly framed problem.

## Sources

- Weick, K. E. (1995). "Sensemaking in Organizations" — on how problems get constructed
- Schön, D. A. (1983). "The Reflective Practitioner" — on problem framing in professional practice
- A3 Problem Solving (Toyota methodology) — structured problem statement format
- Dewey, J. (1910). "How We Think" — on problem identification as the first step of reasoning
