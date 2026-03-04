#!/usr/bin/env bash

normalize_window_profile() {
  case "$(printf '%s' "${1:-}" | tr '[:upper:]' '[:lower:]')" in
    simple | bold | ultra)
      printf '%s\n' "$(printf '%s' "${1:-}" | tr '[:upper:]' '[:lower:]')"
      ;;
    *)
      printf 'simple\n'
      ;;
  esac
}

window_style_for_profile() {
  case "$1" in
    simple)
      printf 'bg=#070b12,fg=#738399\n'
      ;;
    bold)
      printf 'bg=#06090f,fg=#67788f\n'
      ;;
    ultra)
      printf 'bg=#05060a,fg=#665a78\n'
      ;;
    *)
      printf 'bg=#070b12,fg=#738399\n'
      ;;
  esac
}

window_active_style_for_profile() {
  case "$1" in
    simple)
      printf 'bg=#0d1422,fg=#d7e3ef\n'
      ;;
    bold)
      printf 'bg=#111b2e,fg=#eef6ff\n'
      ;;
    ultra)
      printf 'bg=#0a1020,fg=#55ead4\n'
      ;;
    *)
      printf 'bg=#0d1422,fg=#d7e3ef\n'
      ;;
  esac
}

apply_theme() {
  local window_profile window_style window_active_style
  local window_style_override window_active_style_override

  window_profile="$(normalize_window_profile "$(get_option "@cyberpunk-window-profile" "simple")")"
  window_style_override="$(get_option "@cyberpunk-window-style" "")"
  window_active_style_override="$(get_option "@cyberpunk-window-active-style" "")"

  if [ -n "$window_style_override" ]; then
    window_style="$window_style_override"
  else
    window_style="$(window_style_for_profile "$window_profile")"
  fi

  if [ -n "$window_active_style_override" ]; then
    window_active_style="$window_active_style_override"
  else
    window_active_style="$(window_active_style_for_profile "$window_profile")"
  fi

  tmux set-option -gq status on
  tmux set-option -gq status-justify left
  tmux set-option -gq status-style "bg=$CYBERPUNK_COLOR_BG,fg=$CYBERPUNK_COLOR_ACCENT"
  tmux set-option -gq status-left-style "bg=$CYBERPUNK_COLOR_BG,fg=$CYBERPUNK_COLOR_ACCENT"
  tmux set-option -gq status-right-style "bg=$CYBERPUNK_COLOR_BG,fg=$CYBERPUNK_COLOR_ACCENT"

  tmux set-option -gq message-style "bg=$CYBERPUNK_COLOR_SECONDARY,fg=$CYBERPUNK_COLOR_ACCENT"
  tmux set-option -gq message-command-style "bg=$CYBERPUNK_COLOR_PRIMARY,fg=$CYBERPUNK_COLOR_ACCENT"
  tmux set-option -gq mode-style "bg=$CYBERPUNK_COLOR_ACCENT,fg=$CYBERPUNK_COLOR_BG"

  tmux set-option -gq pane-border-style "fg=$CYBERPUNK_COLOR_SECONDARY"
  tmux set-option -gq pane-active-border-style "fg=$CYBERPUNK_COLOR_CYAN"
  tmux set-option -gq pane-border-format "#[fg=$CYBERPUNK_COLOR_SECONDARY] #{?pane_active,▶, } #P "

  tmux set-window-option -gq window-status-separator ""
  tmux set-window-option -gq window-status-format "#[fg=$CYBERPUNK_COLOR_ACCENT,bg=$CYBERPUNK_COLOR_BG] #{?window_activity_flag,⚑ ,}#I:#W "
  tmux set-window-option -gq window-status-current-format "#[fg=$CYBERPUNK_COLOR_BG,bg=$CYBERPUNK_COLOR_ACCENT,bold] ▶ #I:#W "
  tmux set-window-option -gq window-status-activity-style "fg=$CYBERPUNK_COLOR_CYAN,bg=$CYBERPUNK_COLOR_BG,bold"
  tmux set-window-option -gq window-status-bell-style "fg=$CYBERPUNK_COLOR_BG,bg=$CYBERPUNK_COLOR_PRIMARY,bold"
  tmux set-window-option -gq window-style "$window_style"
  tmux set-window-option -gq window-active-style "$window_active_style"
}
