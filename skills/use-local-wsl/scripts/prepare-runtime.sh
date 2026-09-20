#!/usr/bin/env bash
# Install declared project runtimes that are missing.
# Python: uv python install from .python-version
# Node/pnpm and other mise tools: mise install in the project directory
# Does not migrate lockfiles, apt, or npm -g.
set -euo pipefail

DRY=0
if [ "${1:-}" = "--dry-run" ]; then
  DRY=1
  shift
fi

ROOT="${1:-.}"
if [ ! -d "$ROOT" ]; then
  printf '%s\n' "not-a-directory $ROOT" >&2
  exit 2
fi
ROOT="$(CDPATH= cd -- "$ROOT" && pwd)"
HOME_DIR="${HOME:-/home/ark}"

case "$ROOT" in
  /|"$HOME_DIR")
    printf '%s\n' "refuse $ROOT" >&2
    exit 2
    ;;
esac

run() {
  if [ "$DRY" -eq 1 ]; then
    printf 'dry-run %s\n' "$*"
    return 0
  fi
  printf 'run %s\n' "$*"
  "$@"
}

if [ -f "$ROOT/.python-version" ]; then
  pin="$(grep -v '^#' "$ROOT/.python-version" | head -n1 | tr -d '[:space:]')"
  if [ -n "$pin" ]; then
    if uv python find "$pin" >/dev/null 2>&1; then
      printf 'python %s already-installed\n' "$pin"
    else
      run uv python install "$pin"
    fi
  fi
fi

if command -v mise >/dev/null 2>&1; then
  if [ -f "$ROOT/mise.toml" ] || [ -f "$ROOT/.nvmrc" ] || [ -f "$ROOT/.node-version" ] \
    || [ -f "$ROOT/.tool-versions" ] || [ -f "$ROOT/package.json" ]; then
    if [ "$DRY" -eq 1 ]; then
      printf 'dry-run mise install (cd %s)\n' "$ROOT"
    else
      printf 'run mise install (cd %s)\n' "$ROOT"
      (CDPATH= cd -- "$ROOT" && mise install)
    fi
  fi
fi

printf 'status=ok dry_run=%s root=%s\n' "$DRY" "$ROOT"
exit 0
