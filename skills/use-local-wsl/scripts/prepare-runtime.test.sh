#!/usr/bin/env bash
set -euo pipefail
_src="${BASH_SOURCE[0]}"
case "$_src" in
  /*) ;;
  *) _src="$PWD/$_src" ;;
esac
HERE="${_src%/*}"
PREP="${HERE}/prepare-runtime.sh"
bash -n "$PREP"

rc=0
bash "$PREP" --dry-run /nonexistent 2>/dev/null || rc=$?
[ "$rc" -eq 2 ]

rc=0
bash "$PREP" --dry-run "$HOME" >/dev/null || rc=$?
[ "$rc" -eq 2 ]

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
printf '3.13\n' > "$TMP/.python-version"
out="$(bash "$PREP" --dry-run "$TMP")"
printf '%s\n' "$out" | grep -q 'python 3.13 already-installed\|dry-run uv python install'
printf '%s\n' "$out" | grep -q '^status=ok dry_run=1'

printf 'ok: prepare-runtime tests passed\n'
