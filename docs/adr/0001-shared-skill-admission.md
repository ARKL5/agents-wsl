# 共享 skill 准入：可移植且对侧会用

两侧工作树用共享名单决定哪些 skill 从 WSL 收到 Windows。进名单必须同时满足可移植和对侧会用。点名只是把一次决定写进名单的手续，不是分类标准。

**Code**: `shared-skills.txt`

**Status**: accepted

## Considered Options

- **点名即共享**：谁点名谁进名单。拒绝：名单不再能解释「为什么这 10 个在、同可移植的 `tdd` 不在」。
- **可移植即共享**：正文两边都能跑就进。拒绝：Windows 技能表会被 WSL 工作流撑满；对侧不会调的指针仍占表。
- **可移植 ∧ 对侧会用**（采纳）：可移植是过滤器，对侧会用是闸。

## Consequences

- 不可移植的 skill 留在本侧：`use-local-wsl`、`configure-harness`；Windows 的 `use-local-windows`、`update-software`、`mpv`、`qbittorrent`。
- 无对侧安装的 skill 不进名单（当前：`herdr`）。
- 厂商内置 skill 不走这份名单，走各家 harness 配置。
- `cli-proxy-api` 正文指向 Windows 脚本仍算可移植：两侧都能按正文做完。
