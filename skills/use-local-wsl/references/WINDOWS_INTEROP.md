# Local Windows Interop

从 WSL 调 Windows 路径和 `.exe`。身份在 skill 的 Always。Windows agent 进 Linux 的命令见 `use-local-windows` 的 `WSL_INTEROP.md`。

## Filesystems

Ubuntu 根是 ext4。Linux 仓库与高 churn 构建放 `/home/ark`。Windows 用 UNC 读：

```text
\\wsl.localhost\Ubuntu\home\ark
```

Windows 盘在 `/mnt/<letter>`。发现用 `ls /mnt`；翻译用 `wslpath`，不要手拼。

```bash
wslpath -w /home/ark/CODE
wslpath -u 'C:\Users\38993'
```

## Absolute Windows executables

Windows 调 WSL 用户级工具（mise/node/uv/pi）用登录壳（默认 PATH 没有用户 shims）：

```text
wsl.exe -d Ubuntu -e /bin/bash -lc "<command>"
```

`appendWindowsPath=false`，从 WSL 调 Windows 用绝对路径：

```text
/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe
/mnt/c/Windows/System32/cmd.exe
/mnt/c/Windows/explorer.exe
/mnt/c/Windows/System32/wsl.exe
```

PowerShell 接受当前 `\\wsl.localhost\Ubuntu\...` 提供程序路径。`cmd.exe` 拒绝 UNC 当前目录，要先 `cd /d` 到盘符路径：

```bash
/mnt/c/Windows/System32/cmd.exe /d /c \
  "cd /d C:\\Users\\38993 && <command>"
```

资源管理器打开 Linux 路径：

```bash
/mnt/c/Windows/explorer.exe "$(wslpath -w /home/ark/CODE)"
```

Done when every path in this run went through `wslpath` or an absolute `.exe` listed above.
