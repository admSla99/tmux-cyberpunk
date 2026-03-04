#!/usr/bin/env bash

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# shellcheck source=./utils.sh
source "$CURRENT_DIR/utils.sh"
# shellcheck source=./palette.sh
source "$CURRENT_DIR/palette.sh"
# shellcheck source=./theme.sh
source "$CURRENT_DIR/theme.sh"
# shellcheck source=./status.sh
source "$CURRENT_DIR/status.sh"

set_defaults() {
  upsert_option "@cyberpunk-padding" "1"
  upsert_option "@cyberpunk-interval" "5"
  upsert_option "@cyberpunk-show-icons" "on"
  upsert_option "@cyberpunk-icon-pack" "cyber-fa"
  upsert_option "@cyberpunk-nerd-fonts" "off"
  upsert_option "@cyberpunk-separator-left" ""
  upsert_option "@cyberpunk-separator-right" ""
  upsert_option "@cyberpunk-separator-style" "ghost"
  upsert_option "@cyberpunk-show-session" "on"
  upsert_option "@cyberpunk-show-mode" "on"
  upsert_option "@cyberpunk-show-git" "on"
  upsert_option "@cyberpunk-git-show-dirty" "on"
  upsert_option "@cyberpunk-git-show-updown" "on"
  upsert_option "@cyberpunk-git-prefix" "git:"
  upsert_option "@cyberpunk-show-network" "on"
  upsert_option "@cyberpunk-network-host" "1.1.1.1"
  upsert_option "@cyberpunk-network-timeout-ms" "250"
  upsert_option "@cyberpunk-show-cpu" "on"
  upsert_option "@cyberpunk-show-memory" "on"
  upsert_option "@cyberpunk-show-battery" "on"
  upsert_option "@cyberpunk-show-host" "on"
  upsert_option "@cyberpunk-show-time" "on"
  upsert_option "@cyberpunk-window-profile" "simple"

  upsert_option "@cyberpunk-color-bg" "$CYBERPUNK_DEFAULT_BG"
  upsert_option "@cyberpunk-color-primary" "$CYBERPUNK_DEFAULT_PRIMARY"
  upsert_option "@cyberpunk-color-secondary" "$CYBERPUNK_DEFAULT_SECONDARY"
  upsert_option "@cyberpunk-color-accent" "$CYBERPUNK_DEFAULT_ACCENT"
  upsert_option "@cyberpunk-color-cyan" "$CYBERPUNK_DEFAULT_CYAN"
  upsert_option "@cyberpunk-color-warning" "$CYBERPUNK_DEFAULT_WARNING"
}

main() {
  local interval

  set_defaults
  load_palette
  apply_theme
  apply_status

  interval="$(coerce_positive_integer "$(get_option "@cyberpunk-interval" "5")" "5")"
  tmux set-option -gq status-interval "$interval"
}

main
