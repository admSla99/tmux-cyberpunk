#!/usr/bin/env bash

apply_theme() {
  tmux set-option -gq status on
  tmux set-option -gq status-justify left
  tmux set-option -gq status-style "bg=$CYBERPUNK_COLOR_BG,fg=$CYBERPUNK_COLOR_ACCENT"

  tmux set-option -gq message-style "bg=$CYBERPUNK_COLOR_SECONDARY,fg=$CYBERPUNK_COLOR_ACCENT"
  tmux set-option -gq message-command-style "bg=$CYBERPUNK_COLOR_PRIMARY,fg=$CYBERPUNK_COLOR_ACCENT"
  tmux set-option -gq mode-style "bg=$CYBERPUNK_COLOR_ACCENT,fg=$CYBERPUNK_COLOR_BG"

  tmux set-option -gq pane-border-style "fg=$CYBERPUNK_COLOR_SECONDARY"
  tmux set-option -gq pane-active-border-style "fg=$CYBERPUNK_COLOR_CYAN"

  tmux set-window-option -gq window-status-separator ""
  tmux set-window-option -gq window-status-format "#[fg=$CYBERPUNK_COLOR_ACCENT,bg=$CYBERPUNK_COLOR_BG] #{window_index}:#{window_name} "
  tmux set-window-option -gq window-status-current-format "#[fg=$CYBERPUNK_COLOR_BG,bg=$CYBERPUNK_COLOR_ACCENT,bold] #{window_index}:#{window_name} "
}
