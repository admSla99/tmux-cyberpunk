#!/usr/bin/env bash

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "$CURRENT_DIR/utils.sh"
source "$CURRENT_DIR/palette.sh"
source "$CURRENT_DIR/theme.sh"
source "$CURRENT_DIR/status.sh"

set_defaults() {
  upsert_option "@cyberpunk-padding" "1"
  upsert_option "@cyberpunk-interval" "5"
  upsert_option "@cyberpunk-nerd-fonts" "off"
  upsert_option "@cyberpunk-separator-left" ""
  upsert_option "@cyberpunk-separator-right" ""
  upsert_option "@cyberpunk-show-session" "on"
  upsert_option "@cyberpunk-show-git" "on"
  upsert_option "@cyberpunk-git-show-dirty" "on"
  upsert_option "@cyberpunk-git-prefix" "git:"
  upsert_option "@cyberpunk-show-host" "on"
  upsert_option "@cyberpunk-show-time" "on"

  upsert_option "@cyberpunk-color-bg" "$CYBERPUNK_DEFAULT_BG"
  upsert_option "@cyberpunk-color-primary" "$CYBERPUNK_DEFAULT_PRIMARY"
  upsert_option "@cyberpunk-color-secondary" "$CYBERPUNK_DEFAULT_SECONDARY"
  upsert_option "@cyberpunk-color-accent" "$CYBERPUNK_DEFAULT_ACCENT"
  upsert_option "@cyberpunk-color-cyan" "$CYBERPUNK_DEFAULT_CYAN"
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
