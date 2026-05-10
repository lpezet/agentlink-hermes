#!/bin/bash
# Convenience wrapper for running Hermes Agent against the local skills checkout.
# Run from anywhere; script resolves paths relative to the repo root.
#
# Usage:
#   ./tests/hermes/run.sh [setup|configure|chat]
#
#   setup      - First-time Hermes initialisation (pick model, API key, etc.)
#   configure  - Add the local skills/ dir as an External Skill Directory
#   chat       - Open an interactive chat session (default)

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
SKILLS_DIR="$REPO_ROOT/skills"
DATA_DIR="${HERMES_DATA_DIR:-$HOME/.hermes-agentlink-skills}"
IMAGE="${HERMES_IMAGE:-agentlink-hermes}"

COMMON_ARGS=(
  -it --rm
  -v "$DATA_DIR:/opt/data"
  -v "$SKILLS_DIR:/opt/agentlink-skills"
)

CMD="${1:-chat}"

case "$CMD" in
  setup)
    docker run "${COMMON_ARGS[@]}" "$IMAGE" setup
    ;;
  configure)
    docker run "${COMMON_ARGS[@]}" "$IMAGE" \
      -z "Add the following directory as External Skill Directory in your existing \`skills.external_dirs\` configuration: /opt/agentlink-skills/"
    ;;
  chat)
    docker run "${COMMON_ARGS[@]}" "$IMAGE"
    ;;
  *)
    echo "Unknown command: $CMD" >&2
    echo "Usage: $0 [setup|configure|chat]" >&2
    exit 1
    ;;
esac
