#!/usr/bin/env bash
# Reapply local cliproxy patches after `pi update` of
# git:github.com/algal/pi-openai-server-compaction
set -euo pipefail
EXT="${HOME}/.pi/agent/git/github.com/algal/pi-openai-server-compaction"
ROOT="$(cd "$(dirname "$0")" && pwd)"
OPENAI_SRC="${ROOT}/openai.ts.patched"
REMOTE_SRC="${ROOT}/remote-compaction.ts.patched"

if [[ ! -d "$EXT" ]]; then
  echo "extension not installed at $EXT" >&2
  exit 1
fi
if [[ ! -f "$OPENAI_SRC" ]]; then
  echo "missing patched source $OPENAI_SRC" >&2
  exit 1
fi
if [[ ! -f "$REMOTE_SRC" ]]; then
  echo "missing patched source $REMOTE_SRC" >&2
  exit 1
fi

if [[ ! -f "$EXT/src/openai.ts.orig" ]]; then
  cp -a "$EXT/src/openai.ts" "$EXT/src/openai.ts.orig"
fi
if [[ ! -f "$EXT/src/remote-compaction.ts.orig" ]]; then
  cp -a "$EXT/src/remote-compaction.ts" "$EXT/src/remote-compaction.ts.orig"
fi

cp -a "$OPENAI_SRC" "$EXT/src/openai.ts"
cp -a "$REMOTE_SRC" "$EXT/src/remote-compaction.ts"
echo "reapplied cliproxy patches -> $EXT/src/openai.ts"
echo "reapplied cliproxy patches -> $EXT/src/remote-compaction.ts"
