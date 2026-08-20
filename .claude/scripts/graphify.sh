#!/usr/bin/env bash
#
# .claude/scripts/graphify.sh
#
# Installs Graphify (https://github.com/Graphify-Labs/graphify) if needed,
# builds or incrementally updates a knowledge graph of this codebase, and
# wires Graphify into Claude Code as an always-on knowledge source.
#
# Graphify owns its own output directory at the repository root:
#
#   graphify-out/
#
# Nothing is moved, copied, or symlinked by this script.
#
# The script itself lives in .claude/scripts/.
#
# RE-RUNNING THIS SCRIPT IS THE UPDATE PATH.
# If graphify-out/graph.json already exists, this script runs an incremental
# `graphify update` instead of a full `graphify extract`.
#
# Usage:
#   .claude/scripts/graphify.sh              # local-only, code AST, no API key
#   .claude/scripts/graphify.sh --full       # + semantic pass over docs/PDFs/
#                                             #   images (needs an LLM API key)
#   .claude/scripts/graphify.sh --force      # overwrite even if graph shrinks
#   .claude/scripts/graphify.sh --full --force
#
# Env (only read when --full is used and no key is already exported):
#   ANTHROPIC_API_KEY, GEMINI_API_KEY / GOOGLE_API_KEY, OPENAI_API_KEY
#

set -euo pipefail

# ---------------------------------------------------------------------------
# 0. Resolve paths
# ---------------------------------------------------------------------------

# Prefer git's own idea of the repo root (robust to being invoked from any
# subdirectory); fall back to walking up from this script's location.
SCRIPT_DIR="$(
  cd -- "$(dirname -- "${BASH_SOURCE[0]}")" >/dev/null 2>&1 &&
    pwd -P
)"

if REPO_ROOT="$(git -C "$SCRIPT_DIR" rev-parse --show-toplevel 2>/dev/null)"; then
  :
else
  REPO_ROOT="$(
    cd -- "$SCRIPT_DIR/../.." >/dev/null 2>&1 &&
      pwd -P
  )"
fi

OUT_DIR="$REPO_ROOT/graphify-out"
GRAPH_JSON="$OUT_DIR/graph.json"
MODE_FILE="$OUT_DIR/.graphify-mode"
IGNORE_FILE="$REPO_ROOT/.graphifyignore"

if [ ! -d "$REPO_ROOT/.claude" ]; then
  echo "[graphify] couldn't find a .claude/ directory under repo root ($REPO_ROOT)." >&2
  echo "[graphify] this script expects to run from inside a repo that has .claude/scripts/graphify.sh." >&2
  exit 1
fi

MODE="code-only"
FORCE_FLAG=""

for arg in "$@"; do
  case "$arg" in
    --full)
      MODE="full"
      ;;
    --force)
      FORCE_FLAG="--force"
      ;;
    -h|--help)
      sed -n '2,40p' "$0" | sed 's/^# \{0,1\}//'
      exit 0
      ;;
    *)
      echo "[graphify] unknown option: $arg" >&2
      exit 1
      ;;
  esac
done

log() {
  printf '\n\033[1;34m[graphify]\033[0m %s\n' "$1"
}

warn() {
  printf '\033[1;33m[graphify][warn]\033[0m %s\n' "$1" >&2
}

# ---------------------------------------------------------------------------
# 1. Install graphify + dependencies if not already present
# ---------------------------------------------------------------------------

ensure_python() {
  if ! command -v python3 >/dev/null 2>&1; then
    warn "python3 not found. Install Python 3.10+ and re-run."
    exit 1
  fi

  local pyver
  pyver="$(
    python3 -c \
      'import sys; print("%d.%d" % sys.version_info[:2])'
  )"

  case "$pyver" in
    3.10|3.11|3.12|3.13|3.14)
      ;;
    *)
      warn "system python3 is $pyver (graphify needs 3.10+ to run) — harmless if uv installs its own; only matters if 'uv tool install' falls back to this interpreter."
      ;;
  esac
}

ensure_uv() {
  if command -v uv >/dev/null 2>&1; then
    return
  fi

  log "uv not found — installing it (astral.sh installer)"

  curl -LsSf https://astral.sh/uv/install.sh | sh

  export PATH="$HOME/.local/bin:$PATH"

  if ! command -v uv >/dev/null 2>&1; then
    warn "uv installed but not on PATH yet. Run 'uv tool update-shell', open a new terminal, and re-run this script."
    exit 1
  fi
}

ensure_graphify() {
  if command -v graphify >/dev/null 2>&1; then
    log "graphify already installed ($(graphify --version 2>/dev/null || echo present))"
    return
  fi

  log "Installing graphify (PyPI package: graphifyy)"

  uv tool install graphifyy

  export PATH="$HOME/.local/bin:$PATH"

  if ! command -v graphify >/dev/null 2>&1; then
    warn "graphify installed but not on PATH yet. Run 'uv tool update-shell', open a new terminal, and re-run this script."
    exit 1
  fi
}

log "Checking prerequisites"

ensure_python
ensure_uv
ensure_graphify

# ---------------------------------------------------------------------------
# 2. Ignore Graphify's own output
# ---------------------------------------------------------------------------
#
# Graphify writes its output to:
#
#   <repo-root>/graphify-out/
#
# We don't move or symlink this directory. We simply make sure the generated
# graph doesn't become part of the graph itself or accidentally get committed.
#

if [ ! -f "$IGNORE_FILE" ] || ! grep -qxF 'graphify-out/' "$IGNORE_FILE" 2>/dev/null; then
  {
    echo ''
    echo '# added by .claude/scripts/graphify.sh — do not graph Graphify output'
    echo 'graphify-out/'
  } >> "$IGNORE_FILE"

  log "Added graphify-out/ to .graphifyignore"
fi

# ---------------------------------------------------------------------------
# 3. Build the graph (first run) or update it (subsequent runs)
# ---------------------------------------------------------------------------

cd "$REPO_ROOT"

BACKEND_FLAG=""

if [ "$MODE" = "full" ]; then
  if [ -n "${ANTHROPIC_API_KEY:-}" ]; then
    BACKEND_FLAG="--backend claude"
  elif [ -n "${GEMINI_API_KEY:-}${GOOGLE_API_KEY:-}" ]; then
    BACKEND_FLAG="--backend gemini"
  elif [ -n "${OPENAI_API_KEY:-}" ]; then
    BACKEND_FLAG="--backend openai"
  else
    warn "No ANTHROPIC_API_KEY / GEMINI_API_KEY / OPENAI_API_KEY set for --full extraction."
    warn "Falling back to --code-only (local AST parsing, no docs/PDFs/images, no API key needed)."

    MODE="code-only"
  fi
fi

if [ -f "$GRAPH_JSON" ]; then
  log "Existing graph found at graphify-out/graph.json — running incremental update"

  if [ "$MODE" = "full" ]; then
    log "Full mode requested; Graphify will update using its configured backend"
  fi

  # shellcheck disable=SC2086
  graphify update "$REPO_ROOT" $FORCE_FLAG

else
  log "No existing graph — running full extraction (mode: $MODE)"

  if [ "$MODE" = "code-only" ]; then
    # shellcheck disable=SC2086
    graphify extract "$REPO_ROOT" --code-only $FORCE_FLAG
  else
    # shellcheck disable=SC2086
    graphify extract "$REPO_ROOT" $BACKEND_FLAG $FORCE_FLAG
  fi
fi

# Persist the mode used by this script.
printf '%s\n' "$MODE" > "$MODE_FILE"

# ---------------------------------------------------------------------------
# 4. Make Claude Code always consult the graph
# ---------------------------------------------------------------------------

log "Registering the /graphify skill with Claude Code (project-scoped)"

graphify install --project

log "Enabling always-on graph guidance (CLAUDE.md + PreToolUse hook, project-scoped)"

graphify claude install --project

# ---------------------------------------------------------------------------
# 5. Done
# ---------------------------------------------------------------------------

log "Done."

echo
echo "  Report:  graphify-out/GRAPH_REPORT.md"
echo "  Graph:   graphify-out/graph.json"
echo "  Visual:  graphify-out/graph.html   (open in a browser)"
echo
echo "Claude will now be nudged to run 'graphify query \"<question>\"' before"
echo "grepping or reading files one by one."
echo
echo "Re-run this script (including after a git pull) to refresh the graph"
echo "incrementally:"
echo
echo "  .claude/scripts/graphify.sh"`