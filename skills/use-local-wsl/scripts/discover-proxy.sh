#!/usr/bin/env bash
# Discover WSL proxy endpoint from files. Do not write ports back to the skill.
set +e

FILE="${HOME}/.config/proxy-env.sh"
printf '## source file\n'
if [ -r "$FILE" ]; then
  printf 'path=%s\n' "$FILE"
  # Print proxy-related assignments without dumping secrets from elsewhere.
  grep -E '^(export[[:space:]]+)?(http_proxy|https_proxy|HTTP_PROXY|HTTPS_PROXY|all_proxy|ALL_PROXY|no_proxy|NO_PROXY)=' "$FILE" || true
else
  printf 'missing %s\n' "$FILE"
  exit 0
fi

# shellcheck disable=SC1090
. "$FILE"

url="${http_proxy:-${HTTP_PROXY:-${all_proxy:-$ALL_PROXY}}}"
printf '\n## parsed\n'
printf 'url=%s\n' "${url:-none}"
port="$(printf '%s' "$url" | sed -n 's/.*:\([0-9][0-9]*\)\/*$/\1/p')"
printf 'port=%s\n' "${port:-none}"
printf 'no_proxy=%s\n' "${no_proxy:-${NO_PROXY:-none}}"

printf '\n## profile loads proxy-env.sh\n'
for f in "${HOME}/.profile" "${HOME}/.bashrc"; do
  if grep -q 'proxy-env.sh' "$f" 2>/dev/null; then
    printf '%s: yes\n' "$f"
  else
    printf '%s: no\n' "$f"
  fi
done

if [ -n "$port" ]; then
  printf '\n## Windows listen on port %s\n' "$port"
  /mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe \
    -NoLogo -NoProfile -Command \
    "Get-NetTCPConnection -LocalPort $port -State Listen -ErrorAction SilentlyContinue | Select-Object LocalAddress,LocalPort,OwningProcess | Format-Table -AutoSize"
fi
