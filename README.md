# tmux-cyberpunk

Cyberpunk 2077 inspired `tmux` theme plugin for `tmux 3.2+`, installable via
[TPM](https://github.com/tmux-plugins/tpm).

Default palette:
`#000000`, `#c5003c`, `#880425`, `#f3e600`, `#55ead4`

## Install (TPM)

Add to `~/.tmux.conf`:

```tmux
set -g @plugin '<your-github-username>/tmux-cyberpunk'
run '~/.tmux/plugins/tpm/tpm'
```

Inside tmux:

1. `prefix + I`
2. `tmux source-file ~/.tmux.conf`

## Quick Config

```tmux
# core
set -g @cyberpunk-icon-pack 'cyber-fa'
set -g @cyberpunk-show-icons 'on'
set -g @cyberpunk-nerd-fonts 'on'
set -g @cyberpunk-separator-style 'ghost'

# window focus profile: simple | bold | ultra
set -g @cyberpunk-window-profile 'simple'

# common toggles
set -g @cyberpunk-show-git 'on'
set -g @cyberpunk-git-show-updown 'on'
set -g @cyberpunk-show-network 'on'
set -g @cyberpunk-show-battery 'on'
set -g @cyberpunk-show-host 'off'
```

Apply without restarting tmux:

```bash
tmux source-file ~/.tmux.conf
tmux run-shell ~/.tmux/plugins/tmux-cyberpunk/cyberpunk.tmux
```

## Window Profiles

Runtime switch:

```bash
tmux set -g @cyberpunk-window-profile bold
tmux run-shell ~/.tmux/plugins/tmux-cyberpunk/cyberpunk.tmux
```

Profiles:

- `simple`: `window-style bg=#070b12,fg=#738399`, `window-active-style bg=#0d1422,fg=#d7e3ef`
- `bold`: `window-style bg=#06090f,fg=#67788f`, `window-active-style bg=#111b2e,fg=#eef6ff`
- `ultra`: `window-style bg=#05060a,fg=#665a78`, `window-active-style bg=#0a1020,fg=#55ead4`

Optional manual overrides (higher priority than profile):

```tmux
set -g @cyberpunk-window-style 'bg=#101010,fg=#8f8f8f'
set -g @cyberpunk-window-active-style 'bg=#181818,fg=#f0f0f0'
```

## Key Options

All options use `@cyberpunk-*`.

- `@cyberpunk-icon-pack`: `cyber-fa` (default), `emoji`, `nerd`, `ascii`, `none`
- `@cyberpunk-show-git`: show branch segment based on active pane path
- `@cyberpunk-git-show-dirty`: append `*` for modified working tree
- `@cyberpunk-git-show-updown`: append `↑N`/`↓N` when diverged from upstream
- `@cyberpunk-network-host`: ping host for `NET` segment (default `1.1.1.1`)
- `@cyberpunk-network-timeout-ms`: network probe timeout (default `250`)
- `@cyberpunk-color-*`: palette overrides (`bg`, `primary`, `secondary`, `accent`, `cyan`, `warning`)

## Troubleshooting

- Plugin does not load: ensure `run '~/.tmux/plugins/tpm/tpm'` is last in `~/.tmux.conf`, then run `prefix + I`.
- Icons render as squares: use Nerd Font for `cyber-fa`, or switch to `@cyberpunk-icon-pack 'ascii'`.
- Theme not refreshed: run `tmux source-file ~/.tmux.conf` and `tmux run-shell ~/.tmux/plugins/tmux-cyberpunk/cyberpunk.tmux`.

## Development

```bash
shellcheck -x cyberpunk.tmux scripts/*.sh
tests/git_info_test.sh
tests/git_segment_test.sh
tests/status_git_format_test.sh
tests/system_info_test.sh
tests/cyberhud_pro_format_test.sh
tests/icons_test.sh
tests/window_profile_test.sh
```
