# tmux-cyberpunk

A `tmux` theme plugin inspired by Cyberpunk 2077 aesthetics, built for
`tmux 3.2+` and installable with [TPM](https://github.com/tmux-plugins/tpm).

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
| `@cyberpunk-nerd-fonts` | `off` | Enable powerline separators (Nerd Fonts). |
| `@cyberpunk-separator-left` | `` | Left-side separator when Nerd Fonts are enabled. |
| `@cyberpunk-separator-right` | `` | Right-side separator when Nerd Fonts are enabled. |
| `@cyberpunk-show-session` | `on` | Show session block in status-left. |
| `@cyberpunk-show-git` | `on` | Show Git segment in status-right (uses active pane path). |
| `@cyberpunk-git-show-dirty` | `on` | Append `*` when working tree has changes. |
| `@cyberpunk-git-prefix` | `git:` | Prefix rendered before branch name. |
| `@cyberpunk-show-host` | `on` | Show host block in status-right. |
| `@cyberpunk-show-time` | `on` | Show time block in status-right. |
| `@cyberpunk-color-bg` | `#000000` | Base background color. |
| `@cyberpunk-color-primary` | `#c5003c` | Primary segment background color. |
| `@cyberpunk-color-secondary` | `#880425` | Secondary segment background color. |
| `@cyberpunk-color-accent` | `#f3e600` | Accent text color. |
| `@cyberpunk-color-cyan` | `#55ead4` | Highlight color for active visuals/time segment. |

### Example override

```tmux
set -g @cyberpunk-nerd-fonts 'on'
set -g @cyberpunk-show-git 'on'
set -g @cyberpunk-git-prefix 'branch:'
set -g @cyberpunk-show-host 'off'
set -g @cyberpunk-color-accent '#ffe600'
```

## Development

Run static checks locally:

```bash
shellcheck cyberpunk.tmux scripts/*.sh
tests/git_info_test.sh
tests/status_git_format_test.sh
```

## Troubleshooting

- Plugin does not load:
  - Verify `run '~/.tmux/plugins/tpm/tpm'` is the last line in `tmux.conf`.
  - Run `prefix + I` to reinstall/update plugin links.
- Theme not refreshed:
  - Run `tmux source-file ~/.tmux.conf`.
- Broken separators:
  - Set `@cyberpunk-nerd-fonts` to `off` if your terminal font is not Nerd Font compatible.
