#!/usr/bin/env bash
# Live-check WSL package managers. Print status only; do not classify, apt-get update, or write back.
set +e

section() {
  printf '\n## %s\n' "$1"
}

run_or_none() {
  if command -v "$1" >/dev/null 2>&1; then
    "$@" 2>&1
  else
    printf 'none\n'
  fi
}

export PATH="$HOME/.local/bin:$HOME/.grok/bin:$PATH"
# Login env (mise, proxy) comes from bash -lc. If missing, load wsl-env.sh.
if ! command -v mise >/dev/null 2>&1 && [ -r "$HOME/.config/wsl-env.sh" ]; then
  # shellcheck disable=SC1091
  . "$HOME/.config/wsl-env.sh"
fi

section 'apt + unattended-upgrades'
printf 'apt-lists=not-refreshed\n'
if [ -d /var/lib/apt/lists ]; then
  latest=$(find /var/lib/apt/lists -maxdepth 1 -type f \( -name '*InRelease' -o -name '*Release' \) -printf '%T@\n' 2>/dev/null | sort -n | tail -n 1)
  if [ -n "$latest" ]; then
    secs=${latest%%.*}
    printf 'apt-lists-mtime=%s\n' "$(date -d "@$secs" '+%Y-%m-%d %H:%M:%S %z' 2>/dev/null || printf 'unknown')"
  else
    printf 'apt-lists-mtime=none\n'
  fi
else
  printf 'apt-lists-mtime=none\n'
fi
if command -v apt-get >/dev/null 2>&1; then
  apt-get -s upgrade
  printf '\n--- apt list --upgradable ---\n'
  apt list --upgradable 2>/dev/null
else
  printf 'none\n'
fi

if command -v dpkg-query >/dev/null 2>&1; then
  dpkg-query -W unattended-upgrades 2>/dev/null || printf 'unattended-upgrades none\n'
fi
if command -v systemctl >/dev/null 2>&1; then
  printf 'unattended-upgrades enabled=%s active=%s\n' \
    "$(systemctl is-enabled unattended-upgrades.service 2>/dev/null)" \
    "$(systemctl is-active unattended-upgrades.service 2>/dev/null)"
  if [ -r /etc/apt/apt.conf.d/50unattended-upgrades ]; then
    printf '\n--- unattended Allowed-Origins ---\n'
    grep -E 'Allowed-Origins|distro_codename|-security|-updates' /etc/apt/apt.conf.d/50unattended-upgrades 2>/dev/null | grep -v '//' || true
  fi
fi

section 'snap'
if command -v snap >/dev/null 2>&1; then
  snap list 2>&1
else
  printf 'none\n'
fi

section 'mise / Node'
if command -v mise >/dev/null 2>&1; then
  printf 'mise: %s\n' "$(mise --version 2>/dev/null)"
  printf 'mise source: %s\n' "$(command -v mise)"
  mise doctor 2>/dev/null | grep -E 'self_update_available|version:' || true
  mise ls node 2>/dev/null
  printf 'node: %s\n' "$(node -v 2>/dev/null)"
  printf 'npm: %s\n' "$(npm -v 2>/dev/null)"
  printf 'pnpm: %s\n' "$(pnpm -v 2>/dev/null)"
  npm -g ls --depth=0 2>/dev/null
  pnpm list -g --depth=0 2>/dev/null
else
  printf 'mise none\n'
  run_or_none node -v
fi

section 'uv'
if command -v uv >/dev/null 2>&1; then
  uv self version 2>&1
  printf '\n--- uv tool list ---\n'
  uv tool list 2>&1
  printf '\n--- uv tool outdated ---\n'
  uv tool list --outdated 2>&1
else
  printf 'none\n'
fi

section 'Docker CE'
if command -v docker >/dev/null 2>&1; then
  docker version 2>&1
  docker compose version 2>&1
  if command -v apt-cache >/dev/null 2>&1; then
    printf '\n--- docker apt installed/candidate ---\n'
    for p in docker-ce docker-ce-cli docker-compose-plugin containerd.io; do
      apt-cache policy "$p" 2>/dev/null | awk -v pkg="$p" '
        NR==1 { print pkg }
        /已安装|Installed|候选|Candidate/ { print }
      '
    done
  fi
else
  printf 'none\n'
fi

section 'grok / codex / agy'
for c in grok codex agy pi claude opencode; do
  if command -v "$c" >/dev/null 2>&1; then
    printf '%s %s\n' "$c" "$("$c" --version 2>&1 | head -n 1)"
  else
    printf '%s none\n' "$c"
  fi
done
