# .agents

当前操作系统上实际生效的 agent skills 工作树，以及它与另一棵工作树之间的共享边界。

## Language

**本侧工作树**：
当前操作系统上实际被各家 harness 加载的那棵 `~/.agents`。
_Avoid_: 本仓, 本地仓, skill 仓

**对侧**：
另一个操作系统上的那棵工作树。WSL 的对侧是 Windows，反之亦然。
_Avoid_: 对面, 另一边

**两侧**：
WSL 工作树与 Windows 工作树。
_Avoid_: 系统两侧

**共享 skill**：
属于两侧工作树的 skill，写在共享名单里。
_Avoid_: 公共 skill, 全局 skill

**平台专属 skill**：
只属于一棵工作树的 skill，不进共享名单。
_Avoid_: 系统 skill, 本侧 skill, local-only

**厂商内置 skill**：
随 harness 发行、不在任一工作树里维护的 skill。
_Avoid_: 系统 skill, bundled skill

**可移植**：
两侧的 agent 都能按正文做完这件事。
_Avoid_: 跨平台, OS-agnostic, 不含某侧路径

**对侧会用**：
对侧工作树上的 agent 会实际调用这个 skill。
_Avoid_: 有用, 通用, 可移植（可移植不是会用）

**协议文件**：
随共享提交在两侧同步、但不是某个 skill 的文件。
_Avoid_: 元文件, 仓库根文件
