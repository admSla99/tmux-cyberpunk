#!/usr/bin/env bash

build_segment() {
  local fg bg content pad
  fg="$1"
  bg="$2"
  content="$3"
  pad="$4"

  printf '#[fg=%s,bg=%s]%s%s%s' \
    "$fg" \
    "$bg" \
    "$(padding "$pad")" \
    "$content" \
    "$(padding "$pad")"
}

build_separator() {
  local fg bg separator
  fg="$1"
  bg="$2"
  separator="$3"

  printf '#[fg=%s,bg=%s]%s' "$fg" "$bg" "$separator"
}

apply_status() {
  local padding_size nerd_fonts show_session show_host show_time
  local separator_left separator_right
  local status_left status_right
  local right_bg segment

  padding_size="$(coerce_non_negative_integer "$(get_option "@cyberpunk-padding" "1")" "1")"
  nerd_fonts="$(get_option "@cyberpunk-nerd-fonts" "off")"
  separator_left="$(get_option "@cyberpunk-separator-left" "")"
  separator_right="$(get_option "@cyberpunk-separator-right" "")"
  show_session="$(get_option "@cyberpunk-show-session" "on")"
  show_host="$(get_option "@cyberpunk-show-host" "on")"
  show_time="$(get_option "@cyberpunk-show-time" "on")"

  status_left=""
  status_right=""

  if is_true "$show_session"; then
    if is_true "$nerd_fonts"; then
      status_left="$status_left$(build_separator "$CYBERPUNK_COLOR_PRIMARY" "$CYBERPUNK_COLOR_BG" "$separator_left")"
    fi

    segment="$(build_segment "$CYBERPUNK_COLOR_ACCENT" "$CYBERPUNK_COLOR_PRIMARY" "#S" "$padding_size")"
    status_left="$status_left$segment"

    if is_true "$nerd_fonts"; then
      status_left="$status_left$(build_separator "$CYBERPUNK_COLOR_BG" "$CYBERPUNK_COLOR_PRIMARY" "$separator_left")"
    fi
  fi

  right_bg="$CYBERPUNK_COLOR_BG"

  if is_true "$show_host"; then
    if is_true "$nerd_fonts"; then
      status_right="$status_right$(build_separator "$CYBERPUNK_COLOR_SECONDARY" "$right_bg" "$separator_right")"
    fi

    segment="$(build_segment "$CYBERPUNK_COLOR_ACCENT" "$CYBERPUNK_COLOR_SECONDARY" "#H" "$padding_size")"
    status_right="$status_right$segment"
    right_bg="$CYBERPUNK_COLOR_SECONDARY"
  fi

  if is_true "$show_time"; then
    if is_true "$nerd_fonts"; then
      status_right="$status_right$(build_separator "$CYBERPUNK_COLOR_CYAN" "$right_bg" "$separator_right")"
    elif [ -n "$status_right" ]; then
      status_right="$status_right "
    fi

    segment="$(build_segment "$CYBERPUNK_COLOR_BG" "$CYBERPUNK_COLOR_CYAN" "%H:%M" "$padding_size")"
    status_right="$status_right$segment"
    right_bg="$CYBERPUNK_COLOR_CYAN"
  fi

  if [ -n "$status_right" ] && is_true "$nerd_fonts"; then
    status_right="$status_right$(build_separator "$CYBERPUNK_COLOR_BG" "$right_bg" "$separator_right")"
  fi

  tmux set-option -gq status-left "$status_left"
  tmux set-option -gq status-right "$status_right"
  tmux set-option -gq status-left-length 100
  tmux set-option -gq status-right-length 100
}
