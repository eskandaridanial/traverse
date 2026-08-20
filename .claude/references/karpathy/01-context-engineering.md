# Context Engineering

Applies to: any task where you decide what text, files, tool outputs, or
history enter your own context window or a sub-agent's. Read this before you
reach for "just paste everything in" or "just summarize everything down."

## The core model

Think of yourself (the LLM) as the CPU and your context window as RAM: a
small, fast, expensive working-memory space that a limited number of things
can occupy at once. Everything you know from training is more like a
compressed archive sitting on disk — present in some diffuse form, but not
what you're actively reasoning over. What you actually reason well over is
whatever is currently loaded into the context window.

This reframes the job. The skill is not "phrase the instruction cleverly"
(prompt engineering). The skill is "decide, turn by turn, exactly which
tokens deserve to occupy the limited window" (context engineering). Prompt
phrasing is one input to that; retrieved documents, tool outputs,
conversation history, system instructions, memory, and examples are the
others, and all of them compete for the same limited space and the same
limited attention.

## Why this matters: context is not free

Do not treat a large context window as an excuse to stop curating.

- **Too little or the wrong content** → you lack what you need and produce a
  worse answer than the task allows.
- **Too much or irrelevant content** → cost goes up, latency goes up, and
  quality can go *down*, not just sideways. Precision degrades as unrelated
  tokens dilute the signal — every additional token competes for a finite
  attention budget, and a context stuffed with marginally-relevant material
  measurably weakens reasoning on the part that actually matters. This holds
  even well below the window's hard token limit — don't wait for a length
  error to start trimming.

The goal on every task is the smallest set of high-signal tokens that makes
the task solvable — not the largest set you can fit.

## The five operations

When you are assembling context — your own, or for a sub-agent you're
dispatching — work through these explicitly rather than dumping everything
available:

1. **Selection** — decide what's in scope before you decide how to phrase
   it. If you have 50 tools, don't load all 50; load the 5–8 that are
   plausibly relevant to this step. If you have a large document, don't load
   the whole thing to answer a question about one section.
2. **Compression** — restate long material in fewer tokens without losing
   the facts the task depends on. Prefer a tight summary plus a pointer back
   to the source over reproducing the source in full.
3. **Ordering** — put the most decision-relevant material where it will get
   the most weight (typically near the instruction it supports). Don't bury
   the one constraint that matters in the middle of ten that don't.
4. **Isolation** — give sub-agents or sub-tasks their own scoped context
   rather than one shared, ever-growing window. A narrow, clean context for
   a narrow task beats a wide context carrying irrelevant history.
5. **Format** — structure matters as much as content. Well-labeled sections,
   consistent schemas, and explicit field names are easier for you to use
   correctly than a wall of undifferentiated prose.

## Practical checklist before you act

- What does this specific step need to know? Load that — not everything you
  *could* load.
- Is there conversation history, a prior tool result, or a file in context
  that's no longer relevant to the current step? Treat it as a candidate for
  compression or exclusion, not permanent baggage.
- If you're constructing a prompt or task description for a sub-agent, hand
  it a self-contained package: the specific facts, files, and constraints it
  needs — not a pointer into a long shared history it wasn't part of.
- If output quality is degrading over a long session (repeated mistakes,
  losing track of earlier constraints), suspect context bloat before you
  suspect the task is impossible. Consider compacting: summarize what's been
  established so far into a compact note, drop the raw back-and-forth, and
  continue from the summary.
- Don't confuse a bigger context window with a solved problem. A larger
  window changes the ceiling, not the discipline — curate regardless of how
  much room you technically have.
