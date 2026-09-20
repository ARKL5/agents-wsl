# Shared read-only helpers for WSL live queries. Source from query.sh.
# Do not print credentials, proxy userinfo, or process environments.

# shellcheck shell=bash

HOME_DIR="${HOME:-/home/ark}"
WSLCONFIG="${WSLCONFIG:-/mnt/c/Users/38993/.wslconfig}"
PROXY_ENV="${HOME_DIR}/.config/proxy-env.sh"
WSL_ENV="${HOME_DIR}/.config/wsl-env.sh"
MISE_BIN="${HOME_DIR}/.local/bin/mise"
MISE_SHIMS="${HOME_DIR}/.local/share/mise/shims"
MISE_CFG="${HOME_DIR}/.config/mise/config.toml"
UV_BIN="${HOME_DIR}/.local/bin/uv"
UV_TOML="${HOME_DIR}/.config/uv/uv.toml"
NVM_DIR="${NVM_DIR:-${HOME_DIR}/.nvm}"
PS="${PS:-/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe}"
WSL_EXE="${WSL_EXE:-/mnt/c/Windows/System32/wsl.exe}"

# INSTALL_POLICY global-npm allowlist
NPM_ALLOW='@earendil-works/pi-coding-agent @jackwener/opencli pi opencli'
NPM_KEEP='npm corepack'

wsl_printf_kv() {
  printf '%s=%s\n' "$1" "$2"
}

wsl_status() {
  # wsl_status NAME ok|missing|fail|unverified DETAIL
  printf 'status=%s name=%s detail=%s\n' "$2" "$1" "$3"
}

wsl_summarize_proxy() {
  python3 - "$1" <<'PY'
import sys, re
s = sys.argv[1] if len(sys.argv) > 1 else ""
if not s:
    print("absent")
    raise SystemExit
m = re.match(r"^([a-zA-Z][a-zA-Z0-9+.-]*)://(?:([^/@]+)@)?([^/:]+)(?::(\d+))?", s)
if m:
    userinfo = "present" if m.group(2) else "absent"
    port = m.group(4) or "none"
    print(f"scheme={m.group(1)} host={m.group(3)} port={port} userinfo={userinfo}")
else:
    print("set userinfo=unknown")
PY
}

wsl_is_loopback_no_proxy() {
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

wsl_manager_of() {
  python3 - "$1" "${2:-}" <<'PY'
import os, sys
path = sys.argv[1] if len(sys.argv) > 1 else ""
real = sys.argv[2] if len(sys.argv) > 2 and sys.argv[2] else path
if not path:
    print("missing")
    raise SystemExit
try:
    real = os.path.realpath(real or path)
except OSError:
    pass
candidates = [path.replace("\\", "/"), real.replace("\\", "/")]
rules = (
    ("/mise/shims/", "mise"),
    ("/.local/share/mise/", "mise"),
    ("/.local/bin/mise", "mise"),
    ("/.nvm/", "nvm"),
    ("/.local/share/uv/", "uv"),
    ("/.local/bin/uv", "uv"),
    ("/.local/share/claude/", "official"),
    ("/.opencode/", "official"),
    ("/.grok/", "official"),
    ("/.codex/", "official"),
    ("/usr/bin/", "apt"),
    ("/usr/local/bin/", "usr-local"),
    ("/home/", "user"),
)
for candidate in candidates:
    for needle, name in rules:
        if needle in candidate:
            print(name)
            raise SystemExit
print("unknown")
PY
}

wsl_cmd_record() {
  # wsl_cmd_record FIELD_PREFIX command
  local prefix="$1"
  local cmd="$2"
  local path version manager
  path="$(command -v "$cmd" 2>/dev/null || true)"
  if [ -z "$path" ]; then
    wsl_printf_kv "${prefix}_path" missing
    wsl_printf_kv "${prefix}_version" missing
    wsl_printf_kv "${prefix}_manager" missing
    wsl_status "$cmd" missing "not-in-path"
    return 1
  fi
  local real
  real="$(readlink -f "$path" 2>/dev/null || printf '%s' "$path")"
  manager="$(wsl_manager_of "$path" "$real")"
  version="$("$path" --version 2>/dev/null | head -n1 | tr -d '\r')"
  if [ -z "$version" ]; then
    version="$("$path" -v 2>/dev/null | head -n1 | tr -d '\r')"
  fi
  if [ -z "$version" ]; then
    version="unverified"
  fi
  wsl_printf_kv "${prefix}_path" "$path"
  wsl_printf_kv "${prefix}_real" "$real"
  wsl_printf_kv "${prefix}_version" "$version"
  wsl_printf_kv "${prefix}_manager" "$manager"
  if [ "$version" = "unverified" ]; then
    wsl_status "$cmd" unverified "version-query-failed"
    return 0
  fi
  wsl_status "$cmd" ok "$manager"
  return 0
}

wsl_file_loads() {
  local file="$1"
  local needle="$2"
  local label="$3"
  if [ ! -r "$file" ]; then
    wsl_printf_kv "$label" "missing-file"
    return 1
  fi
  if grep -Eq "$needle" "$file" 2>/dev/null; then
    wsl_printf_kv "$label" yes
    return 0
  fi
  wsl_printf_kv "$label" no
  return 1
}

wsl_topic_shell() {
  echo 'topic=shell'
  wsl_printf_kv 'home' "$HOME_DIR"
  wsl_printf_kv 'wsl_env' "$WSL_ENV"
  if [ -r "$WSL_ENV" ]; then
    wsl_printf_kv 'wsl_env_exists' yes
  else
    wsl_printf_kv 'wsl_env_exists' no
    wsl_status 'wsl-env' missing "missing ${WSL_ENV}"
  fi
  wsl_file_loads "${HOME_DIR}/.bashrc" 'wsl-env.sh' 'bashrc_loads_wsl_env'
  wsl_file_loads "${HOME_DIR}/.profile" 'bashrc|wsl-env.sh' 'profile_loads_env'
  wsl_file_loads "${HOME_DIR}/.bashrc" 'nvm.sh' 'bashrc_loads_nvm'
  wsl_file_loads "${HOME_DIR}/.profile" 'proxy-env.sh' 'profile_direct_proxy'
  wsl_file_loads "${HOME_DIR}/.bashrc" 'proxy-env.sh' 'bashrc_direct_proxy'
  wsl_file_loads "$WSL_ENV" 'proxy-env.sh' 'wsl_env_loads_proxy'
  wsl_file_loads "$WSL_ENV" 'pi-env.sh' 'wsl_env_loads_pi'
  wsl_file_loads "$WSL_ENV" 'mise' 'wsl_env_mentions_mise'
  wsl_cmd_record shell_mise mise || true
  if [ -d "${HOME_DIR}/.local/share/mise/shims" ]; then
    wsl_printf_kv 'mise_shims' yes
  else
    wsl_printf_kv 'mise_shims' no
  fi
  wsl_printf_kv 'path_has_mise_shims' "$(case ":$PATH:" in *":$MISE_SHIMS:"*) echo yes ;; *) echo no ;; esac)"
  wsl_printf_kv 'path_has_nvm' "$(case ":$PATH:" in *":$NVM_DIR/"*) echo yes ;; *) echo no ;; esac)"
  wsl_printf_kv 'path_has_local_bin' "$(case ":$PATH:" in *":${HOME_DIR}/.local/bin:"*) echo yes ;; *) echo no ;; esac)"
  wsl_printf_kv 'SSH_AUTH_SOCK_set' "$([ -n "${SSH_AUTH_SOCK:-}" ] && echo yes || echo no)"
  wsl_printf_kv 'BROWSER_set' "$([ -n "${BROWSER:-}" ] && echo yes || echo no)"
  wsl_printf_kv 'OPENCLI_PROFILE_set' "$([ -n "${OPENCLI_PROFILE:-}" ] && echo yes || echo no)"
  if [ -n "${OPENCLI_PROFILE:-}" ]; then
    wsl_printf_kv 'OPENCLI_PROFILE' "$OPENCLI_PROFILE"
  fi
  if [ -n "${BROWSER:-}" ]; then
    wsl_printf_kv 'BROWSER' "$BROWSER"
  fi
}

wsl_topic_python() {
  echo 'topic=python'
  wsl_cmd_record uv uv || true
  wsl_cmd_record uvx uvx || true
  if [ -r "$UV_TOML" ]; then
    wsl_printf_kv 'uv_toml' "$UV_TOML"
    if grep -qE '^python-downloads[[:space:]]*=' "$UV_TOML"; then
      wsl_printf_kv 'python_downloads' "$(grep -E '^python-downloads[[:space:]]*=' "$UV_TOML" | tail -n1 | sed -E 's/.*=[[:space:]]*//; s/["'\'']//g')"
    else
      wsl_printf_kv 'python_downloads' unset-in-toml
    fi
  else
    wsl_printf_kv 'uv_toml' missing
    wsl_printf_kv 'python_downloads' missing
  fi
  echo '## uv-python-installed'
  if command -v uv >/dev/null 2>&1; then
    if uv python list --only-installed 2>/dev/null | sed 's/^/installed /'; then
      :
    else
      wsl_status 'uv-python-list' fail 'uv-python-list-failed'
    fi
    echo '## uv-tools'
    if uv tool list 2>/dev/null; then
      wsl_status 'uv-tools' ok listed
    else
      wsl_status 'uv-tools' fail 'uv-tool-list-failed'
    fi
  fi
  echo '## system-python'
  wsl_cmd_record system_python3 python3 || true
  if [ -x "$MISE_BIN" ]; then
    if "$MISE_BIN" ls python >/dev/null 2>&1 && [ -n "$("$MISE_BIN" ls python 2>/dev/null)" ]; then
      wsl_status 'mise-python' fail 'mise-manages-python'
    else
      wsl_status 'mise-python' ok 'not-managed'
    fi
  else
    wsl_status 'mise-python' missing 'mise-not-installed'
  fi
}

wsl_topic_node() {
  echo 'topic=node'
  wsl_cmd_record node node || true
  wsl_cmd_record npm npm || true
  wsl_cmd_record pnpm pnpm || true
  wsl_cmd_record corepack corepack || true
  if command -v corepack >/dev/null 2>&1; then
    # "enabled" means shims like yarn/pnpm were installed by corepack enable
    wsl_printf_kv 'corepack_present' yes
    wsl_printf_kv 'corepack_enable' 'do-not-enable (mise selects pnpm from packageManager)'
  fi
  if [ -x "$MISE_BIN" ]; then
    wsl_printf_kv 'mise' "$MISE_BIN"
    wsl_printf_kv 'mise_auto_install' "$("$MISE_BIN" settings get auto_install 2>/dev/null || echo fail)"
    wsl_printf_kv 'mise_idiomatic' "$("$MISE_BIN" settings get idiomatic_version_file_enable_tools 2>/dev/null || echo fail)"
    wsl_printf_kv 'mise_disable_tools' "$("$MISE_BIN" settings get disable_tools 2>/dev/null || echo fail)"
    echo '## mise-tools'
    "$MISE_BIN" ls 2>/dev/null || wsl_status 'mise-ls' fail 'mise-ls-failed'
  else
    wsl_status 'mise' missing 'mise-binary-missing'
  fi
  echo '## nvm-residue'
  if [ -d "$NVM_DIR" ]; then
    wsl_printf_kv 'nvm_dir' "$NVM_DIR"
    wsl_printf_kv 'nvm_dir_exists' yes
    wsl_status 'nvm-residue' unverified 'dir-present-not-deleted'
  else
    wsl_printf_kv 'nvm_dir_exists' no
    wsl_status 'nvm-residue' ok 'absent'
  fi
  echo '## npm-global'
  if command -v npm >/dev/null 2>&1; then
    wsl_printf_kv 'npm_prefix' "$(npm prefix -g 2>/dev/null || echo fail)"
    npm -g ls --depth=0 2>/dev/null || wsl_status 'npm-global-ls' fail 'npm-g-ls-failed'
    PARSE="$(npm -g ls --depth=0 --parseable 2>/dev/null || true)"
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
      echo 'npm_extras:'
      printf '%s\n' "$EXTRA_LIST"
      wsl_status 'npm-global' fail 'extras-present'
    else
      wsl_printf_kv 'npm_extras' none
      wsl_status 'npm-global' ok 'allowlist-only'
    fi
  else
    wsl_status 'npm-global' missing 'npm-not-in-path'
  fi
}

wsl_topic_tools() {
  echo 'topic=tools'
  local cmd
  for cmd in grok claude opencode codex agy herdr pi opencli uv mise docker direnv bun; do
    wsl_cmd_record "$cmd" "$cmd" || true
  done
  echo '## usr-local-bin'
  local name
  for name in uv codex wsl-chrome windows-chrome; do
    local p="/usr/local/bin/$name"
    if [ -e "$p" ] || [ -L "$p" ]; then
      wsl_printf_kv "usr_local_${name}" "$p -> $(readlink -f "$p" 2>/dev/null || echo broken)"
    else
      wsl_printf_kv "usr_local_${name}" absent
    fi
  done
  echo '## bun-home'
  if [ -d "${HOME_DIR}/.bun" ]; then
    if [ -x "${HOME_DIR}/.bun/bin/bun" ]; then
      wsl_printf_kv 'bun_home_binary' yes
    else
      wsl_printf_kv 'bun_home_binary' no
      wsl_status 'bun' unverified 'cache-or-home-without-binary'
    fi
  else
    wsl_printf_kv 'bun_home' absent
  fi
  echo '## java'
  if command -v javac >/dev/null 2>&1; then
    wsl_printf_kv 'javac' "$(command -v javac)"
    wsl_status 'javac' unverified 'present (project-scoped JDK is allowed)'
  else
    wsl_printf_kv 'javac' none
    wsl_status 'javac' ok 'not-on-path'
  fi
  JRE_PKGS="$(dpkg-query -W -f='${Package} ${db:Status-Status}\n' 'openjdk-*-jre*' 'openjdk-*-jre-headless*' 'openjdk-*-jdk*' 2>/dev/null | grep -v 'not-installed' | grep -v '^$' || true)"
  if [ -n "$JRE_PKGS" ]; then
    echo 'jre-packages:'
    printf '%s\n' "$JRE_PKGS"
  else
    wsl_printf_kv 'jre_packages' none
  fi
  echo '## direnv-hook'
  if grep -q direnv "${HOME_DIR}/.bashrc" "${HOME_DIR}/.profile" "$WSL_ENV" 2>/dev/null; then
    wsl_printf_kv 'direnv_shell_hook' yes
  else
    wsl_printf_kv 'direnv_shell_hook' no
  fi
}

wsl_topic_network() {
  echo 'topic=network'
  wsl_printf_kv 'proxy_env' "$PROXY_ENV"
  if [ -r "$PROXY_ENV" ]; then
    wsl_printf_kv 'proxy_env_exists' yes
    # shellcheck disable=SC1090
    . "$PROXY_ENV"
    url="${http_proxy:-${HTTP_PROXY:-${all_proxy:-${ALL_PROXY:-}}}}"
    echo -n 'proxy '; wsl_summarize_proxy "$url"
    NO_PROXY_VAL="${no_proxy:-${NO_PROXY:-none}}"
    wsl_printf_kv 'no_proxy' "$NO_PROXY_VAL"
    if wsl_is_loopback_no_proxy "$NO_PROXY_VAL"; then
      wsl_status 'no_proxy' ok only-loopback
    else
      wsl_status 'no_proxy' fail not-only-loopback
    fi
    if grep -qE '^(export[[:space:]]+)?NODE_USE_ENV_PROXY=' "$PROXY_ENV"; then
      wsl_printf_kv 'NODE_USE_ENV_PROXY' present
    else
      wsl_printf_kv 'NODE_USE_ENV_PROXY' absent
    fi
  else
    wsl_printf_kv 'proxy_env_exists' no
    wsl_status 'proxy-env' missing "missing ${PROXY_ENV}"
    url=""
  fi
  wsl_file_loads "${HOME_DIR}/.bashrc" 'proxy-env.sh' 'bashrc_mentions_proxy'
  wsl_file_loads "${HOME_DIR}/.profile" 'proxy-env.sh' 'profile_mentions_proxy'
  wsl_file_loads "$WSL_ENV" 'proxy-env.sh' 'wsl_env_mentions_proxy'

  echo '## layer=APT'
  APT_FILE='/etc/apt/apt.conf.d/80proxy'
  if [ -r "$APT_FILE" ]; then
    wsl_printf_kv 'apt_proxy_file' "$APT_FILE"
    if grep -q 'Acquire::http::Proxy' "$APT_FILE" && grep -q 'Acquire::https::Proxy' "$APT_FILE"; then
      wsl_status 'APT' unverified 'proxy-keys-present; request-not-verified'
    else
      wsl_status 'APT' fail '80proxy-missing-keys'
    fi
  else
    wsl_status 'APT' missing 'no-80proxy'
  fi

  echo '## layer=Git-HTTP'
  if git config --global --get http.proxy >/dev/null 2>&1 || git config --global --get https.proxy >/dev/null 2>&1; then
    wsl_status 'Git-HTTP' unverified 'git-config-proxy; request-not-verified'
  else
    wsl_status 'Git-HTTP' unverified 'inherit-shell; request-not-verified'
  fi

  echo '## layer=GitHub-SSH'
  SSH_CFG="${HOME_DIR}/.ssh/config"
  if [ -r "$SSH_CFG" ]; then
    if ssh -G github.com 2>/dev/null | grep -Eiq '^proxycommand .*\bnc\b.*[[:space:]]-x[[:space:]]'; then
      wsl_status 'GitHub-SSH' unverified 'effective-proxycommand-nc; request-not-verified'
    else
      wsl_status 'GitHub-SSH' fail 'no-proxycommand'
    fi
  else
    wsl_status 'GitHub-SSH' missing 'missing-ssh-config'
  fi

  echo '## layer=Docker-daemon'
  DOCK_FILE='/etc/systemd/system/docker.service.d/http-proxy.conf'
  if [ -r "$DOCK_FILE" ]; then
    dock_ok=1
    for k in HTTP_PROXY HTTPS_PROXY NO_PROXY; do
      if grep -q "$k=" "$DOCK_FILE"; then
        wsl_printf_kv "dockerd_$k" present
      else
        wsl_printf_kv "dockerd_$k" absent
        dock_ok=0
      fi
    done
    if [ "$dock_ok" -eq 1 ]; then
      wsl_status 'Docker-daemon' unverified 'drop-in-present; active-environment-not-verified'
    else
      wsl_status 'Docker-daemon' fail 'drop-in-incomplete'
    fi
  else
    wsl_status 'Docker-daemon' missing 'missing-drop-in'
  fi

  port="$(wsl_summarize_proxy "${url:-}" | sed -n 's/.*port=\([^ ]*\).*/\1/p')"
  if [ -n "$port" ] && [ "$port" != "none" ] && [ "$port" != "absent" ]; then
    echo "## listen port=${port}"
    if [ -x "$PS" ]; then
      if "$PS" -NoLogo -NoProfile -Command \
        "if (Get-NetTCPConnection -LocalPort $port -State Listen -ErrorAction SilentlyContinue) { 'listen=yes' } else { 'listen=no' }"; then
        wsl_status 'proxy-listen' unverified 'windows-listen-queried'
      else
        wsl_status 'proxy-listen' fail 'powershell-query-failed'
      fi
    else
      wsl_status 'proxy-listen' missing 'powershell-missing'
    fi
  fi
}

wsl_topic_docker() {
  echo 'topic=docker'
  wsl_cmd_record docker docker || true
  if command -v docker >/dev/null 2>&1; then
    if docker version --format 'client={{.Client.Version}} server={{.Server.Version}}' 2>/dev/null; then
      wsl_status 'docker-version' ok queried
    else
      wsl_status 'docker-version' fail 'docker-version-failed'
    fi
  fi
  wsl_printf_kv 'socket' 'unix:///var/run/docker.sock'
  if [ -S /var/run/docker.sock ]; then
    wsl_printf_kv 'socket_exists' yes
  else
    wsl_printf_kv 'socket_exists' no
    wsl_status 'docker-socket' missing 'no-sock'
  fi
  if id -nG 2>/dev/null | tr ' ' '\n' | grep -qx docker; then
    wsl_printf_kv 'user_in_docker' yes
  else
    wsl_printf_kv 'user_in_docker' no
  fi
  wsl_printf_kv 'docker_active' "$(systemctl is-active docker 2>/dev/null || echo fail)"
  wsl_printf_kv 'engine' 'native-docker-engine'
}

wsl_topic_browser() {
  echo 'topic=browser'
  wsl_cmd_record wslview wslview || true
  wsl_cmd_record wsl_chrome wsl-chrome || true
  wsl_printf_kv 'wsl_chrome_path' /usr/local/bin/wsl-chrome
  if [ -x /usr/local/bin/wsl-chrome ]; then
    if grep -q 'proxy-env.sh' /usr/local/bin/wsl-chrome; then
      wsl_printf_kv 'wsl_chrome_sources_proxy' yes
    else
      wsl_printf_kv 'wsl_chrome_sources_proxy' no
    fi
  fi
  wsl_printf_kv 'BROWSER' "${BROWSER:-unset}"
  wsl_printf_kv 'OPENCLI_PROFILE' "${OPENCLI_PROFILE:-unset}"
  if command -v xdg-settings >/dev/null 2>&1; then
    wsl_printf_kv 'default_web_browser' "$(env -u BROWSER xdg-settings get default-web-browser 2>/dev/null || echo fail)"
  fi
  if command -v xdg-mime >/dev/null 2>&1; then
    wsl_printf_kv 'http_handler' "$(xdg-mime query default x-scheme-handler/http 2>/dev/null || echo fail)"
  fi
  if [ -r /proc/sys/fs/binfmt_misc/WSLInterop ]; then
    wsl_printf_kv 'WSLInterop' "$(grep enabled /proc/sys/fs/binfmt_misc/WSLInterop 2>/dev/null || echo unread)"
  fi
  echo '## opencli'
  if command -v opencli >/dev/null 2>&1; then
    wsl_cmd_record opencli opencli || true
    if out="$(opencli doctor 2>/dev/null)"; then
      printf '%s\n' "$out" | grep -E '\[(OK|WARN|FAIL|ERR)' || printf '%s\n' "$out" | head -n 20
      wsl_status 'opencli-doctor' unverified 'ran (no credentials printed by filter)'
    else
      wsl_status 'opencli-doctor' fail 'doctor-failed'
    fi
  else
    wsl_status 'opencli' missing 'not-in-path'
  fi
}

wsl_topic_wsl() {
  echo 'topic=wsl'
  if [ -r /etc/os-release ]; then
    # shellcheck disable=SC1091
    . /etc/os-release
    wsl_printf_kv 'os' "${ID:-unknown} ${VERSION_ID:-unknown}"
  fi
  wsl_printf_kv 'kernel' "$(uname -srm 2>/dev/null || echo fail)"
  wsl_printf_kv 'pid1' "$(ps -p 1 -o comm= 2>/dev/null || echo fail)"
  wsl_printf_kv 'systemd' "$(systemctl is-system-running 2>/dev/null || echo fail)"
  wsl_printf_kv 'distro' "${WSL_DISTRO_NAME:-unknown}"
  if command -v wslinfo >/dev/null 2>&1; then
    wsl_printf_kv 'networkingMode_live' "$(wslinfo --networking-mode 2>/dev/null || echo fail)"
  fi
  echo '## wsl.conf'
  if [ -r /etc/wsl.conf ]; then
    grep -E '^[A-Za-z[]' /etc/wsl.conf | sed 's/^/wsl.conf /'
  else
    wsl_status 'wsl.conf' missing 'absent'
  fi
  echo '## .wslconfig'
  wsl_printf_kv 'wslconfig_path' "$WSLCONFIG"
  if [ -r "$WSLCONFIG" ]; then
    grep -E '^[A-Za-z][A-Za-z0-9]*=' "$WSLCONFIG" | sed 's/^/wslconfig /'
    wsl_status '.wslconfig' ok readable
  else
    wsl_status '.wslconfig' missing 'unreadable'
  fi
  echo '## interop'
  wsl_printf_kv 'windows_path_on_PATH' "$(case ":$PATH:" in *:/mnt/c/Windows*) echo yes ;; *) echo no ;; esac)"
}

wsl_topic_summary() {
  echo 'topic=summary'
  echo '## shell'; wsl_topic_shell
  echo
  echo '## python'; wsl_topic_python
  echo
  echo '## node'; wsl_topic_node
  echo
  echo '## tools'; wsl_topic_tools
  echo
  echo '## network'; wsl_topic_network
  echo
  echo '## docker'; wsl_topic_docker
  echo
  echo '## browser'; wsl_topic_browser
  echo
  echo '## wsl'; wsl_topic_wsl
}

