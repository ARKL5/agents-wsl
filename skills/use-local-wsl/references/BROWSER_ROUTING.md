# Local Browser Routing

## Boundary

| Workload | Browser state |
| --- | --- |
| Agent open of a URL or local file for the user | Windows default app via `wslview` |
| Interactive WSL shell / mime / CLI auth in Linux Chrome | Signed-in WSL Google Chrome profile `ARK` |
| OpenCLI Browser Bridge | Signed-in Windows Chrome（profile **live-check**） |
| Browser automation | A tool-owned isolated profile |

Keep these profiles separate. OpenCLI is the only agent workflow that reuses signed-in Windows Chrome. Automation uses a tool-owned profile, not WSL `ARK`.

## Agent open

```bash
wslview <absolute-linux-path-or-url>
```

- Files: absolute path (`readlink -f`). URLs: pass through.
- After open, report the absolute path or URL to the user.
- If `wslview` is missing or WSL interop is disabled, stop and report — no substitute open command.
- Force Windows Chrome only when the task names it:

```bash
/usr/local/bin/windows-chrome "$(wslpath -w /absolute/path)"
/usr/local/bin/windows-chrome "https://example.com"
```

## WSL Chrome (shell / mime)

Interactive launcher: `/usr/local/bin/wsl-chrome` (sources `~/.config/proxy-env.sh`, maps proxy env to Chrome flags, runs `/usr/bin/google-chrome-stable`). Prefer it over calling the Chrome binary when a human or Linux-side tool wants WSL Chrome.

| Item | Local value |
| --- | --- |
| Shell browser | `BROWSER=/usr/local/bin/wsl-chrome` in `~/.bashrc` |
| Desktop entry | `~/.local/share/applications/wsl-google-chrome.desktop` |
| HTTP, HTTPS, HTML mime default | `wsl-google-chrome.desktop` |
| Chrome profile | `~/.config/google-chrome/Default`, name `ARK` |
| Sync | Enabled; extension sync disabled |
| Package updates | Google APT source `/etc/apt/sources.list.d/google-chrome.sources` |

`$BROWSER` and xdg mime stay WSL Chrome for interactive shell/desktop. Agent open-for-user still uses only `wslview` above.

## OpenCLI

`OPENCLI_PROFILE` 从登录壳现查（`~/.bashrc` 会导出）。以 `opencli profile list` / `opencli doctor` 的已连接配置为准，不把配置名写回本文件。

```bash
bash -lc 'printf "%s\n" "$OPENCLI_PROFILE"'
opencli profile list
opencli doctor
```

扩展连的若和 `$OPENCLI_PROFILE` 不同：`opencli profile use <id>` 并改 bashrc，用新的 login shell 验证。

用户点名站点抓取时走 `fetch-media`。

## Verification

```bash
command -v wslview
grep enabled /proc/sys/fs/binfmt_misc/WSLInterop
env -u BROWSER xdg-settings get default-web-browser
xdg-mime query default x-scheme-handler/http
bash -lc 'printf "%s\n" "$BROWSER" "$OPENCLI_PROFILE"'
```

Done when agent open uses `wslview` only; interactive mime still points at `wsl-google-chrome.desktop` when that layer is in scope; WSL Chrome launcher still carries proxy flags; automation stays off `ARK`; and `opencli doctor` passes when OpenCLI is in scope.
