#!/usr/bin/env bash
set -euo pipefail

path="${1:-}"
show_dirty="${2:-on}"
prefix="${3:-git:}"
show_updown="${4:-on}"

if [ -z "$path" ] || [ ! -d "$path" ]; then
  exit 0
fi

cd "$path"

if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  exit 0
fi

branch="$(git symbolic-ref --quiet --short HEAD 2>/dev/null || git rev-parse --short HEAD 2>/dev/null)"

if [ -z "$branch" ]; then
  exit 0
fi

dirty_suffix=""
case "$(printf '%s' "$show_dirty" | tr '[:upper:]' '[:lower:]')" in
  1 | true | on | yes | y)
    if [ -n "$(git status --porcelain --ignore-submodules=dirty 2>/dev/null)" ]; then
      dirty_suffix="*"
    fi
    ;;
esac

updown_suffix=""
case "$(printf '%s' "$show_updown" | tr '[:upper:]' '[:lower:]')" in
  1 | true | on | yes | y)
    upstream="$(git rev-parse --abbrev-ref --symbolic-full-name '@{upstream}' 2>/dev/null || true)"
    if [ -n "$upstream" ] && git rev-parse --verify --quiet "$upstream" >/dev/null 2>&1; then
      counts="$(git rev-list --left-right --count "HEAD...$upstream" 2>/dev/null || true)"
      if [ -n "$counts" ]; then
        read -r ahead_count behind_count _ <<< "$counts"
        ahead_count="${ahead_count:-0}"
        behind_count="${behind_count:-0}"

        if [ "$ahead_count" -gt 0 ] 2>/dev/null; then
          updown_suffix="$updown_suffix ↑$ahead_count"
        fi

        if [ "$behind_count" -gt 0 ] 2>/dev/null; then
          updown_suffix="$updown_suffix ↓$behind_count"
        fi
      fi
    fi
    ;;
esac

printf '%s%s%s%s' "$prefix" "$branch" "$dirty_suffix" "$updown_suffix"
