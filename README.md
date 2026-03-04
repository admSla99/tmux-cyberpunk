# tmux-cyberpunk

A `tmux` theme plugin inspired by Cyberpunk 2077 aesthetics, built for
`tmux 3.2+` and installable with [TPM](https://github.com/tmux-plugins/tpm).

CyberHUD Pro defaults include:

- mode awareness (`PREFIX` / `COPY` / `SYNC` / `LIVE`)
- Git segment with branch, dirty marker, and upstream divergence arrows
- system telemetry segments (`NET`, `CPU`, `MEM`, `BAT`)
- neon pane and window indicators for better focus/alerts

Default palette:

- `#000000`
- `#c5003c`
- `#880425`
- `#f3e600`
- `#55ead4`

## Installation (TPM)

Add this to your `~/.tmux.conf`:

```tmux
set -g @plugin '<your-github-username>/tmux-cyberpunk'

# Keep this line at the bottom
run '~/.tmux/plugins/tpm/tpm'
```

Install and reload inside tmux:

1. Press `prefix + I` (capital i) to install plugins.
2. Reload config with:
   ```bash
   tmux source-file ~/.tmux.conf
   ```

## Configuration

All options are global tmux options and use the `@cyberpunk-*` namespace.

| Option | Default | Description |
| --- | --- | --- |
| `@cyberpunk-padding` | `1` | Non-negative integer padding spaces inside each status segment (`0`, `1`, `2`, ...). Invalid values fallback to `1`. |
| `@cyberpunk-interval` | `5` | Positive integer `status-interval` in seconds (`1`, `2`, ...). Invalid values fallback to `5`. |
| `@cyberpunk-show-icons` | `on` | Show decorative icons before segment labels/values. |
| `@cyberpunk-icon-pack` | `cyber-fa` | Icon set: `emoji`, `nerd`, `cyber-fa`, `ascii`, or `none`. |
| `@cyberpunk-nerd-fonts` | `off` | Enable powerline separators (Nerd Fonts). |
| `@cyberpunk-separator-left` | `` | Left-side separator when Nerd Fonts are enabled. |
| `@cyberpunk-separator-right` | `` | Right-side separator when Nerd Fonts are enabled. |
| `@cyberpunk-separator-style` | `ghost` | Separator rendering style: `ghost` (no filled boxes) or `legacy` (filled boxes). |
| `@cyberpunk-show-session` | `on` | Show session block in status-left. |
| `@cyberpunk-show-mode` | `on` | Show mode block (`PREFIX`/`COPY`/`SYNC`/`LIVE`) in status-left. |
| `@cyberpunk-show-git` | `on` | Show Git segment in status-right (uses active pane path). |
| `@cyberpunk-git-show-dirty` | `on` | Append `*` when working tree has changes. |
| `@cyberpunk-git-show-updown` | `on` | Append `↑N` / `↓N` when branch diverges from upstream. |
| `@cyberpunk-git-prefix` | `git:` | Prefix rendered before branch name. |
| `@cyberpunk-show-network` | `on` | Show network latency segment. |
| `@cyberpunk-network-host` | `1.1.1.1` | Host used for `NET` latency probe. |
| `@cyberpunk-network-timeout-ms` | `250` | Network probe timeout in milliseconds. |
| `@cyberpunk-show-cpu` | `on` | Show CPU load segment. |
| `@cyberpunk-show-memory` | `on` | Show memory usage segment. |
| `@cyberpunk-show-battery` | `on` | Show battery/AC segment. |
| `@cyberpunk-show-host` | `on` | Show host block in status-right. |
| `@cyberpunk-show-time` | `on` | Show time block in status-right. |
| `@cyberpunk-window-profile` | `simple` | Window focus profile for pane backgrounds: `simple`, `bold`, or `ultra`. |
| `@cyberpunk-window-style` | _(unset)_ | Optional direct override for `window-style` (for example `bg=#070b12,fg=#738399`). |
| `@cyberpunk-window-active-style` | _(unset)_ | Optional direct override for `window-active-style` (for example `bg=#0d1422,fg=#d7e3ef`). |
| `@cyberpunk-color-bg` | `#000000` | Base background color. |
| `@cyberpunk-color-primary` | `#c5003c` | Primary segment background color. |
| `@cyberpunk-color-secondary` | `#880425` | Secondary segment background color. |
| `@cyberpunk-color-accent` | `#f3e600` | Accent text color. |
| `@cyberpunk-color-cyan` | `#55ead4` | Highlight color for active visuals/time segment. |
| `@cyberpunk-color-warning` | `#f3e600` | Warning/attention color (used by battery segment in CyberHUD Pro). |

### Example override

```tmux
set -g @cyberpunk-nerd-fonts 'on'
set -g @cyberpunk-separator-style 'ghost'
set -g @cyberpunk-show-icons 'on'
set -g @cyberpunk-icon-pack 'cyber-fa'
set -g @cyberpunk-show-git 'on'
set -g @cyberpunk-git-show-updown 'on'
set -g @cyberpunk-git-prefix 'branch:'
set -g @cyberpunk-show-network 'off'
set -g @cyberpunk-show-battery 'off'
set -g @cyberpunk-show-host 'off'
set -g @cyberpunk-window-profile 'bold'
set -g @cyberpunk-color-accent '#ffe600'
set -g @cyberpunk-color-warning '#f3e600'
```

### Window Focus Profiles

Switch profiles at runtime:

```bash
tmux set -g @cyberpunk-window-profile simple
tmux run-shell ~/.tmux/plugins/tmux-cyberpunk/cyberpunk.tmux
```

Available profiles:

- `simple`
  - `window-style`: `bg=#070b12,fg=#738399`
  - `window-active-style`: `bg=#0d1422,fg=#d7e3ef`
- `bold`
  - `window-style`: `bg=#06090f,fg=#67788f`
  - `window-active-style`: `bg=#111b2e,fg=#eef6ff`
- `ultra`
  - `window-style`: `bg=#05060a,fg=#665a78`
  - `window-active-style`: `bg=#0a1020,fg=#55ead4`

Manual overrides (higher priority than profile):

```tmux
set -g @cyberpunk-window-style 'bg=#101010,fg=#8f8f8f'
set -g @cyberpunk-window-active-style 'bg=#181818,fg=#f0f0f0'
```

## Development

Run static checks locally:

```bash
shellcheck cyberpunk.tmux scripts/*.sh
tests/git_info_test.sh
tests/git_segment_test.sh
tests/status_git_format_test.sh
tests/system_info_test.sh
tests/cyberhud_pro_format_test.sh
tests/icons_test.sh
tests/window_profile_test.sh
```

## Troubleshooting

- Plugin does not load:
  - Verify `run '~/.tmux/plugins/tpm/tpm'` is the last line in `tmux.conf`.
  - Run `prefix + I` to reinstall/update plugin links.
- Theme not refreshed:
  - Run `tmux source-file ~/.tmux.conf`.
- Broken separators:
  - Set `@cyberpunk-nerd-fonts` to `off` if your terminal font is not Nerd Font compatible.
- Broken icons (squares/tofu):
  - `cyber-fa` requires a Nerd Font in your terminal profile.
  - If you do not use Nerd Font, switch to `@cyberpunk-icon-pack 'ascii'` or `none`.
