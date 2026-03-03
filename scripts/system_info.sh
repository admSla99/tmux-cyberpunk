#!/usr/bin/env bash
set -euo pipefail

metric="${1:-}"

safe_timeout_ms() {
  local raw
  raw="${1:-250}"
  if [[ "$raw" =~ ^[0-9]+$ ]] && [ "$raw" -gt 0 ]; then
    printf '%s\n' "$raw"
  else
    printf '250\n'
  fi
}

ms_to_timeout_seconds() {
  local timeout_ms timeout_seconds
  timeout_ms="$(safe_timeout_ms "${1:-250}")"
  timeout_seconds="$(awk -v ms="$timeout_ms" 'BEGIN { printf "%.3f", ms / 1000 }')"
  printf '%s\n' "$timeout_seconds"
}

get_cpu() {
  local load
  load="$(LC_ALL=C uptime 2>/dev/null | sed -nE 's/.*load averages?: ([0-9]+([.][0-9]+)?).*/\1/p' | head -n 1)"
  if [ -z "$load" ] && [ -r /proc/loadavg ]; then
    load="$(awk '{print $1}' /proc/loadavg 2>/dev/null || true)"
  fi
  if [ -z "$load" ]; then
    load="--"
  fi
  printf 'CPU %s' "$load"
}

get_memory() {
  local mem_pct total_kb available_kb used_kb

  if command -v free >/dev/null 2>&1; then
    mem_pct="$(free 2>/dev/null | awk '/^Mem:/ { if ($2 > 0) printf "%.0f%%", ($3 / $2) * 100 }')"
    if [ -n "$mem_pct" ]; then
      printf 'MEM %s' "$mem_pct"
      return 0
    fi
  fi

  if [ -r /proc/meminfo ]; then
    total_kb="$(awk '/^MemTotal:/ {print $2}' /proc/meminfo 2>/dev/null || true)"
    available_kb="$(awk '/^MemAvailable:/ {print $2}' /proc/meminfo 2>/dev/null || true)"
    if [ -n "$total_kb" ] && [ -n "$available_kb" ] && [ "$total_kb" -gt 0 ] 2>/dev/null; then
      used_kb=$((total_kb - available_kb))
      mem_pct="$(awk -v used="$used_kb" -v total="$total_kb" 'BEGIN { printf "%.0f%%", (used / total) * 100 }')"
      printf 'MEM %s' "$mem_pct"
      return 0
    fi
  fi

  printf 'MEM --'
}

get_battery() {
  local bat_path capacity status

  for bat_path in /sys/class/power_supply/BAT*; do
    [ -d "$bat_path" ] || continue
    capacity="$(cat "$bat_path/capacity" 2>/dev/null || true)"
    status="$(cat "$bat_path/status" 2>/dev/null || true)"
    if [ -n "$capacity" ]; then
      case "$status" in
        Charging)
          printf 'BAT %s%%+' "$capacity"
          ;;
        *)
          printf 'BAT %s%%' "$capacity"
          ;;
      esac
      return 0
    fi
  done

  if command -v pmset >/dev/null 2>&1; then
    capacity="$(pmset -g batt 2>/dev/null | sed -nE 's/.* ([0-9]+)%\;.*/\1/p' | head -n 1)"
    if [ -n "$capacity" ]; then
      printf 'BAT %s%%' "$capacity"
      return 0
    fi
  fi

  printf 'BAT AC'
}

get_network() {
  local host timeout_ms timeout_seconds timeout_cmd output latency os_name timeout_whole_seconds
  host="${1:-1.1.1.1}"
  timeout_ms="$(safe_timeout_ms "${2:-250}")"
  timeout_seconds="$(ms_to_timeout_seconds "$timeout_ms")"

  if ! command -v ping >/dev/null 2>&1; then
    printf 'NET --'
    return 0
  fi

  timeout_cmd=()
  if command -v timeout >/dev/null 2>&1; then
    timeout_cmd=(timeout "${timeout_seconds}s")
  elif command -v gtimeout >/dev/null 2>&1; then
    timeout_cmd=(gtimeout "${timeout_seconds}s")
  fi

  if [ "${#timeout_cmd[@]}" -gt 0 ]; then
    output="$("${timeout_cmd[@]}" ping -c 1 "$host" 2>/dev/null || true)"
  else
    os_name="$(uname -s 2>/dev/null || echo '')"
    case "$os_name" in
      Darwin)
        output="$(ping -c 1 -W "$timeout_ms" "$host" 2>/dev/null || true)"
        ;;
      *)
        timeout_whole_seconds="$(awk -v ms="$timeout_ms" 'BEGIN { s = int((ms + 999) / 1000); if (s < 1) s = 1; print s }')"
        output="$(ping -c 1 -W "$timeout_whole_seconds" "$host" 2>/dev/null || true)"
        ;;
    esac
  fi

  latency="$(printf '%s\n' "$output" | sed -nE 's/.*time=([0-9]+([.][0-9]+)?).*/\1/p' | head -n 1)"
  if [ -n "$latency" ]; then
    printf 'NET %sms' "$latency"
  else
    printf 'NET --'
  fi
}

case "$metric" in
  cpu)
    get_cpu
    ;;
  memory)
    get_memory
    ;;
  battery)
    get_battery
    ;;
  network)
    get_network "${2:-1.1.1.1}" "${3:-250}"
    ;;
  *)
    printf 'N/A'
    ;;
esac
