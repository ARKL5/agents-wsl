#!/usr/bin/env bash
# Read-only live-check for Windows use-local-windows AUDIT.md steps 1-3.
# Step 4 prints would-fix lists only. Do not chmod/rm/npm/apt/shutdown.
set +e
umask 022

HOME_DIR="${HOME:-/home/ark}"
SCRIPT_DIR="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
DISCOVER="${SCRIPT_DIR}/discover-proxy.sh"
PROXY_ENV="${HOME_DIR}/.config/proxy-env.sh"
WSLCONFIG="/mnt/c/Users/38993/.wslconfig"
SECRETS="${HOME_DIR}/.env.secrets"
LEFTOVER="/home/ark/CODE/ARK-skills/scripts/wsl/strip-leftover-links.py"
PS="/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe"
WSL_EXE="/mnt/c/Windows/System32/wsl.exe"

# INSTALL_POLICY.md global-npm allowlist (do not copy into AUDIT.md).
NPM_ALLOW='@earendil-works/pi-coding-agent @jackwener/opencli pi opencli'
NPM_KEEP='npm corepack'

SAFE_FIXES=()
GATE_FIXES=()

printf_kv() {
  printf '%s=%s\n' "$1" "$2"
}

mark_safe() {
  SAFE_FIXES+=("$1")
}

mark_gate() {
  GATE_FIXES+=("$1")
}

status_of() {
  # status_of NAME ok|fail|observed reason
  printf 'status=%s name=%s detail=%s\n' "$2" "$1" "$3"
}

load_nvm() {
  export NVM_DIR="${NVM_DIR:-$HOME_DIR/.nvm}"
  if [ -s "${NVM_DIR}/nvm.sh" ]; then
    # shellcheck disable=SC1091
    . "${NVM_DIR}/nvm.sh"
    return 0
  fi
  return 1
}

is_loopback_no_proxy() {
  # Contract: only localhost, 127.0.0.1, ::1
  python3 - "$1" <<'PY'
import sys
raw = sys.argv[1] if len(sys.argv) > 1 else ""
if raw in ("", "none"):
    sys.exit(1)
parts = [p.strip() for p in raw.replace(";", ",").split(",") if p.strip()]
allowed = {"localhost", "127.0.0.1", "::1"}
sys.exit(0 if parts and set(parts) <= allowed else 1)
PY
}

summarize_proxy_value() {
  python3 - "$1" <<'PY'
import sys, re
s = sys.argv[1] if len(sys.argv) > 1 else ""
if not s:
    print("absent")
    raise SystemExit
m = re.match(r"^([a-zA-Z][a-zA-Z0-9+.-]*)://([^/:]+)(?::(\d+))?", s)
if m:
    port = m.group(3) or "none"
    print(f"scheme={m.group(1)} host={m.group(2)} port={port}")
else:
    print("set")
PY
}

echo '======== 步1 机器合同 ========'

echo '--- discover-proxy.sh ---'
if [ -x "$DISCOVER" ] || [ -f "$DISCOVER" ]; then
  bash "$DISCOVER"
  printf_kv 'discover-proxy' 'ran'
else
  printf_kv 'discover-proxy' "fail missing ${DISCOVER}"
fi

echo
echo '--- no_proxy contract ---'
NO_PROXY_VAL='none'
if [ -r "$PROXY_ENV" ]; then
  # shellcheck disable=SC1090
  . "$PROXY_ENV"
  NO_PROXY_VAL="${no_proxy:-${NO_PROXY:-none}}"
fi
printf_kv 'no_proxy' "$NO_PROXY_VAL"
if is_loopback_no_proxy "$NO_PROXY_VAL"; then
  status_of 'no_proxy' pass 'only-loopback'
else
  status_of 'no_proxy' fail 'not-only-loopback'
  mark_gate 'shell no_proxy (proxy-env.sh) — not-done'
fi

echo
echo '--- NETWORK_PROXY.md layers ---'

# Shell
echo '## layer=Shell'
if [ -r "$PROXY_ENV" ]; then
  printf_kv 'file' "$PROXY_ENV"
  printf_kv 'exists' yes
  grep -E '^(export[[:space:]]+)?(http_proxy|https_proxy|HTTP_PROXY|HTTPS_PROXY|all_proxy|ALL_PROXY|no_proxy|NO_PROXY|NODE_USE_ENV_PROXY)=' "$PROXY_ENV" \
    | sed -E 's/=.*/=set/'
  prof_yes=0
  for f in "${HOME_DIR}/.profile" "${HOME_DIR}/.bashrc"; do
    if grep -q 'proxy-env.sh' "$f" 2>/dev/null; then
      printf_kv "$(basename "$f")_loads_proxy_env" yes
      prof_yes=1
    else
      printf_kv "$(basename "$f")_loads_proxy_env" no
    fi
  done
  if [ "$prof_yes" -eq 1 ]; then
    status_of 'Shell' pass 'proxy-env+profile'
  else
    status_of 'Shell' fail 'profile-does-not-source-proxy-env'
    mark_gate 'shell proxy-env profile load — not-done'
  fi
else
  printf_kv 'exists' no
  status_of 'Shell' fail "missing ${PROXY_ENV}"
  mark_gate 'shell proxy-env.sh missing — not-done'
fi

# APT
echo '## layer=APT'
APT_FILE='/etc/apt/apt.conf.d/80proxy'
if [ -r "$APT_FILE" ]; then
  printf_kv 'file' "$APT_FILE"
  printf_kv 'exists' yes
  if grep -q 'Acquire::http::Proxy' "$APT_FILE" && grep -q 'Acquire::https::Proxy' "$APT_FILE"; then
    printf_kv 'Acquire::http::Proxy' present
    printf_kv 'Acquire::https::Proxy' present
    status_of 'APT' pass '80proxy-present'
  else
    printf_kv 'keys' incomplete
    status_of 'APT' fail '80proxy-missing-keys'
    mark_gate 'APT /etc/apt/apt.conf.d/80proxy — not-done'
  fi
else
  printf_kv 'file' "$APT_FILE"
  printf_kv 'exists' no
  status_of 'APT' fail 'missing'
  mark_gate 'APT /etc/apt/apt.conf.d/80proxy — not-done'
fi

# Git HTTP(S)
echo '## layer=Git-HTTP'
GIT_PROXY="$(git config --global --get http.proxy 2>/dev/null)"
GIT_SPROXY="$(git config --global --get https.proxy 2>/dev/null)"
if [ -n "$GIT_PROXY$GIT_SPROXY" ]; then
  printf_kv 'git-http.proxy' set
  printf_kv 'git-https.proxy' "$([ -n "$GIT_SPROXY" ] && echo set || echo absent)"
  status_of 'Git-HTTP' pass 'git-config-proxy'
else
  printf_kv 'git-http.proxy' inherit-shell
  status_of 'Git-HTTP' pass 'inherit-shell'
fi

# GitHub SSH
echo '## layer=GitHub-SSH'
SSH_CFG="${HOME_DIR}/.ssh/config"
if [ -r "$SSH_CFG" ]; then
  printf_kv 'file' "$SSH_CFG"
  printf_kv 'exists' yes
  if grep -Eiq 'ProxyCommand' "$SSH_CFG" && grep -Eq 'nc .*-x' "$SSH_CFG"; then
    printf_kv 'ProxyCommand' 'present (nc -x)'
    status_of 'GitHub-SSH' pass 'proxycommand-nc'
  else
    printf_kv 'ProxyCommand' absent-or-not-nc-x
    status_of 'GitHub-SSH' fail 'no-proxycommand'
    mark_gate 'GitHub SSH ~/.ssh/config ProxyCommand — not-done'
  fi
else
  printf_kv 'file' "$SSH_CFG"
  printf_kv 'exists' no
  status_of 'GitHub-SSH' fail 'missing-ssh-config'
  mark_gate 'GitHub SSH ~/.ssh/config — not-done'
fi

# Node
echo '## layer=Node'
NODE_FLAG='absent'
if [ -r "$PROXY_ENV" ] && grep -qE '^(export[[:space:]]+)?NODE_USE_ENV_PROXY=' "$PROXY_ENV"; then
  NODE_FLAG="$(grep -E '^(export[[:space:]]+)?NODE_USE_ENV_PROXY=' "$PROXY_ENV" | tail -n1 | sed -E 's/^[^=]+=//; s/^["'\'']//; s/["'\'']$//')"
fi
printf_kv 'NODE_USE_ENV_PROXY' "${NODE_FLAG}"
printf_kv 'http_proxy' inherit-shell
if [ "$NODE_FLAG" = "1" ] || [ "$NODE_FLAG" = "true" ]; then
  status_of 'Node' pass 'NODE_USE_ENV_PROXY+inherit-shell'
else
  status_of 'Node' fail 'NODE_USE_ENV_PROXY-not-set'
  mark_gate 'Node NODE_USE_ENV_PROXY in proxy-env.sh — not-done'
fi

# Docker daemon
echo '## layer=Docker-daemon'
DOCK_FILE='/etc/systemd/system/docker.service.d/http-proxy.conf'
if [ -r "$DOCK_FILE" ]; then
  printf_kv 'file' "$DOCK_FILE"
  printf_kv 'exists' yes
  dock_ok=1
  for k in HTTP_PROXY HTTPS_PROXY NO_PROXY; do
    if grep -q "$k=" "$DOCK_FILE"; then
      printf_kv "$k" present
    else
      printf_kv "$k" absent
      dock_ok=0
    fi
  done
  DOCK_NO="$(grep -oE 'NO_PROXY=[^"]+' "$DOCK_FILE" 2>/dev/null | sed 's/^NO_PROXY=//')"
  if [ -n "$DOCK_NO" ]; then
    if is_loopback_no_proxy "$DOCK_NO"; then
      printf_kv 'NO_PROXY_loopback' yes
    else
      printf_kv 'NO_PROXY_loopback' no
      dock_ok=0
    fi
  fi
  if [ "$dock_ok" -eq 1 ]; then
    status_of 'Docker-daemon' pass 'drop-in-present'
  else
    status_of 'Docker-daemon' fail 'drop-in-incomplete'
    mark_gate 'dockerd /etc/systemd/system/docker.service.d/http-proxy.conf — not-done'
  fi
else
  printf_kv 'file' "$DOCK_FILE"
  printf_kv 'exists' no
  status_of 'Docker-daemon' fail 'missing-drop-in'
  mark_gate 'dockerd http-proxy.conf — not-done'
fi

# WSL Chrome
echo '## layer=WSL-Chrome'
CHROME_BIN='/usr/local/bin/wsl-chrome'
if [ -r "$CHROME_BIN" ]; then
  printf_kv 'file' "$CHROME_BIN"
  printf_kv 'exists' yes
  if grep -q 'proxy-env.sh' "$CHROME_BIN"; then
    printf_kv 'sources_proxy_env' yes
    status_of 'WSL-Chrome' pass 'launcher-sources-proxy-env'
  else
    printf_kv 'sources_proxy_env' no
    status_of 'WSL-Chrome' fail 'launcher-no-proxy-env'
  fi
else
  printf_kv 'file' "$CHROME_BIN"
  printf_kv 'exists' no
  status_of 'WSL-Chrome' fail 'missing-wsl-chrome'
fi

# WinINet / WinHTTP
echo '## layer=WinINet-WinHTTP'
if [ -x "$PS" ]; then
  "$PS" -NoLogo -NoProfile -Command \
    "\$i=Get-ItemProperty 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings' -ErrorAction SilentlyContinue; if(\$i){ 'ProxyEnable=' + \$i.ProxyEnable; if(\$i.ProxyServer){'ProxyServer=set'}else{'ProxyServer=absent'}; if(\$i.AutoConfigURL){'AutoConfigURL=set'}else{'AutoConfigURL=absent'} } else { 'WinINet=unreadable' }"
else
  echo 'WinINet=fail powershell-missing'
fi
if [ -x /mnt/c/Windows/System32/netsh.exe ]; then
  echo '--- WinHTTP ---'
  /mnt/c/Windows/System32/netsh.exe winhttp show proxy
else
  echo 'WinHTTP=fail netsh-missing'
fi
status_of 'WinINet-WinHTTP' observed 'independent-of-wsl-shell'

echo
echo '--- .wslconfig vs LOCAL_WSL.md ---'
printf_kv 'path' "$WSLCONFIG"
if [ -r "$WSLCONFIG" ]; then
  printf_kv 'exists' yes
  echo 'keys:'
  grep -E '^[A-Za-z][A-Za-z0-9]*=' "$WSLCONFIG" || true
  nm="$(grep -E '^networkingMode=' "$WSLCONFIG" | tail -n1 | cut -d= -f2- | tr -d '[:space:]')"
  ap="$(grep -E '^autoProxy=' "$WSLCONFIG" | tail -n1 | cut -d= -f2- | tr -d '[:space:]')"
  dns="$(grep -E '^dnsTunneling=' "$WSLCONFIG" | tail -n1 | cut -d= -f2- | tr -d '[:space:]')"
  wsl_ok=1
  [ "$nm" = "mirrored" ] || { printf_kv 'networkingMode_expected' mirrored; wsl_ok=0; }
  [ "$ap" = "false" ] || { printf_kv 'autoProxy_expected' false; wsl_ok=0; }
  [ "$dns" = "true" ] || { printf_kv 'dnsTunneling_expected' true; wsl_ok=0; }
  if command -v wslinfo >/dev/null 2>&1; then
    printf_kv 'wslinfo_networkingMode' "$(wslinfo --networking-mode 2>/dev/null)"
  fi
  if [ "$wsl_ok" -eq 1 ]; then
    status_of '.wslconfig' pass 'intent-keys-match'
  else
    status_of '.wslconfig' fail 'intent-mismatch'
    mark_gate '.wslconfig autoProxy/networkingMode/dnsTunneling — not-done'
  fi
else
  printf_kv 'exists' no
  status_of '.wslconfig' fail 'missing'
  mark_gate '.wslconfig missing — not-done'
fi

echo
echo '--- autoProxy inheritance (no restart) ---'
INHERIT='no'
INJECTED="$("$WSL_EXE" -d Ubuntu -e /bin/bash --noprofile --norc -c 'printf %s "${http_proxy:-}|${HTTP_PROXY:-}|${WSL_PAC_URL:-}"' 2>/dev/null | tr -d '\0\r')"
printf_kv 'nested_wsl_injected' "${INJECTED:-empty}"
case "$INJECTED" in
  ''|'||') INHERIT='no' ;;
  http://*|https://*|HTTP://*|HTTPS://*|*\|http*|*\|HTTP*|*'pac'*|*'PAC'*) INHERIT='yes' ;;
  *) printf_kv 'inherit_raw_ignored' "$INJECTED"; INHERIT='no' ;;
esac
SYSENV="$(systemctl show-environment 2>/dev/null | grep -Ei '^(http_proxy|HTTP_PROXY|https_proxy|HTTPS_PROXY|WSL_PAC_URL)=' || true)"
if [ -n "$SYSENV" ]; then
  echo 'systemd-environment-proxy=present'
  INHERIT='yes'
else
  echo 'systemd-environment-proxy=absent'
fi
printf_kv 'autoProxy_file' "${ap:-unknown}"
printf_kv 'inherited_old_autoProxy' "$INHERIT"

echo
echo '--- wsl -l -v ---'
if [ -x "$PS" ]; then
  "$PS" -NoLogo -NoProfile -Command 'wsl.exe -l -v'
else
  "$WSL_EXE" -l -v 2>/dev/null | iconv -f UTF-16LE -t UTF-8 2>/dev/null || echo 'fail wsl.exe-list'
fi

# This process is already inside the distro; do not re-capture `wsl -l -v` (UTF-16 NUL).
DISTRO_RUNNING=1
printf_kv 'this_distro' "${WSL_DISTRO_NAME:-Ubuntu}"
if [ "$INHERIT" = "yes" ] && [ "$DISTRO_RUNNING" -eq 1 ]; then
  echo 'pending-restart=yes reason=running-and-still-inheriting-old-autoProxy'
  mark_gate '.wslconfig autoProxy (pending-restart; distro restart needs user interrupt) — not-done'
else
  echo 'pending-restart=no'
fi

echo
echo '======== 步2 安装漂移 ========'

echo '--- /usr/local user pip tree ---'
PIP_RESIDUE=0
shopt -s nullglob
for d in /usr/local/lib/python3.*/dist-packages; do
  printf_kv 'tree' "$d"
  if [ -d "$d" ]; then
    count="$(find "$d" -mindepth 1 -maxdepth 1 2>/dev/null | wc -l)"
    count="$(printf '%s' "$count" | tr -d '[:space:]')"
    printf_kv 'entries' "$count"
    if [ "$count" != "0" ]; then
      find "$d" -mindepth 1 -maxdepth 1 -printf 'residue %p\n' 2>/dev/null
      PIP_RESIDUE=1
    fi
  fi
done
SHEBANGS="$(grep -l '^#!.*python' /usr/local/bin/* 2>/dev/null)"
if [ -n "$SHEBANGS" ]; then
  printf '%s\n' "$SHEBANGS" | sed 's/^/python-shebang /'
  PIP_RESIDUE=1
else
  echo 'python-shebang=/usr/local/bin none'
fi
if [ "$PIP_RESIDUE" -eq 0 ]; then
  status_of 'usr-local-pip' pass 'empty'
else
  status_of 'usr-local-pip' fail 'residue'
  mark_safe 'erase /usr/local user pip tree — not-done'
fi
shopt -u nullglob

echo
echo '--- npm -g ls --depth=0 ---'
load_nvm
if command -v npm >/dev/null 2>&1; then
  echo 'npm-global-tree:'
  npm -g ls --depth=0 2>/dev/null || echo 'fail npm-g-ls'
  echo 'classified:'
  EXTRAS=0
  PARSE="$(npm -g ls --depth=0 --parseable 2>/dev/null)"
  if [ -z "$PARSE" ]; then
    echo 'fail npm-g-ls-parseable-empty'
  fi
  printf '%s\n' "$PARSE" | while IFS= read -r p; do
    [ -n "$p" ] || continue
    case "$p" in
      */node_modules/*) ;;
      *) continue ;;
    esac
    rel="${p##*/node_modules/}"
    [ -n "$rel" ] || continue
    case " $NPM_KEEP " in
      *" $rel "*) echo "keep ${rel}"; continue ;;
    esac
    case " $NPM_ALLOW " in
      *" $rel "*) echo "allow ${rel}"; continue ;;
    esac
    echo "extra ${rel}"
  done
  # Count extras in this shell (subshell above cannot set EXTRAS).
  EXTRA_LIST="$(printf '%s\n' "$PARSE" | while IFS= read -r p; do
    [ -n "$p" ] || continue
    case "$p" in */node_modules/*) ;; *) continue ;; esac
    rel="${p##*/node_modules/}"
    case " $NPM_KEEP $NPM_ALLOW " in
      *" $rel "*) continue ;;
    esac
    printf '%s\n' "$rel"
  done)"
  if [ -n "$EXTRA_LIST" ]; then
    echo 'extras:'
    printf '%s\n' "$EXTRA_LIST"
    EXTRAS=1
  else
    echo 'extras: none'
  fi
  if command -v corepack >/dev/null 2>&1; then
    printf_kv 'corepack' present
  else
    printf_kv 'corepack' 'not-in-path (not an extra)'
  fi
  if [ "$EXTRAS" -eq 1 ]; then
    status_of 'npm-global' fail 'extras-present'
    while IFS= read -r extra; do
      [ -n "$extra" ] || continue
      mark_safe "npm uninstall -g ${extra} — not-done"
    done <<EOF
$EXTRA_LIST
EOF
  else
    status_of 'npm-global' pass 'no-extras'
  fi
else
  echo 'fail npm-not-found'
  status_of 'npm-global' fail 'npm-not-found'
fi

echo
echo '--- Java ---'
if command -v javac >/dev/null 2>&1; then
  printf_kv 'javac' "$(command -v javac)"
  status_of 'javac' fail 'present'
else
  printf_kv 'javac' none
  status_of 'javac' pass 'absent'
fi
JRE_PKGS="$(dpkg-query -W -f='${Package} ${db:Status-Status}\n' 'openjdk-*-jre*' 'openjdk-*-jre-headless*' 'openjdk-*-jdk*' 2>/dev/null | grep -v 'not-installed' | grep -v '^$' || true)"
if [ -n "$JRE_PKGS" ]; then
  echo 'jre-as-distro-dependency:'
  printf '%s\n' "$JRE_PKGS"
else
  echo 'jre: none'
fi

echo
echo '--- which -a agent CLIs ---'
classify_agent() {
  cmd="$1"
  echo "## cmd=${cmd}"
  paths="$(which -a "$cmd" 2>/dev/null)"
  if [ -z "$paths" ]; then
    echo 'which: not-in-path'
  else
    printf '%s\n' "$paths" | while IFS= read -r p; do
      res="$(readlink -f "$p" 2>/dev/null || printf '%s' "$p")"
      kind='unknown'
      case "$res" in
        */.nvm/*|*/node_modules/*|*/npm/*) kind='npm' ;;
        */.local/share/claude/*|*/.opencode/bin/*|*/.grok/*|*/.codex/*) kind='official' ;;
        */.local/bin/*)
          tgt="$(readlink -f "$p" 2>/dev/null || true)"
          case "$tgt" in
            */.local/share/claude/*|*/.opencode/bin/*|*/.grok/*|*/.codex/*) kind='official' ;;
            */.nvm/*) kind='npm' ;;
            *) kind='official-or-local' ;;
          esac
          ;;
        *) kind='unknown' ;;
      esac
      printf 'which %s -> %s kind=%s\n' "$p" "$res" "$kind"
    done
  fi
}

classify_agent claude
if [ -e "${HOME_DIR}/.local/share/claude" ]; then
  echo "disk ${HOME_DIR}/.local/share/claude kind=official"
fi

classify_agent opencode
if [ -e "${HOME_DIR}/.opencode/bin/opencode" ]; then
  echo "disk ${HOME_DIR}/.opencode/bin/opencode kind=official"
elif [ -e "${HOME_DIR}/.opencode/bin/opencode2" ]; then
  echo "disk ${HOME_DIR}/.opencode/bin/opencode2 kind=official"
fi

classify_agent grok
if [ -e "${HOME_DIR}/.grok/bin/grok" ]; then
  echo "disk ${HOME_DIR}/.grok/bin/grok kind=official"
fi

classify_agent codex
if [ -e "${HOME_DIR}/.local/bin/codex" ]; then
  echo "disk $(readlink -f "${HOME_DIR}/.local/bin/codex") kind=official"
fi

classify_agent pi
echo 'pi official-entry=npm (INSTALL_POLICY)'

echo
echo '======== 步3 卫生 ========'

echo '--- product point dirs (top-level only copied skills/; skip ~/.agents) ---'
POINT_COUNT=0
POINT_NAMES=()
python3 - "$HOME_DIR" <<'PY'
import os, sys
home = sys.argv[1]
count = 0
try:
    entries = sorted(os.listdir(home))
except OSError as e:
    print(f"fail home-list {e}")
    raise SystemExit
for name in entries:
    if not name.startswith(".") or name in {".", "..", ".agents"}:
        continue
    path = os.path.join(home, name)
    if os.path.islink(path) or not os.path.isdir(path):
        continue
    try:
        kids = [k for k in os.listdir(path) if k not in {".", ".."}]
    except OSError as e:
        print(f"fail {path}: {e}")
        continue
    if kids != ["skills"]:
        continue
    skills = os.path.join(path, "skills")
    if os.path.islink(skills):
        print(f"skip-symlink-skills {path}")
        continue
    if not os.path.isdir(skills):
        continue
    print(f"point-dir {path}")
    count += 1
print(f"point-dir-count={count}")
PY
POINT_COUNT="$(python3 - "$HOME_DIR" <<'PY'
import os, sys
home = sys.argv[1]
count = 0
for name in os.listdir(home):
    if not name.startswith(".") or name in {".", "..", ".agents"}:
        continue
    path = os.path.join(home, name)
    if os.path.islink(path) or not os.path.isdir(path):
        continue
    try:
        kids = [k for k in os.listdir(path) if k not in {".", ".."}]
    except OSError:
        continue
    if kids != ["skills"]:
        continue
    skills = os.path.join(path, "skills")
    if os.path.islink(skills) or not os.path.isdir(skills):
        continue
    count += 1
print(count)
PY
)"
POINT_COUNT="$(printf '%s' "$POINT_COUNT" | tr -d '[:space:]')"
if [ "${POINT_COUNT:-0}" != "0" ]; then
  mark_safe "remove copy-type product point dirs (count=${POINT_COUNT}) — not-done"
fi

echo
echo '--- broken / Windows-Docker-Desktop links ---'
python3 - <<'PY'
import os
dirs = ["/usr/local/bin", "/usr/local/lib/docker/cli-plugins"]
needles = (
    "/Program Files/Docker",
    "/Program Files/Microsoft VS Code",
    "/Docker/host",
    "docker-desktop",
    "/mnt/wsl/docker-desktop",
    "/AppData/Local/Programs/Microsoft VS Code",
)
found = []
for d in dirs:
    if not os.path.isdir(d):
        print(f"dir {d} exists=no")
        continue
    print(f"dir {d} exists=yes")
    try:
        names = os.listdir(d)
    except OSError as e:
        print(f"fail list {d}: {e}")
        continue
    for name in sorted(names):
        path = os.path.join(d, name)
        if not os.path.islink(path):
            continue
        try:
            target = os.readlink(path)
        except OSError as e:
            print(f"fail readlink {path}: {e}")
            continue
        dangling = not os.path.exists(path)
        win = any(n.lower() in target.replace("\\", "/").lower() for n in needles) or any(
            n.lower() in path.replace("\\", "/").lower() for n in ("/Docker/host",)
        )
        if dangling or win:
            kind = "dangling" if dangling else "windows-or-docker-desktop"
            print(f"broken {path} -> {target} kind={kind}")
            found.append(path)
print(f"broken-link-count={len(found)}")
PY
BROKEN_COUNT="$(python3 - <<'PY'
import os
dirs = ["/usr/local/bin", "/usr/local/lib/docker/cli-plugins"]
needles = (
    "/Program Files/Docker",
    "/Program Files/Microsoft VS Code",
    "/Docker/host",
    "docker-desktop",
    "/mnt/wsl/docker-desktop",
    "/AppData/Local/Programs/Microsoft VS Code",
)
n = 0
for d in dirs:
    if not os.path.isdir(d):
        continue
    for name in os.listdir(d):
        path = os.path.join(d, name)
        if not os.path.islink(path):
            continue
        try:
            target = os.readlink(path)
        except OSError:
            n += 1
            continue
        dangling = not os.path.exists(path)
        win = any(x.lower() in target.replace("\\", "/").lower() for x in needles)
        if dangling or win:
            n += 1
print(n)
PY
)"
BROKEN_COUNT="$(printf '%s' "$BROKEN_COUNT" | tr -d '[:space:]')"
if [ "${BROKEN_COUNT:-0}" != "0" ]; then
  mark_safe "remove broken Windows/Docker Desktop links (count=${BROKEN_COUNT}) — not-done"
fi

echo
echo '--- ~/.env.secrets mode and named keys (no values) ---'
if [ -e "$SECRETS" ] || [ -L "$SECRETS" ]; then
  MODE="$(stat -c '%a' "$SECRETS" 2>/dev/null || echo unreadable)"
  printf_kv 'path' "$SECRETS"
  printf_kv 'mode' "$MODE"
  if [ "$MODE" = "600" ]; then
    status_of 'env.secrets-mode' pass '600'
  else
    status_of 'env.secrets-mode' fail "mode=${MODE}"
    mark_safe 'chmod 600 ~/.env.secrets — not-done'
  fi
  python3 - "$SECRETS" <<'PY'
import os, re, sys
path = sys.argv[1]
wanted = ("EXA_API_KEY", "CONTEXT7_API_KEY")
names = set()
try:
    with open(path, "r", encoding="utf-8", errors="replace") as fh:
        for line in fh:
            m = re.match(r"^(?:export\s+)?([A-Za-z_][A-Za-z0-9_]*)=", line)
            if m:
                names.add(m.group(1))
except OSError as e:
    print(f"fail read-secrets-names {e}")
    raise SystemExit
for key in wanted:
    print(f"{key}={'present' if key in names else 'absent'}")
PY
else
  printf_kv 'path' "$SECRETS"
  printf_kv 'exists' no
  status_of 'env.secrets-mode' fail 'missing'
fi

echo
echo '--- farm symlinks into source root (leftover; do not delete) ---'
if [ -f "$LEFTOVER" ]; then
  echo "tool=${LEFTOVER} --check"
  if [ -x "$LEFTOVER" ] || [ -f "$LEFTOVER" ]; then
    "$LEFTOVER" --check
  else
    echo 'fail leftover-tool-not-runnable'
  fi
else
  echo "fail leftover-tool-missing ${LEFTOVER}"
fi

echo
echo '======== 步4 两档修复（只列不修） ========'
echo 'would-fix-safe:'
if [ "${#SAFE_FIXES[@]}" -eq 0 ]; then
  echo '  (none)'
else
  for item in "${SAFE_FIXES[@]}"; do
    printf '  - %s\n' "$item"
  done
fi
echo 'would-fix-gate:'
if [ "${#GATE_FIXES[@]}" -eq 0 ]; then
  echo '  (none)'
else
  for item in "${GATE_FIXES[@]}"; do
    printf '  - %s\n' "$item"
  done
fi
echo 'executed: none'
echo 'all-listed-fixes: not-done'

echo
echo '======== done ========'
exit 0
