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

normalize_icon_pack() {
  case "$(printf '%s' "${1:-}" | tr '[:upper:]' '[:lower:]')" in
    emoji | nerd | cyber-fa | ascii | none)
      printf '%s\n' "$(printf '%s' "${1:-}" | tr '[:upper:]' '[:lower:]')"
      ;;
    *)
      printf 'emoji\n'
      ;;
  esac
}

icon_for() {
  local slot pack
  slot="$1"
  pack="$2"

  case "$pack" in
    emoji)
      case "$slot" in
        session) printf '📡' ;;
        mode_prefix) printf '⌨' ;;
        mode_copy) printf '📋' ;;
        mode_sync) printf '🔗' ;;
        mode_live) printf '⚡' ;;
        network) printf '🌐' ;;
        cpu) printf '🧠' ;;
        memory) printf '💾' ;;
        battery) printf '🔋' ;;
        host) printf '🖥' ;;
        time) printf '🕒' ;;
      esac
      ;;
    nerd)
      case "$slot" in
        session) printf '󰓩' ;;
        mode_prefix) printf '󰌌' ;;
        mode_copy) printf '󰆏' ;;
        mode_sync) printf '󰓦' ;;
        mode_live) printf '󱐋' ;;
        network) printf '󰖩' ;;
        cpu) printf '󰍛' ;;
        memory) printf '󰘚' ;;
        battery) printf '󰁹' ;;
        host) printf '󰒋' ;;
        time) printf '󱑂' ;;
      esac
      ;;
    cyber-fa)
      case "$slot" in
        session) printf '' ;;
        mode_prefix) printf '⌨' ;;
        mode_copy) printf '' ;;
        mode_sync) printf '' ;;
        mode_live) printf '' ;;
        network) printf '' ;;
        cpu) printf '' ;;
        memory) printf '' ;;
        battery) printf '' ;;
        host) printf '' ;;
        time) printf '' ;;
      esac
      ;;
    ascii)
      case "$slot" in
        session) printf 'S' ;;
        mode_prefix) printf 'P' ;;
        mode_copy) printf 'C' ;;
        mode_sync) printf 'Y' ;;
        mode_live) printf 'L' ;;
        network) printf 'N' ;;
        cpu) printf 'C' ;;
        memory) printf 'M' ;;
        battery) printf 'B' ;;
        host) printf 'H' ;;
        time) printf 'T' ;;
      esac
      ;;
    none)
      printf ''
      ;;
  esac
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
  local show_icons icon_pack
  local session_icon mode_prefix_icon mode_copy_icon mode_sync_icon mode_live_icon
  local network_icon cpu_icon memory_icon battery_icon host_icon time_icon
  local session_content host_content time_content
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
  show_icons="$(get_option "@cyberpunk-show-icons" "on")"
  icon_pack="$(normalize_icon_pack "$(get_option "@cyberpunk-icon-pack" "cyber-fa")")"

  session_icon=""
  mode_prefix_icon=""
  mode_copy_icon=""
  mode_sync_icon=""
  mode_live_icon=""
  network_icon=""
  cpu_icon=""
  memory_icon=""
  battery_icon=""
  host_icon=""
  time_icon=""

  if is_true "$show_icons"; then
    session_icon="$(icon_for session "$icon_pack")"
    mode_prefix_icon="$(icon_for mode_prefix "$icon_pack")"
    mode_copy_icon="$(icon_for mode_copy "$icon_pack")"
    mode_sync_icon="$(icon_for mode_sync "$icon_pack")"
    mode_live_icon="$(icon_for mode_live "$icon_pack")"
    network_icon="$(icon_for network "$icon_pack")"
    cpu_icon="$(icon_for cpu "$icon_pack")"
    memory_icon="$(icon_for memory "$icon_pack")"
    battery_icon="$(icon_for battery "$icon_pack")"
    host_icon="$(icon_for host "$icon_pack")"
    time_icon="$(icon_for time "$icon_pack")"
  fi

  status_left=""
  status_right=""

  if is_true "$show_session"; then
    session_content="#S"
    if [ -n "$session_icon" ]; then
      session_content="$session_icon $session_content"
    fi
    append_left_segment "$CYBERPUNK_COLOR_ACCENT" "$CYBERPUNK_COLOR_PRIMARY" "$session_content"
  fi

  if is_true "$show_mode"; then
    if [ -n "$mode_live_icon" ]; then
      mode_content="#{?client_prefix,${mode_prefix_icon} PREFIX,#{?pane_in_mode,${mode_copy_icon} COPY,#{?pane_synchronized,${mode_sync_icon} SYNC,${mode_live_icon} LIVE}}}"
    else
      mode_content="#{?client_prefix,PREFIX,#{?pane_in_mode,COPY,#{?pane_synchronized,SYNC,LIVE}}}"
    fi
    append_left_segment "$CYBERPUNK_COLOR_BG" "$CYBERPUNK_COLOR_CYAN" "$mode_content"
  fi

  right_bg="$CYBERPUNK_COLOR_BG"
  has_static_right_segments=false

  printf -v system_info_script_quoted '%q' "$CURRENT_DIR/system_info.sh"

  if is_true "$show_network"; then
    network_content="#(${system_info_script_quoted} network #{q:@cyberpunk-network-host} #{q:@cyberpunk-network-timeout-ms})"
    if [ -n "$network_icon" ]; then
      network_content="$network_icon $network_content"
    fi
    append_right_segment "$CYBERPUNK_COLOR_ACCENT" "$CYBERPUNK_COLOR_PRIMARY" "$network_content"
  fi

  if is_true "$show_cpu"; then
    cpu_content="#(${system_info_script_quoted} cpu)"
    if [ -n "$cpu_icon" ]; then
      cpu_content="$cpu_icon $cpu_content"
    fi
    append_right_segment "$CYBERPUNK_COLOR_ACCENT" "$CYBERPUNK_COLOR_PRIMARY" "$cpu_content"
  fi

  if is_true "$show_memory"; then
    memory_content="#(${system_info_script_quoted} memory)"
    if [ -n "$memory_icon" ]; then
      memory_content="$memory_icon $memory_content"
    fi
    append_right_segment "$CYBERPUNK_COLOR_BG" "$CYBERPUNK_COLOR_CYAN" "$memory_content"
  fi

  if is_true "$show_battery"; then
    battery_content="#(${system_info_script_quoted} battery)"
    if [ -n "$battery_icon" ]; then
      battery_content="$battery_icon $battery_content"
    fi
    append_right_segment "$CYBERPUNK_COLOR_BG" "$CYBERPUNK_COLOR_WARNING" "$battery_content"
  fi

  if is_true "$show_host"; then
    host_content="#H"
    if [ -n "$host_icon" ]; then
      host_content="$host_icon $host_content"
    fi
    append_right_segment "$CYBERPUNK_COLOR_ACCENT" "$CYBERPUNK_COLOR_SECONDARY" "$host_content"
  fi

  if is_true "$show_time"; then
    time_content="%H:%M"
    if [ -n "$time_icon" ]; then
      time_content="$time_icon $time_content"
    fi
    append_right_segment "$CYBERPUNK_COLOR_BG" "$CYBERPUNK_COLOR_CYAN" "$time_content"
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
