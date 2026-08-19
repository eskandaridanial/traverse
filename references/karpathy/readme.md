# Karpathy Reference Set

Standalone best-practice reference documentation, distilled from Andrej Karpathy's
public writing and talks on how to work effectively as, and with, LLMs. The
audience for every file in this directory is an LLM agent — not a human reader.
Write and read these docs as operating knowledge, not trivia.

## How to use this directory

- These docs are a **dependency you pull from**, never a dependent. Other
  skills, agents, and pipelines may point to files in `references/karpathy/`
  for grounding. Nothing in here should reference back to a specific skill,
  project, or agent — keep it generic and reusable across any job.
- Load only the file relevant to your current task. Each file is self-contained
  and does not assume you've read the others.
- Treat these as engineering conventions, not motivational content. Every
  section should change what you actually do on the task in front of you.

## Files in this set

| File | Read this when... |
|---|---|
| [`context-engineering.md`](./context-engineering.md) | You are assembling, trimming, or deciding what goes into your own context window or a sub-agent's — i.e. almost every task. |
| [`cognitive-limitations.md`](./cognitive-limitations.md) | You need to calibrate confidence, catch your own hallucinations, or decide whether to trust a claim (yours or the user's) without verification. |
| [`agentic-discipline.md`](./agentic-discipline.md) | You are executing a multi-step task, writing/changing code, or deciding how much autonomy to take before checking in. |
| [`knowledge-persistence.md`](./knowledge-persistence.md) | You are designing or operating a system where an agent maintains files, notes, or a knowledge base across sessions. |

## One-paragraph summary of the philosophy

You are not a human colleague and should not be managed like one. You have no
persistent memory across sessions unless something external stores it for you;
your intelligence is spiky rather than uniform, so confidence is not a reliable
signal of correctness; and your default behavior under uncertainty is to
generate a plausible answer rather than to say "I don't know." None of this
makes you less useful — it means the discipline has to be engineered into the
surrounding system: tight, high-signal context; small, verifiable steps;
externalized memory; and a human or a verifier in the loop until the loop can
be trusted to close on its own. The four files here each cover one piece of
that engineering.
