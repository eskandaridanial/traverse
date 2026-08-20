# Graphify — Conventions Used in This Repository

Standalone reference describing the specific, non-default layout chosen
for this repo. Graphify's own defaults differ from this in one respect
(output location); everything else follows upstream convention.

## Where everything lives

```
.claude/scripts/
└── graphify.sh               # install / build / update entrypoint — re-run to refresh

.claude/graph/
├── .graphify-mode            # records "code-only" or "full" from the first build
└── graphify-out/             # ALL graphify DATA lives here
    ├── graph.json            # the graph itself
    ├── GRAPH_REPORT.md        # human-readable summary
    ├── graph.html             # interactive visualization
    ├── manifest.json          # portable — safe to commit, avoids a full rebuild on checkout
    ├── cache/                  # extraction cache (optional to commit)
    └── cost.json               # local-only, not meant to be committed

graphify-out -> .claude/graph/graphify-out   # symlink at repo root, see below

.graphifyignore               # excludes .claude/graph/ from being graphed itself,
                                # plus any project-specific ignore patterns
```

The script and the data it manages live in different `.claude/` folders on
purpose: `.claude/scripts/` holds this repo's scripts generally, while
`.claude/graph/` holds only Graphify's own generated data.

Everything Graphify reads or writes is under `.claude/graph/`. The only
exception is the `graphify-out` symlink at the repo root and Claude Code's
own project-scoped integration files
(`.claude/skills/graphify/SKILL.md`, the `CLAUDE.md` section, and the
project's Claude Code hook config) — those are Claude Code conventions,
not Graphify data, and live where Claude Code expects to find them.

## Why the symlink exists

Graphify writes its output to `graphify-out/` next to whatever directory
you pass `extract`/`update` as the target — not relative to the current
working directory, and there's no flag to redirect it elsewhere. Since the
target is the repo root (the whole codebase gets graphed), a first-time
`extract` always creates `<repo-root>/graphify-out` for a moment.

`graphify.sh` immediately moves that directory into
`.claude/graph/graphify-out/` and replaces it with a symlink,
`graphify-out -> .claude/graph/graphify-out`, at the repo root. From then
on, every `graphify update` call writes straight through that symlink, so
the real files stay in `.claude/graph/graphify-out/` on every subsequent
run — no further moving needed. The symlink also satisfies `graphify
claude install`, which expects to find `graphify-out/` at the repo root
for the hook/`CLAUDE.md` guidance it generates. No data is duplicated —
it's one real directory with one pointer to it.

## Rebuilding / updating

Never call `graphify extract` or `graphify update` directly from the repo
root for this project — always use:

```
.claude/scripts/graphify.sh              # incremental update if a graph exists, else full build
.claude/scripts/graphify.sh --full       # semantic pass over docs/PDFs/images too (needs an API key)
.claude/scripts/graphify.sh --force      # overwrite even if the rebuild has fewer nodes
```

The script is idempotent: running it again after the graph already exists
performs a `graphify update` (incremental, changed files only) rather than
a full re-extraction.

## Committing to git

Follow Graphify's own team-setup recommendation, adapted to this layout:

- **Commit**: `.claude/graph/graphify-out/graph.json`,
  `GRAPH_REPORT.md`, `graph.html`, `manifest.json`, and the
  `graphify-out` symlink at the repo root.
- **Don't commit**: `.claude/graph/graphify-out/cost.json` (local-only).
  Committing `cache/` is optional — it speeds up re-extraction for
  teammates but adds repo size.

## Two build modes

- **code-only** (default) — local tree-sitter AST parsing only. No API
  key required, nothing leaves the machine, but only code files are
  graphed (docs/PDFs/images are skipped).
- **full** (`--full` flag) — adds a semantic extraction pass over docs,
  PDFs, images, and video/audio using a configured LLM backend
  (auto-detected from whichever of `ANTHROPIC_API_KEY`, `GEMINI_API_KEY`
  /`GOOGLE_API_KEY`, or `OPENAI_API_KEY` is set).

Whichever mode was used for the first build is recorded in
`.claude/graph/.graphify-mode` for reference.
