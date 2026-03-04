#!/usr/bin/env bash
# shellcheck disable=SC2034
# Global palette variables are consumed across sourced plugin scripts.

CYBERPUNK_DEFAULT_BG="#000000"
CYBERPUNK_DEFAULT_PRIMARY="#c5003c"
CYBERPUNK_DEFAULT_SECONDARY="#880425"
CYBERPUNK_DEFAULT_ACCENT="#f3e600"
CYBERPUNK_DEFAULT_CYAN="#55ead4"
CYBERPUNK_DEFAULT_WARNING="#f3e600"

CYBERPUNK_COLOR_BG=""
CYBERPUNK_COLOR_PRIMARY=""
CYBERPUNK_COLOR_SECONDARY=""
CYBERPUNK_COLOR_ACCENT=""
CYBERPUNK_COLOR_CYAN=""
CYBERPUNK_COLOR_WARNING=""

load_palette() {
  local color_bg color_primary color_secondary color_accent color_cyan color_warning

  color_bg="$(get_option "@cyberpunk-color-bg" "$CYBERPUNK_DEFAULT_BG")"
  color_primary="$(get_option "@cyberpunk-color-primary" "$CYBERPUNK_DEFAULT_PRIMARY")"
  color_secondary="$(get_option "@cyberpunk-color-secondary" "$CYBERPUNK_DEFAULT_SECONDARY")"
  color_accent="$(get_option "@cyberpunk-color-accent" "$CYBERPUNK_DEFAULT_ACCENT")"
  color_cyan="$(get_option "@cyberpunk-color-cyan" "$CYBERPUNK_DEFAULT_CYAN")"
  color_warning="$(get_option "@cyberpunk-color-warning" "$CYBERPUNK_DEFAULT_WARNING")"

  if ! is_valid_hex_color "$color_bg"; then
    color_bg="$CYBERPUNK_DEFAULT_BG"
  fi

  if ! is_valid_hex_color "$color_primary"; then
    color_primary="$CYBERPUNK_DEFAULT_PRIMARY"
  fi

  if ! is_valid_hex_color "$color_secondary"; then
    color_secondary="$CYBERPUNK_DEFAULT_SECONDARY"
  fi

  if ! is_valid_hex_color "$color_accent"; then
    color_accent="$CYBERPUNK_DEFAULT_ACCENT"
  fi

  if ! is_valid_hex_color "$color_cyan"; then
    color_cyan="$CYBERPUNK_DEFAULT_CYAN"
  fi

  if ! is_valid_hex_color "$color_warning"; then
    color_warning="$CYBERPUNK_DEFAULT_WARNING"
  fi

  CYBERPUNK_COLOR_BG="$color_bg"
  CYBERPUNK_COLOR_PRIMARY="$color_primary"
  CYBERPUNK_COLOR_SECONDARY="$color_secondary"
  CYBERPUNK_COLOR_ACCENT="$color_accent"
  CYBERPUNK_COLOR_CYAN="$color_cyan"
  CYBERPUNK_COLOR_WARNING="$color_warning"
}
