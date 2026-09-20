#!/usr/bin/env bash
set -euo pipefail
here=$(cd "$(dirname "$0")" && pwd)
ps1=$(wslpath -w "$here/${0##*/}")
ps1=${ps1%.sh}.ps1
exec /mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe -NoProfile -ExecutionPolicy Bypass -File "$ps1" "$@"
