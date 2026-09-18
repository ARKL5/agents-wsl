# Windows 按 wsl/main 当前树检出共享集合

共享集合以 WSL 当前树为准，不重放历史 `shared(...)` 提交。Windows 从 `wsl/main` 检出名单、协议文件和名单里每个 skill；先 `git rm` 再 checkout，清掉工作区里 ACL 损坏、Git 覆盖不了的文件。

**Code**: `tools/sync.py`

**Status**: accepted

## Considered Options

- **cherry-pick `shared(...)` 队列**（拒绝）：新 hash 进不了祖先，旧补丁永远留在 `main..wsl/main`，上下文一变就整队停住。
- **按名单 overlay `wsl/main`**（采纳）：名单是成员，WSL 树是内容。旧提交不再参与。
