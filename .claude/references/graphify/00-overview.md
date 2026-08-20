# Graphify — Overview & Core Concepts

Standalone reference. No dependency on other files in this directory or on
network access — everything an agent needs to reason about Graphify output
is below.

## What Graphify is

Graphify turns a codebase (plus its docs, SQL schemas, configs, and PDFs)
into a **queryable knowledge graph** instead of a pile of text chunks to
grep through. Source: https://github.com/Graphify-Labs/graphify

Two extraction paths feed the same graph:

- **Code** is parsed locally with tree-sitter AST across ~40 languages.
  Deterministic, no LLM call, nothing leaves the machine.
- **Everything else** (markdown/docs, PDFs, images, video/audio, Office
  files) goes through a semantic pass using an LLM — either the coding
  agent's own model (when run via the `/graphify` skill) or a configured
  API key (when run headless via `graphify extract`).

It is **not** a vector index. There are no embeddings and no vector store —
just nodes and typed edges you can traverse, query in plain language, or
trace a path through.

## The three output files

A build produces:

| File               | Purpose                                                              |
| ------------------- | --------------------------------------------------------------------- |
| `graph.json`        | The full graph — nodes, edges, communities. Query this repeatedly instead of re-reading source files. |
| `GRAPH_REPORT.md`    | Human-readable highlights: god nodes, communities, surprising links, suggested questions. Good for a first orientation pass on an unfamiliar codebase. |
| `graph.html`         | An interactive force-directed visualization — open it in a browser, click nodes, filter, search. |

## Key vocabulary

- **Node** — a concept: a function, class, module, config key, doc section,
  database table, etc.
- **Edge** — a typed relationship between two nodes: `calls`, `imports`,
  `inherits`, `mixes_in`, `uses`, `references`, `depends_on`, and more.
- **EXTRACTED vs INFERRED vs AMBIGUOUS** — every edge carries a confidence
  tag. `EXTRACTED` means the relationship is explicit in the source (an
  actual `import` statement, a literal function call). `INFERRED` means
  Graphify resolved it (e.g. matching a call site to the function it most
  likely calls). `AMBIGUOUS` flags a case Graphify couldn't confidently
  resolve. Treat `INFERRED`/`AMBIGUOUS` edges as good leads, not certainties.
- **God nodes** — the most-connected concepts in the graph. Everything
  tends to flow through these; they're usually the right place to start
  understanding an unfamiliar area.
- **Communities** — the graph automatically clustered into subsystems
  (via the Leiden algorithm) with generated labels. A community is roughly
  "the set of things that belong to the same subsystem."
- **Rationale nodes** — inline `# NOTE:`, `# WHY:`, `# HACK:` comments,
  docstrings, and ADR/RFC references become first-class nodes linked to the
  code they explain, so "why was this built this way" is queryable too.

## When Graphify is useful vs. not

Good fit:
- "What connects X to Y?" / "What would break if I changed X?"
- Orienting in a codebase you (or the agent) haven't touched before.
- Finding every caller/importer of something across many files at once.
- Understanding the reasoning behind a design decision that's captured in
  a comment or a linked doc.

Not the right tool:
- Reading the literal current contents of one specific file you already
  know the path to — just read the file.
- Anything requiring up-to-the-second accuracy on a file that changed in
  the last few seconds and hasn't been re-extracted yet.

## Confidence and honesty

Because code extraction is local AST parsing, code-graph facts (who calls
whom, what imports what) are as reliable as static analysis gets. Semantic
extraction over docs/PDFs/images depends on the LLM used for that pass —
treat those nodes/edges with the same skepticism you'd apply to any LLM
summarization, especially anything tagged `INFERRED` or `AMBIGUOUS`.
