#!/usr/bin/env bash
# Batch update. Run only when the whole script is authorized. Procedure: SKILL.md upgrade section.
# Apt: root pass (`wsl.exe -d Ubuntu -u root -- bash -lc` this script).
# User channels (mise / uv / opencli / agent-browser): Linux user pass (`wsl.exe -d Ubuntu -- bash -lc`).
# Do not install undeclared runtimes.
set +e

section() {
  printf '\n## %s\n' "$1"
}

run_or_none() {
  if command -v "$1" >/dev/null 2>&1; then
    "$@"
    printf 'exit=%s\n' "$?"
  else
    printf 'none %s\n' "$1"
  fi
}

EUID_NOW="$(id -u)"

section 'apt'
export DEBIAN_FRONTEND=noninteractive
if ! command -v apt-get >/dev/null 2>&1; then
  printf 'none\n'
elif [ "$EUID_NOW" -eq 0 ]; then
  apt-get update
  printf 'update-exit=%s\n' "$?"
  apt-get upgrade -y
  printf 'upgrade-exit=%s\n' "$?"
elif sudo -n true >/dev/null 2>&1; then
  sudo -n apt-get update
  printf 'update-exit=%s\n' "$?"
  sudo -n apt-get upgrade -y
  printf 'upgrade-exit=%s\n' "$?"
else
  printf 'apt skipped on this pass; root invocation runs apt-get update and upgrade\n'
  printf 'update-exit=skip\n'
  printf 'upgrade-exit=skip\n'
fi

if [ "$EUID_NOW" -eq 0 ]; then
  printf 'skip user-channel tools as root; rerun as the Linux user for mise/uv/opencli/agent-browser\n'
  exit 0
fi

if [ -r "$HOME/.config/wsl-env.sh" ]; then
  # shellcheck disable=SC1091
  . "$HOME/.config/wsl-env.sh"
fi
export PATH="$HOME/.local/bin:$HOME/.grok/bin:$PATH"

section 'mise self-update'
run_or_none mise self-update -y

section 'mise install (pinned tools)'
run_or_none mise install

section 'uv'
run_or_none uv self update
run_or_none uv tool upgrade --all

section 'pnpm global'
if command -v pnpm >/dev/null 2>&1; then
  for pkg in @jackwener/opencli agent-browser; do
    pnpm add -g "$pkg"
    printf '%s add-exit=%s\n' "$pkg" "$?"
    pnpm approve-builds -g "$pkg"
    printf '%s approve-exit=%s\n' "$pkg" "$?"
  done
else
  printf 'none pnpm\n'
fi
