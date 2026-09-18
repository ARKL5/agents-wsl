#!/usr/bin/env bash
# Reapply the local pi-web-access SSRF adaptation after a package update.
# Existing web-search.json keys are preserved; only ssrf.allowRanges is merged.
set -euo pipefail

# Match pi-web-access getWebSearchConfigDir: PI_CODING_AGENT_DIR, else
# XDG (existing XDG file, else existing ~/.pi/web-search.json, else XDG),
# else ~/.pi/agent.
if [ -n "${PI_CODING_AGENT_DIR:-}" ]; then
  CONFIG_DIR="$PI_CODING_AGENT_DIR"
elif [ -n "${XDG_CONFIG_HOME:-}" ]; then
  xdg_dir="${XDG_CONFIG_HOME}/pi"
  if [ -f "${xdg_dir}/web-search.json" ]; then
    CONFIG_DIR="$xdg_dir"
  elif [ -f "${HOME}/.pi/web-search.json" ]; then
    CONFIG_DIR="${HOME}/.pi"
  else
    CONFIG_DIR="$xdg_dir"
  fi
else
  CONFIG_DIR="${HOME}/.pi/agent"
fi
CONFIG="${CONFIG_DIR}/web-search.json"
LEGACY="${HOME}/.pi/web-search.json"
ASSET="$(cd "$(dirname "$0")" && pwd)/web-search.json"

mkdir -p "$CONFIG_DIR"
if [ ! -f "$CONFIG" ] && [ -f "$LEGACY" ] && [ "$CONFIG" != "$LEGACY" ]; then
  cp -a "$LEGACY" "$CONFIG"
fi

node --input-type=module - "$CONFIG" "$ASSET" <<'NODE'
import { readFileSync, writeFileSync, renameSync } from "node:fs";
import { dirname } from "node:path";

const [configPath, assetPath] = process.argv.slice(2);
const asset = JSON.parse(readFileSync(assetPath, "utf8"));
let config = {};
try {
  config = JSON.parse(readFileSync(configPath, "utf8"));
} catch (error) {
  if (error.code !== "ENOENT") throw error;
}

const currentRanges = Array.isArray(config?.ssrf?.allowRanges)
  ? config.ssrf.allowRanges
  : [];
const requiredRanges = asset?.ssrf?.allowRanges ?? [];
const mergedRanges = [...new Set([...currentRanges, ...requiredRanges])];
const next = {
  ...config,
  ssrf: {
    ...(config.ssrf && typeof config.ssrf === "object" && !Array.isArray(config.ssrf) ? config.ssrf : {}),
    allowRanges: mergedRanges,
  },
};

const tempPath = `${configPath}.tmp-${process.pid}`;
writeFileSync(tempPath, `${JSON.stringify(next, null, 2)}\n`, { mode: 0o600 });
renameSync(tempPath, configPath);
console.log(`reapplied pi-web-access adaptation -> ${configPath}`);
NODE
