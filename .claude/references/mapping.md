# Reference Mapping

This file is the single source of truth for **which reference docs a given
skill must load before doing anything else**. It exists so that shared
conventions can be updated in one place without editing downstream skill files.

This file is human-maintained only. Agents read it and follow it, but never 
edit it — not to add a missing row, not to fix a stale one, not even as a side 
effect of an unrelated task. If something here looks wrong or incomplete, flag
 it to a human instead of correcting it yourself.

If you are an agent and a skill file pointed you here, follow the algorithm
below exactly. Do not skip it, do not summarize it from memory, and do not
proceed with the skill's own instructions until you've completed it.

---

## Algorithm

If you are an agent and a skill file pointed you here, follow this algorithm exactly and in order.

1. **Identify your own skill file's path** — the **exact** skill name from 
   the skill definition that invoked this mapping. Use the skill's declared 
   name/identity, not an inferred filename or approximate description.
2. **Load every file listed under "Always Load"** below. These apply to
   every skill, unconditionally. Load these regardless of what skill you are.
3. **Find your skill's row in the "Per-Skill" table** by matching
   your name exactly.
   - **Row found:** load every file listed in that row's "Additional
     References" column, in the order listed.
   - **Row not found** (your skill isn't in the table — e.g. it's new):
     Do not silently proceed with only the "Always Load" set. **WARN** 
     the human that this skill has no entry in the reference mapping.
4. **Load referenced files in full.** Do not partially read them, do not
   load only a summary of them. If a listed file doesn't exist at the given
   path, treat that as a blocking issue and surface it — don't proceed as if
   the reference were satisfied.

This algorithm runs on every invocation of your skill, not just the first
one in a session. References are not assumed to persist from a previous run.

---

## Always Load (every skill, no lookup required)

References listed here apply globally and every skill loads these regardless
of its row in the table below.

| Reference                                                        |
|------------------------------------------------------------------|
| [`karpathy-overview`](karpathy/00-overview.md)|
| [`context-engineering`](karpathy/01-context-engineering.md)|
| [`cognitive-limitations`](karpathy/02-cognitive-limitations.md)|
| [`agentic-discipline`](karpathy/03-agentic-discipline.md)|
| [`knowledge-persistence`](karpathy/04-knowledge-persistence.md)|
| [`graphify-overview`](graphify/00-overview.md)|
| [`cli-reference`](graphify/01-cli-reference.md)|
| [`agent-workflow`](graphify/02-agent-workflow.md)|
| [`repo-conventions`](graphify/03-repo-conventions.md)|
| [`troubleshooting`](graphify/04-troubleshooting.md)|

---

## Per-Skill

Match your skill file's path **exactly** against the left column. Load only
the additional files listed — the "Always load" set above is already
covered and does not need to be repeated per row.

| Skill              | Additional References                                      |
|--------------------|------------------------------------------------------------|
| dig | [`dig-socratic`](dig/01-socratic.md), [`dig-framing`](dig/02-framing.md), [`dig-premortem`](dig/03-premortem.md) |

---

## Required Skill-File Header

Every skill file must contain exactly this instruction as its first line:

```md
> Before doing anything else, read `references/mapping.md` and follow its algorithm to load your required references. Do not proceed with the instructions below until that's complete.
```

This header establishes that the mapping algorithm is a mandatory prerequisite for the skill. The mapping file itself remains immutable to agents.