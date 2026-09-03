import {
	stripFrontmatter,
	type ExtensionAPI,
	type SlashCommandInfo,
} from "@earendil-works/pi-coding-agent";
import type {
	AutocompleteItem,
	AutocompleteProvider,
} from "@earendil-works/pi-tui";
import { existsSync, readFileSync, statSync } from "node:fs";
import { dirname, join } from "node:path";

type SkillInfo = {
	name: string;
	description: string;
	filePath: string;
	baseDir: string;
};

type SkillReference = {
	name: string;
	escaped: boolean;
};

const SKILL_REFERENCE = /(\\*)\$([a-z][a-z0-9_-]*)/g;

function resolveSkillFile(path: string): string | undefined {
	if (!existsSync(path)) return undefined;

	try {
		const stat = statSync(path);
		if (stat.isFile() && path.endsWith(".md")) return path;
		if (stat.isDirectory()) {
			const skillFile = join(path, "SKILL.md");
			if (existsSync(skillFile)) return skillFile;
		}
	} catch {
		return undefined;
	}

	return undefined;
}

function commandToSkill(command: SlashCommandInfo): SkillInfo | undefined {
	if (command.source !== "skill" || !command.name.startsWith("skill:")) {
		return undefined;
	}

	const name = command.name.slice("skill:".length);
	const filePath = resolveSkillFile(command.sourceInfo.path);
	if (!name || !filePath) return undefined;

	return {
		name,
		description: command.description ?? "",
		filePath,
		baseDir: dirname(filePath),
	};
}

export function buildSkillRegistry(
	commands: SlashCommandInfo[],
): Map<string, SkillInfo> {
	const registry = new Map<string, SkillInfo>();
	for (const command of commands) {
		const skill = commandToSkill(command);
		if (skill && !registry.has(skill.name)) {
			registry.set(skill.name, skill);
		}
	}
	return registry;
}

export function parseSkillReferences(text: string): SkillReference[] {
	const references: SkillReference[] = [];
	for (const match of text.matchAll(SKILL_REFERENCE)) {
		const backslashes = match[1] ?? "";
		references.push({
			name: match[2],
			escaped: backslashes.length % 2 === 1,
		});
	}
	return references;
}

function replaceSkillReferences(
	text: string,
	resolvedNames: ReadonlySet<string>,
): string {
	return text.replace(
		SKILL_REFERENCE,
		(match, backslashes: string, name: string) => {
			if (backslashes.length % 2 === 1) {
				return `${backslashes.slice(0, -1)}$${name}`;
			}
			return resolvedNames.has(name) ? `${backslashes}${name}` : match;
		},
	);
}

function escapeAttribute(value: string): string {
	return value
		.replaceAll("&", "&amp;")
		.replaceAll('"', "&quot;")
		.replaceAll("<", "&lt;")
		.replaceAll(">", "&gt;");
}

export function buildSkillBlock(
	skills: SkillInfo[],
	bodies: ReadonlyMap<string, string>,
): string {
	const names = skills.map((skill) => skill.name).join(", ");
	const sections = skills.map((skill) => {
		const body = bodies.get(skill.name) ?? "";
		return [
			`## ${skill.name}`,
			`Location: ${skill.filePath}`,
			`References are relative to ${skill.baseDir}.`,
			"",
			body,
		].join("\n");
	});

	return [
		`<skill name="${escapeAttribute(names)}" location="multi-skills">`,
		sections.join("\n\n---\n\n"),
		"</skill>",
	].join("\n");
}

function createAutocompleteProvider(
	current: AutocompleteProvider,
	getRegistry: () => Map<string, SkillInfo>,
): AutocompleteProvider {
	return {
		triggerCharacters: ["$"],
		async getSuggestions(lines, cursorLine, cursorCol, options) {
			const line = lines[cursorLine] ?? "";
			const beforeCursor = line.slice(0, cursorCol);
			const match = beforeCursor.match(/(?:^|[^\\])\$([a-z][a-z0-9_-]*)?$/);
			if (!match) {
				return current.getSuggestions(lines, cursorLine, cursorCol, options);
			}

			const query = match[1] ?? "";
			const items: AutocompleteItem[] = [...getRegistry().values()]
				.filter((skill) => skill.name.includes(query))
				.map((skill) => ({
					value: `$${skill.name} `,
					label: `$${skill.name}`,
					description: skill.description,
				}));

			if (options.signal.aborted || items.length === 0) {
				return current.getSuggestions(lines, cursorLine, cursorCol, options);
			}

			return { prefix: `$${query}`, items };
		},
		applyCompletion(lines, cursorLine, cursorCol, item, prefix) {
			return current.applyCompletion(
				lines,
				cursorLine,
				cursorCol,
				item,
				prefix,
			);
		},
		shouldTriggerFileCompletion(lines, cursorLine, cursorCol) {
			return (
				current.shouldTriggerFileCompletion?.(
					lines,
					cursorLine,
					cursorCol,
				) ?? true
			);
		},
	};
}

export default function multiSkills(pi: ExtensionAPI): void {
	const getRegistry = () => buildSkillRegistry(pi.getCommands());

	pi.on("session_start", (_event, ctx) => {
		ctx.ui.addAutocompleteProvider((current) =>
			createAutocompleteProvider(current, getRegistry),
		);
	});

	pi.on("input", (event, ctx) => {
		if (event.source === "extension" || !event.text.includes("$")) {
			return { action: "continue" };
		}

		const references = parseSkillReferences(event.text);
		if (references.length === 0) return { action: "continue" };

		const registry = getRegistry();
		const resolved: SkillInfo[] = [];
		const resolvedNames = new Set<string>();
		const unknownNames = new Set<string>();

		for (const reference of references) {
			if (reference.escaped) continue;
			const skill = registry.get(reference.name);
			if (!skill) {
				unknownNames.add(reference.name);
				continue;
			}
			if (!resolvedNames.has(skill.name)) {
				resolvedNames.add(skill.name);
				resolved.push(skill);
			}
		}

		if (unknownNames.size > 0) {
			ctx.ui.notify(
				`Unknown skill references: ${[...unknownNames]
					.map((name) => `$${name}`)
					.join(", ")}`,
				"warning",
			);
		}

		const userText = replaceSkillReferences(event.text, resolvedNames);
		if (resolved.length === 0) {
			return userText === event.text
				? { action: "continue" }
				: { action: "transform", text: userText };
		}

		const bodies = new Map<string, string>();
		try {
			for (const skill of resolved) {
				const content = readFileSync(skill.filePath, "utf-8");
				bodies.set(skill.name, stripFrontmatter(content).trim());
			}
		} catch (error) {
			const message = error instanceof Error ? error.message : String(error);
			ctx.ui.notify(`Multi-skill loading failed: ${message}`, "error");
			if (ctx.hasUI) ctx.ui.setEditorText(event.text);
			if (!ctx.hasUI) console.error(`Multi-skill loading failed: ${message}`);
			return { action: "handled" };
		}

		return {
			action: "transform",
			text: `${buildSkillBlock(resolved, bodies)}\n\n${userText}`,
		};
	});
}
