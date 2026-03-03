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

append_left_segment() {
  local segment_fg segment_bg content
  segment_fg="$1"
  segment_bg="$2"
  content="$3"

  if is_true "$nerd_fonts"; then
    if [ "$separator_style" = "ghost" ]; then
      status_left="$status_left$(build_separator "$segment_bg" "$CYBERPUNK_COLOR_BG" "$separator_left")"
      status_left="$status_left$(build_segment "$segment_bg" "$CYBERPUNK_COLOR_BG" "$content" "$padding_size")"
      return 0
    fi

    status_left="$status_left$(build_separator "$segment_bg" "$CYBERPUNK_COLOR_BG" "$separator_left")"
    status_left="$status_left$(build_segment "$segment_fg" "$segment_bg" "$content" "$padding_size")"
    status_left="$status_left$(build_separator "$CYBERPUNK_COLOR_BG" "$segment_bg" "$separator_left")"
    return 0
  fi

  status_left="$status_left$(build_segment "$segment_fg" "$segment_bg" "$content" "$padding_size")"
}

append_right_segment() {
  local segment_fg segment_bg content
  segment_fg="$1"
  segment_bg="$2"
  content="$3"

  if is_true "$nerd_fonts"; then
    if [ "$separator_style" = "ghost" ]; then
      status_right="$status_right$(build_separator "$segment_bg" "$CYBERPUNK_COLOR_BG" "$separator_right")"
      status_right="$status_right$(build_segment "$segment_bg" "$CYBERPUNK_COLOR_BG" "$content" "$padding_size")"
      right_bg="$CYBERPUNK_COLOR_BG"
      has_static_right_segments=true
      return 0
    fi

    status_right="$status_right$(build_separator "$segment_bg" "$right_bg" "$separator_right")"
  elif [ -n "$status_right" ]; then
    status_right="$status_right "
  fi

  status_right="$status_right$(build_segment "$segment_fg" "$segment_bg" "$content" "$padding_size")"
  right_bg="$segment_bg"
  has_static_right_segments=true
}

apply_status() {
  local padding_size nerd_fonts show_session show_mode show_git
  local show_network show_cpu show_memory show_battery show_host show_time
  local mode_content network_content cpu_content memory_content battery_content
  local git_segment_script_quoted system_info_script_quoted
  local color_bg_quoted color_primary_quoted color_accent_quoted right_bg_quoted has_static_quoted
  local separator_style
  local has_static_right_segments
  local separator_left separator_right
  local status_left status_right
  local right_bg

  padding_size="$(coerce_non_negative_integer "$(get_option "@cyberpunk-padding" "1")" "1")"
  nerd_fonts="$(get_option "@cyberpunk-nerd-fonts" "off")"
  separator_left="$(get_option "@cyberpunk-separator-left" "")"
  separator_right="$(get_option "@cyberpunk-separator-right" "")"
  separator_style="$(get_option "@cyberpunk-separator-style" "ghost")"
  show_session="$(get_option "@cyberpunk-show-session" "on")"
  show_mode="$(get_option "@cyberpunk-show-mode" "on")"
  show_git="$(get_option "@cyberpunk-show-git" "on")"
  show_network="$(get_option "@cyberpunk-show-network" "on")"
  show_cpu="$(get_option "@cyberpunk-show-cpu" "on")"
  show_memory="$(get_option "@cyberpunk-show-memory" "on")"
  show_battery="$(get_option "@cyberpunk-show-battery" "on")"
  show_host="$(get_option "@cyberpunk-show-host" "on")"
  show_time="$(get_option "@cyberpunk-show-time" "on")"

  status_left=""
  status_right=""

  if is_true "$show_session"; then
    append_left_segment "$CYBERPUNK_COLOR_ACCENT" "$CYBERPUNK_COLOR_PRIMARY" "#S"
  fi

  if is_true "$show_mode"; then
    mode_content="#{?client_prefix,PREFIX,#{?pane_in_mode,COPY,#{?pane_synchronized,SYNC,LIVE}}}"
    append_left_segment "$CYBERPUNK_COLOR_BG" "$CYBERPUNK_COLOR_CYAN" "$mode_content"
  fi

  right_bg="$CYBERPUNK_COLOR_BG"
  has_static_right_segments=false

  printf -v system_info_script_quoted '%q' "$CURRENT_DIR/system_info.sh"

  if is_true "$show_network"; then
    network_content="#(${system_info_script_quoted} network #{q:@cyberpunk-network-host} #{q:@cyberpunk-network-timeout-ms})"
    append_right_segment "$CYBERPUNK_COLOR_ACCENT" "$CYBERPUNK_COLOR_PRIMARY" "$network_content"
  fi

  if is_true "$show_cpu"; then
    cpu_content="#(${system_info_script_quoted} cpu)"
    append_right_segment "$CYBERPUNK_COLOR_ACCENT" "$CYBERPUNK_COLOR_PRIMARY" "$cpu_content"
  fi

  if is_true "$show_memory"; then
    memory_content="#(${system_info_script_quoted} memory)"
    append_right_segment "$CYBERPUNK_COLOR_BG" "$CYBERPUNK_COLOR_CYAN" "$memory_content"
  fi

  if is_true "$show_battery"; then
    battery_content="#(${system_info_script_quoted} battery)"
    append_right_segment "$CYBERPUNK_COLOR_BG" "$CYBERPUNK_COLOR_ACCENT" "$battery_content"
  fi

  if is_true "$show_host"; then
    append_right_segment "$CYBERPUNK_COLOR_ACCENT" "$CYBERPUNK_COLOR_SECONDARY" "#H"
  fi

  if is_true "$show_time"; then
    append_right_segment "$CYBERPUNK_COLOR_BG" "$CYBERPUNK_COLOR_CYAN" "%H:%M"
  fi

  if is_true "$show_git"; then
    printf -v git_segment_script_quoted '%q' "$CURRENT_DIR/git_segment.sh"
    printf -v color_bg_quoted '%q' "$CYBERPUNK_COLOR_BG"
    printf -v color_primary_quoted '%q' "$CYBERPUNK_COLOR_PRIMARY"
    printf -v color_accent_quoted '%q' "$CYBERPUNK_COLOR_ACCENT"
    printf -v right_bg_quoted '%q' "$right_bg"
    printf -v has_static_quoted '%q' "$has_static_right_segments"

    status_right="$status_right#(${git_segment_script_quoted} #{q:pane_current_path} #{q:@cyberpunk-git-show-dirty} #{q:@cyberpunk-git-prefix} #{q:@cyberpunk-git-show-updown} #{q:@cyberpunk-padding} #{q:@cyberpunk-nerd-fonts} #{q:@cyberpunk-separator-right} ${color_bg_quoted} ${color_primary_quoted} ${color_accent_quoted} ${right_bg_quoted} ${has_static_quoted} #{q:@cyberpunk-separator-style})"
  fi

  tmux set-option -gq status-left "$status_left"
  tmux set-option -gq status-right "$status_right"
  tmux set-option -gq status-left-length 100
  tmux set-option -gq status-right-length 100
}
