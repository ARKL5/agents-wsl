#!/usr/bin/env bash
# Tests for query.sh: syntax, happy path, missing, fail, redaction, read-only.
set -euo pipefail

_src="${BASH_SOURCE[0]}"
case "$_src" in
  /*) ;;
  *) _src="$PWD/$_src" ;;
esac
SCRIPT_DIR="${_src%/*}"
unset _src
QUERY="${SCRIPT_DIR}/query.sh"
LIB="${SCRIPT_DIR}/query-lib.sh"
FAILS=0

pass() { printf 'PASS %s\n' "$1"; }
fail() { printf 'FAIL %s\n' "$1"; FAILS=$((FAILS + 1)); }

echo '== syntax =='
for f in "$QUERY" "$LIB" "$0"; do
  if bash -n "$f"; then
    pass "bash -n $(basename "$f")"
  else
    fail "bash -n $(basename "$f")"
  fi
done

echo '== unknown topic =='
rc=0
out="$("$QUERY" not-a-topic 2>&1)" || rc=$?
if [ "$rc" -eq 2 ] && printf '%s' "$out" | grep -q 'unknown topic'; then
  pass 'unknown-topic exit 2'
else
  fail "unknown-topic rc=$rc out=$(printf '%s' "$out" | head -c 120)"
fi

echo '== help =='
if "$QUERY" --help | grep -q 'usage:'; then
  pass 'help'
else
  fail 'help'
fi

echo '== live topics emit topic= =='
for t in shell python node tools network docker browser wsl; do
  if out="$("$QUERY" "$t")"; printf '%s' "$out" | grep -q "^topic=$t"; then
    pass "topic $t"
  else
    fail "topic $t missing header"
  fi
done

echo '== redaction: proxy userinfo =='
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
mkdir -p "$TMP/.config" "$TMP/.local/bin"
cat > "$TMP/.config/proxy-env.sh" <<'EOF'
export http_proxy='http://user:s3cret-value@127.0.0.1:7890'
export https_proxy='http://user:s3cret-value@127.0.0.1:7890'
export HTTP_PROXY="$http_proxy"
export HTTPS_PROXY="$https_proxy"
export no_proxy='localhost,127.0.0.1,::1'
export NO_PROXY="$no_proxy"
export NODE_USE_ENV_PROXY=1
EOF
chmod 600 "$TMP/.config/proxy-env.sh"
redact_out="$(HOME="$TMP" bash "$QUERY" network 2>/dev/null || true)"
if printf '%s' "$redact_out" | grep -Eq 's3cret-value|user:s3cret'; then
  fail 'redaction leaked credential'
else
  pass 'redaction no credential'
fi
if printf '%s' "$redact_out" | grep -q 'userinfo=present' && printf '%s' "$redact_out" | grep -q 'port=7890'; then
  pass 'redaction keeps host/port'
else
  fail "redaction missing summary: $(printf '%s' "$redact_out" | head -c 200)"
fi

echo '== secrets hygiene =='
sec_dir="$(mktemp -d)"
sec_out="$(HOME="$sec_dir" /usr/bin/bash "$QUERY" shell 2>/dev/null || true)"
if printf '%s' "$sec_out" | grep -q 'env_secrets=absent' && printf '%s' "$sec_out" | grep -q 'secrets_dir=absent'; then
  pass 'secrets absent on empty home'
else
  fail "secrets absent: $(printf '%s' "$sec_out" | grep -E 'env_secrets|secrets_dir' | tr '\n' ' ')"
fi
printf 'export UNITTEST_TOKEN=s3cret-query-test\n' > "$sec_dir/.env.secrets"
chmod 644 "$sec_dir/.env.secrets"
mode_out="$(HOME="$sec_dir" /usr/bin/bash "$QUERY" shell 2>/dev/null || true)"
if printf '%s' "$mode_out" | grep -q 'status=fail name=env-secrets-mode'; then
  pass 'env-secrets mode 644 fails'
else
  fail 'env-secrets mode 644 not fail'
fi
if printf '%s' "$mode_out" | grep -q 's3cret-query-test'; then
  fail 'env-secrets value leaked'
else
  pass 'env-secrets value redacted'
fi
chmod 600 "$sec_dir/.env.secrets"
mode_ok="$(HOME="$sec_dir" /usr/bin/bash "$QUERY" shell 2>/dev/null || true)"
if printf '%s' "$mode_ok" | grep -q 'status=ok name=env-secrets-mode'; then
  pass 'env-secrets mode 600 ok'
else
  fail 'env-secrets mode 600 not ok'
fi
mkdir "$sec_dir/.secrets"
dual_out="$(HOME="$sec_dir" /usr/bin/bash "$QUERY" shell 2>/dev/null || true)"
if printf '%s' "$dual_out" | grep -q 'status=fail name=secrets-dir'; then
  pass 'secrets-dir dual store fails'
else
  fail 'secrets-dir dual store not fail'
fi
rm -rf "$sec_dir"

echo '== missing commands =='
# Keep coreutils on PATH; drop user/local bins so uv is missing. bun is not installed.
miss_out="$(env PATH="/usr/bin:/bin" HOME="$TMP" /usr/bin/bash "$QUERY" tools 2>/dev/null || true)"
if printf '%s' "$miss_out" | grep -q 'status=missing name=uv'; then
  pass 'missing uv'
else
  fail 'missing uv not reported'
fi
if printf '%s' "$miss_out" | grep -q 'status=missing name=bun'; then
  pass 'missing bun'
else
  fail 'missing bun not reported'
fi

echo '== query failure: docker stub =='
mkdir -p "$TMP/bin"
cat > "$TMP/bin/docker" <<'EOF'
#!/bin/sh
echo 'docker: cannot talk to daemon' >&2
exit 1
EOF
chmod +x "$TMP/bin/docker"
fail_out="$(env PATH="$TMP/bin:/usr/bin:/bin" HOME="$TMP" /usr/bin/bash "$QUERY" docker 2>/dev/null || true)"
if printf '%s' "$fail_out" | grep -q 'status=fail name=docker-version'; then
  pass 'docker version fail'
else
  fail "docker fail branch: $(printf '%s' "$fail_out" | head -c 240)"
fi

echo '== wsl processors keys =='
wsl_out="$("$QUERY" wsl 2>/dev/null || true)"
if printf '%s' "$wsl_out" | grep -q '^nproc=' \
  && printf '%s' "$wsl_out" | grep -q '^host_logical_processors=' \
  && printf '%s' "$wsl_out" | grep -q 'name=processors-vs-host'; then
  pass 'processors live keys'
else
  fail "processors keys: $(printf '%s' "$wsl_out" | grep -E 'nproc=|host_logical|processors-vs-host' | tr '\n' ' ')"
fi

echo '== read-only: config mtimes =='
cfg="${HOME}/.bashrc"
if [ -f "$cfg" ]; then
  before="$(stat -c '%Y %s' "$cfg")"
  "$QUERY" shell >/dev/null
  after="$(stat -c '%Y %s' "$cfg")"
  if [ "$before" = "$after" ]; then
    pass 'bashrc mtime unchanged'
  else
    fail 'bashrc mtime changed'
  fi
fi
mise_cfg="${HOME}/.config/mise/config.toml"
if [ -f "$mise_cfg" ]; then
  before="$(stat -c '%Y %s' "$mise_cfg")"
  "$QUERY" node >/dev/null
  after="$(stat -c '%Y %s' "$mise_cfg")"
  if [ "$before" = "$after" ]; then
    pass 'mise config mtime unchanged'
  else
    fail 'mise config mtime changed'
  fi
fi
if [ -f "${HOME}/.config/proxy-env.sh" ]; then
  before="$(stat -c '%Y %s' "${HOME}/.config/proxy-env.sh")"
  "$QUERY" network >/dev/null
  after="$(stat -c '%Y %s' "${HOME}/.config/proxy-env.sh")"
  if [ "$before" = "$after" ]; then
    pass 'proxy-env mtime unchanged'
  else
    fail 'proxy-env mtime changed'
  fi
fi

echo '== no full process environ dump =='
sum="$("$QUERY" summary 2>/dev/null || true)"
if printf '%s' "$sum" | grep -Eq '^(export )?PATH=/.+:/.+'; then
  fail 'summary dumped PATH'
else
  pass 'no PATH dump'
fi
if printf '%s' "$sum" | grep -Eqi 'api[_-]?key=|token=[A-Za-z0-9]{8,}'; then
  fail 'summary looks like a secret assignment'
else
  pass 'no secret assignment'
fi

if [ "$FAILS" -ne 0 ]; then
  printf 'FAILED %s tests\n' "$FAILS" >&2
  exit 1
fi
printf 'ok: query tests passed\n'
exit 0
