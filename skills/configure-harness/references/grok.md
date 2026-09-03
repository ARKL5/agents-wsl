# Grok

## 全局指令

- `~/.grok/AGENTS.md`
- `~/.grok/agents/swift.md`
- `~/.grok/agents/deliberate.md`
- 类型副本（与 Grok 同一轮改）：`~/.claude/agents/swift.md`、`~/.claude/agents/deliberate.md`
- 现查：`~/.grok/docs/user-guide/16-subagents.md`、`05-configuration.md`、`grok inspect`；官方字段走 `find-docs`

## 表面

- `~/.grok/config.toml`（权限、sandbox、features、memory、compat、skills、subagents.toggle）
- 现查：同目录 user-guide 里 permissions / features / harness compatibility 各节
- `[models]` 与各 `[model."…"]` 是活偏好，除非用户这轮要改型号，否则原样留下

## 家私

类型名是 `swift` / `deliberate`。spawn 参数名、权限字段名现查，不要沿用记忆。
