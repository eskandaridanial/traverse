# Graphify — CLI Reference

Standalone reference. The commands below are Graphify's own CLI syntax and
are safe to run as-is; only the paths noted under "In this repository" are
specific to how this project is set up.

## In this repository

Graphify's data for this project lives at `.claude/graph/graphify-out/`
(not the default `./graphify-out/`), with a symlink `graphify-out ->
.claude/graph/graphify-out` at the repo root so Graphify's own generated
Claude Code integration works unmodified. Two consequences:

- `graphify query`, `graphify path`, `graphify explain`, and any command
  that accepts `--graph <path>` should be pointed at
  `graphify-out/graph.json` (via the symlink) or
  `.claude/graph/graphify-out/graph.json` directly — both resolve to the
  same file.
- To rebuild or incrementally update the graph, don't call `graphify
  extract`/`graphify update` directly — run `.claude/scripts/graphify.sh`
  instead. On first run it relocates Graphify's output into
  `.claude/graph/graphify-out/` and leaves a symlink at the repo root; on
  later runs it updates through that symlink and refreshes the Claude Code
  integration.

## Querying the graph (read-only, safe to run anytime)

```
graphify query "what connects auth to the database?"
graphify query "..." --graph graphify-out/graph.json
graphify query "..." --dfs --budget 1500      # depth-first, token-budgeted

graphify path "UserService" "DatabasePool"     # shortest path between two nodes
graphify explain "RateLimiter"                 # everything connected to one node
```

`query` returns a scoped subgraph relevant to a plain-language question.
`path` traces how two named things connect, hop by hop. `explain` dumps a
single node's neighborhood: source location, community, degree, and every
inbound/outbound edge with its confidence tag.

## Building / updating the graph

```
graphify extract <dir>                  # full build (needs LLM key for docs/PDFs/images)
graphify extract <dir> --code-only      # code only — local AST, no API key
graphify extract <dir> --force          # overwrite even if the new graph is smaller
graphify extract <dir> --backend claude # explicit backend (claude/gemini/openai/deepseek/ollama/bedrock/azure)

graphify update <dir>                   # incremental — re-extract only changed files
graphify update <dir> --force
graphify update <dir> --no-cluster      # skip re-clustering, raw graph only

graphify check-update <dir>             # report whether an update is needed, without running one
graphify cluster-only <dir>             # re-run community detection without re-extracting
graphify cluster-only <dir> --resolution 1.5   # more, smaller communities
graphify cluster-only <dir> --exclude-hubs 99  # drop top-1% degree nodes from god-node rankings
graphify label <dir>                    # (re)name communities with the configured backend
```

`extract` is the first full build; `update` is for every run after that.
`cluster-only` is for re-tuning how the graph is partitioned into
communities without paying for re-extraction.

## Exploring visually / exporting

```
graphify export callflow-html                    # Mermaid architecture/call-flow HTML
graphify export callflow-html --max-sections 8
graphify export callflow-html --output docs/arch.html

graphify --graphml     # export for Gephi / yEd
graphify --svg         # export graph.svg
graphify --neo4j       # generate cypher.txt for Neo4j
graphify --wiki        # build an agent-crawlable markdown wiki from the graph
graphify --obsidian    # generate an Obsidian vault
```

## Adding external sources

```
graphify add https://arxiv.org/abs/1706.03762   # fetch a paper and add it to the graph
graphify add <youtube-url>                       # transcribe and add a video
```

## Git integration

```
graphify hook install     # post-commit/post-checkout hooks: auto-rebuild (AST only, free) + a merge driver so graph.json never gets left with conflict markers
graphify hook uninstall
graphify hook status
```

## Serving the graph over MCP (for repeated tool-call access)

```
python -m graphify.serve graphify-out/graph.json
python -m graphify.serve graphify-out/graph.json --transport http --port 8080 --api-key "$SECRET"
```

Exposes `query_graph`, `get_node`, `get_neighbors`, `shortest_path`,
`list_prs`, `get_pr_impact`, `triage_prs` as MCP tools. `--transport http`
lets a whole team point at one shared server instead of each developer
running their own local process.

## PR dashboard

```
graphify prs                # CI state, review status, worktree mapping
graphify prs 42              # deep dive on PR #42 with graph impact
graphify prs --triage        # rank the review queue with whatever backend is configured
graphify prs --conflicts     # PRs sharing graph communities — merge-order risk
```

## Uninstalling

```
graphify uninstall                              # remove from all platforms
graphify uninstall --purge                      # also delete graphify-out/
graphify uninstall --project --platform claude   # remove just this repo's Claude Code integration
```
