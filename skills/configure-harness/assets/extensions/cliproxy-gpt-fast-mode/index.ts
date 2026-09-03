/**
 * cliproxy-gpt-fast-mode
 *
 * Per-model "priority / fast" injection for official GPT models reached via
 * local CLIProxyAPI (provider name: cliproxy).
 *
 * Defaults live in BUILTIN_DEFAULTS (convention, not a live model ledger).
 *
 * When ON for the active model:
 *   - service_tier = "priority"
 *   - text.verbosity = "low"
 *
 * Stock npm:@ryan_nookpi/pi-extension-codex-fast-mode only targets
 * openai-codex + a single global boolean; this local extension is the
 * cliproxy + per-model replacement.
 *
 * Commands:
 *   /cliproxy-fast status
 *   /cliproxy-fast on [modelId]
 *   /cliproxy-fast off [modelId]
 *   /cliproxy-fast reset [modelId|all]
 *
 * State: ~/.pi/agent/state/cliproxy-gpt-fast-mode.json
 */
import { mkdirSync, readFileSync, writeFileSync } from "node:fs";
import { dirname, join } from "node:path";
import { homedir } from "node:os";
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

const STATE_FILE = join(homedir(), ".pi", "agent", "state", "cliproxy-gpt-fast-mode.json");

/** Models this extension may inject fast/priority for. */
export const MANAGED_MODEL_IDS = [
  "gpt-5.6-terra",
  "gpt-5.6-sol",
] as const;

export type ManagedModelId = (typeof MANAGED_MODEL_IDS)[number];

/** Built-in defaults — source of truth for "reset". */
export const BUILTIN_DEFAULTS: Record<ManagedModelId, boolean> = {
  "gpt-5.6-terra": true,
  "gpt-5.6-sol": false,
};

type FastModeState = {
  /** Last-known effective flags (defaults merged with user overrides). */
  models: Record<string, boolean>;
};

function isRecord(value: unknown): value is Record<string, unknown> {
  return typeof value === "object" && value !== null && !Array.isArray(value);
}

function isManagedModelId(id: string): id is ManagedModelId {
  return (MANAGED_MODEL_IDS as readonly string[]).includes(id);
}

export function defaultState(): FastModeState {
  return {
    models: { ...BUILTIN_DEFAULTS },
  };
}

export function loadState(): FastModeState {
  const base = defaultState();
  try {
    const raw = readFileSync(STATE_FILE, "utf8");
    const parsed = JSON.parse(raw) as unknown;
    if (!isRecord(parsed) || !isRecord(parsed.models)) return base;
    const models: Record<string, boolean> = { ...base.models };
    for (const [key, value] of Object.entries(parsed.models)) {
      if (typeof value === "boolean" && isManagedModelId(key)) {
        models[key] = value;
      }
    }
    return { models };
  } catch {
    return base;
  }
}

function saveState(state: FastModeState): void {
  mkdirSync(dirname(STATE_FILE), { recursive: true });
  writeFileSync(STATE_FILE, `${JSON.stringify(state, null, 2)}\n`, "utf8");
}

export function isFastEnabledForModel(modelId: string | undefined, state?: FastModeState): boolean {
  if (!modelId || !isManagedModelId(modelId)) return false;
  const s = state ?? loadState();
  return s.models[modelId] === true;
}

function isCliproxyGptResponsesModel(model: {
  provider?: unknown;
  id?: unknown;
  api?: unknown;
}): boolean {
  if (model.provider !== "cliproxy") return false;
  if (typeof model.id !== "string" || !isManagedModelId(model.id)) return false;
  // Prefer openai-responses; still allow missing api if id is managed gpt-5.6.
  if (model.api !== undefined && model.api !== "openai-responses") return false;
  return true;
}

function formatStatus(state: FastModeState): string {
  const lines = MANAGED_MODEL_IDS.map((id) => {
    const on = state.models[id] === true;
    const def = BUILTIN_DEFAULTS[id] ? "on" : "off";
    return `  ${id}: ${on ? "ON" : "OFF"} (default ${def})`;
  });
  return `cliproxy GPT fast mode (service_tier=priority + text.verbosity=low when ON):\n${lines.join("\n")}\nState: ${STATE_FILE}`;
}

function parseHandlerArgs(args: string): {
  action: "on" | "off" | "status" | "reset" | "help";
  modelToken?: string;
} {
  const parts = args.trim().split(/\s+/).filter(Boolean);
  if (parts.length === 0) return { action: "status" };
  const head = parts[0]!.toLowerCase();
  if (head === "help" || head === "-h" || head === "--help") return { action: "help" };
  if (head === "status") return { action: "status" };
  if (head === "on" || head === "off" || head === "reset") {
    return { action: head, modelToken: parts[1]?.toLowerCase() };
  }
  // Allow "/cliproxy-fast gpt-5.6-sol on" style? Keep simple: action first.
  return { action: "help" };
}

function normalizeModelToken(token: string | undefined, currentId: string | undefined): string | "all" | undefined {
  if (!token) return currentId;
  if (token === "all") return "all";
  // accept short aliases
  const aliases: Record<string, ManagedModelId> = {
    terra: "gpt-5.6-terra",
    sol: "gpt-5.6-sol",
    "gpt-5.6-terra": "gpt-5.6-terra",
    "gpt-5.6-sol": "gpt-5.6-sol",
  };
  return aliases[token];
}

export default function cliproxyGptFastMode(pi: ExtensionAPI) {
  // Seed state file on first load so defaults are visible on disk.
  const initial = loadState();
  try {
    readFileSync(STATE_FILE, "utf8");
  } catch {
    saveState(initial);
  }

  pi.on("before_provider_request", (event, ctx) => {
    const model = ctx.model as { provider?: unknown; id?: unknown; api?: unknown } | undefined;
    if (!model || !isCliproxyGptResponsesModel(model)) return undefined;
    if (!isFastEnabledForModel(typeof model.id === "string" ? model.id : undefined)) {
      return undefined;
    }
    if (!isRecord(event.payload)) return undefined;

    const payload = { ...event.payload };
    const prevText = isRecord(payload.text) ? payload.text : {};
    payload.text = {
      ...prevText,
      verbosity: "low",
    };
    payload.service_tier = "priority";
    return payload;
  });

  pi.registerCommand("cliproxy-fast", {
    description:
      "Per-model fast mode for cliproxy GPT (terra default ON, sol OFF). Usage: /cliproxy-fast [on|off|status|reset] [model|all]",
    getArgumentCompletions: (prefix) => {
      const options = [
        "status",
        "on",
        "off",
        "reset",
        "on terra",
        "on sol",
        "off terra",
        "off sol",
        "reset all",
        "reset terra",
        "reset sol",
      ];
      const p = prefix.trim().toLowerCase();
      const filtered = options.filter((o) => o.startsWith(p));
      return filtered.length > 0 ? filtered.map((o) => ({ value: o, label: o })) : null;
    },
    handler: async (args, ctx) => {
      const parsed = parseHandlerArgs(args);
      const currentId = typeof ctx.model?.id === "string" ? ctx.model.id : undefined;

      const notify = (message: string, level: "info" | "warning" | "error" = "info") => {
        if (ctx.hasUI) ctx.ui.notify(message, level);
      };

      if (parsed.action === "help") {
        notify(
          "Usage: /cliproxy-fast [status|on|off|reset] [terra|sol|gpt-5.6-*|all]\n" +
            "Defaults: terra ON, sol OFF. Only affects provider=cliproxy managed GPT models.",
        );
        return;
      }

      if (parsed.action === "status") {
        notify(formatStatus(loadState()));
        return;
      }

      const state = loadState();
      const target = normalizeModelToken(parsed.modelToken, currentId);

      if (parsed.action === "reset") {
        if (target === "all" || parsed.modelToken === "all") {
          saveState(defaultState());
          notify(`Reset all managed models to defaults.\n${formatStatus(defaultState())}`);
          return;
        }
        if (!target || !isManagedModelId(target)) {
          notify(
            `reset needs a managed model (terra|sol) or all; current model is ${currentId ?? "unknown"}`,
            "warning",
          );
          return;
        }
        state.models[target] = BUILTIN_DEFAULTS[target];
        saveState(state);
        notify(`${target}: reset to default ${BUILTIN_DEFAULTS[target] ? "ON" : "OFF"}`);
        return;
      }

      // on / off
      if (!target || target === "all" || !isManagedModelId(target)) {
        notify(
          `${parsed.action} needs a managed model id (terra|sol or gpt-5.6-*). Current: ${currentId ?? "unknown"}`,
          "warning",
        );
        return;
      }
      state.models[target] = parsed.action === "on";
      saveState(state);
      notify(
        `${target}: fast mode ${parsed.action === "on" ? "ON" : "OFF"} (service_tier=priority + text.verbosity=low when ON)`,
      );
    },
  });
}
