# Graphify — Troubleshooting

Standalone reference. Condensed from Graphify's own troubleshooting notes,
adapted for this repo's layout (data under `.claude/graph/graphify-out/`,
symlinked as `graphify-out` at the repo root).

## `graphify: command not found`

The CLI's bin directory isn't on `PATH` yet.

- Installed with `uv tool install graphifyy`: run `uv tool update-shell`,
  then open a new terminal. (`uv tool dir --bin` shows the directory.)
- Installed with `pipx`: run `pipx ensurepath`, then open a new terminal.
- Installed with plain `pip`: add `~/Library/Python/3.x/bin` (macOS) or
  `~/.local/bin` (Linux) to `PATH`, or just run `python -m graphify`.

## Graph has fewer nodes after an update/rebuild

If files were deleted in a refactor, old nodes can linger. Re-run with
`--force`:

```
.claude/scripts/graphify.sh --force
```

## "extraction was incomplete ... refusing to overwrite"

An extraction pass crashed or couldn't fully read the corpus, so Graphify
refused to overwrite a larger existing graph with a partial result — this
protects `graph.json`. Fix the underlying failure and re-run, or pass
`--force` deliberately if the partial result is acceptable.

## Duplicate nodes for the same entity (ghost duplicates)

Recent Graphify versions merge these automatically at build time. If seen
on an older graph, a full re-extract clears it up:

```
.claude/scripts/graphify.sh --full --force
```

## `LLM returned invalid JSON` / `Unterminated string` warnings (full mode only)

The model's response hit its output-token limit mid-string during semantic
extraction. Graphify auto-recovers by splitting and re-extracting the
affected chunk, so these warnings are noisy rather than lossy. To reduce
churn, raise the output cap:

```
GRAPHIFY_MAX_OUTPUT_TOKENS=16384 .claude/scripts/graphify.sh --full
```

## Graph HTML too large to open in a browser (thousands of nodes)

Skip the HTML and work from the JSON/CLI directly — `graph.html` is a
convenience visualization, not required for querying:

```
graphify query "..." --graph graphify-out/graph.json
```

## `graph.json` shows conflict markers after two people commit at once

```
graphify hook install
```

sets up a git merge driver so concurrent commits to `graph.json` are
union-merged automatically instead of leaving conflict markers.

## Extraction returns empty nodes/edges for docs or PDFs

Docs, PDFs, and images require an LLM call — code-only builds correctly
skip them. Confirm an API key is set and run in full mode:

```
ANTHROPIC_API_KEY=sk-... .claude/scripts/graphify.sh --full
```

## Skill version mismatch warning in Claude Code

The installed `graphify` CLI version differs from the installed skill
file. Update both:

```
uv tool upgrade graphifyy
.claude/scripts/graphify.sh
```

(the script re-runs `graphify install --project` and
`graphify claude install --project`, refreshing the skill file)

## The `graphify-out` symlink is missing or broken

`.claude/scripts/graphify.sh` recreates it automatically on the next run. If
something else occupies `./graphify-out` at the repo root and isn't a
symlink, the script will stop and ask you to move or remove it first
rather than overwrite unrelated data.
