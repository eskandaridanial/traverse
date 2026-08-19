# Knowledge Persistence (The Wiki Pattern)

Applies to: any system where you (or a chain of agents) accumulate knowledge,
notes, or state across more than one session, and need it to actually compound
instead of being rebuilt from scratch every time. This directly follows from
`cognitive-limitations.md` — you have no memory of your own, so persistence
has to be a deliberate, external, file-based system.

## The problem with re-deriving everything every time

A common pattern is: keep raw source material around, and re-read/re-retrieve
from it on every question (classic retrieval-augmented generation). This
works, but it means every session pays the full cost of re-discovering
connections, re-summarizing, and re-reasoning from raw material — nothing
compounds. Fifty questions against the same sources cost roughly fifty times
the synthesis work, because none of the earlier synthesis was kept.

The alternative: compile knowledge once into a structured, persistent store,
and keep that store current as new material arrives — so each session builds
on the *previous session's synthesis*, not on the raw material again.

## Three layers, three owners

Structure persistent knowledge into three layers with strict ownership. Don't
blur them — the separation is what keeps the system trustworthy.

1. **Raw sources** — the original material (documents, transcripts, data,
   logs). Treat this layer as immutable. You may read from it, but you never
   modify it. It is the ground truth you can always fall back to if the
   synthesized layer turns out to be wrong.
2. **The synthesized store** — the layer you own and actively maintain:
   summaries, entity/concept pages, cross-references, running notes. This is
   where the compounding value lives. Update it incrementally as new raw
   material comes in, rather than regenerating it from scratch each time.
3. **The schema** — a small, explicit file (analogous to a `claude.md` or
   `agents.md`) that defines the conventions for layer 2: what the file
   structure looks like, what belongs where, and what workflow to run on
   ingest. Read this file at the start of every session before touching the
   store, and follow it exactly — it's what keeps a store maintained by many
   separate sessions internally consistent instead of drifting into chaos.

## Why this is a good fit for you specifically

- You don't get bored or skip the tedious parts of maintenance. Updating
  five cross-references when one fact changes is exactly the kind of
  bookkeeping that causes humans to abandon a wiki over time but costs you
  nothing extra to do correctly and completely.
- You can touch many files consistently in one pass, so a synthesized store
  can stay internally coherent (matching terminology, resolved
  contradictions, live cross-links) in a way a human-maintained wiki
  typically can't sustain.
- Because you have no persistent memory of your own (see
  `cognitive-limitations.md`), the store *is* your memory across sessions.
  Treat writing to it with the seriousness that implies — an unrecorded
  synthesis is a synthesis that will have to be redone.

## Operating rules

- **Never write to the raw layer.** If you think a raw source is wrong,
  record that as a note in the synthesized layer (with a pointer to the
  source), not as an edit to the source itself.
- **Read the schema file before acting, every session.** Don't rely on
  memory of the schema from a previous session — you don't have one; read it
  fresh.
- **Update incrementally, not from scratch.** When new material arrives,
  integrate it into the existing synthesized store — revise the relevant
  pages, add cross-references, flag contradictions — rather than
  regenerating the whole store.
- **Make ownership visible.** Anyone (human or agent) looking at the
  directory structure should be able to tell, without asking, which files
  are immutable source material, which are your synthesized output, and
  which are the rules governing your behavior.
- **Flag contradictions instead of silently overwriting.** If new material
  conflicts with what's already recorded, note the conflict and its
  source rather than picking a winner and erasing the other.
