# Local Browser Routing

## Boundary

| Workload | Browser state |
| --- | --- |
| Interactive WSL shell / mime / CLI auth in Linux Chrome | Signed-in WSL Google Chrome profile `ARK` |
| Browser automation | A tool-owned isolated profile |

Automation uses a tool-owned profile, not WSL `ARK`.

## WSL Chrome (shell / mime)

Interactive launcher: `/usr/local/bin/wsl-chrome` (sources `~/.config/proxy-env.sh`, maps proxy env to Chrome flags, runs `/usr/bin/google-chrome-stable`). Prefer it over calling the Chrome binary when a human or Linux-side tool wants WSL Chrome.

| Item | Local value |
| --- | --- |
| Shell browser | `BROWSER=/usr/local/bin/wsl-chrome` in `~/.config/wsl-env.sh` |
| Desktop entry | `~/.local/share/applications/wsl-google-chrome.desktop` |
| HTTP, HTTPS, HTML mime default | `wsl-google-chrome.desktop` |
| Chrome profile | `~/.config/google-chrome/Default`, name `ARK` |
| Sync | Enabled; extension sync disabled |
| Package updates | Google APT source `/etc/apt/sources.list.d/google-chrome.sources` |

`$BROWSER` and xdg mime stay WSL Chrome for interactive shell/desktop. 点名 Windows Chrome 时用 `/usr/local/bin/windows-chrome`，本地文件先 `wslpath -w`。

Done when interactive mime still points at `wsl-google-chrome.desktop` when that layer is in scope; WSL Chrome launcher still carries proxy flags; automation stays off `ARK`.
