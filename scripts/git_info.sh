#!/usr/bin/env bash
set -euo pipefail

path="${1:-}"
show_dirty="${2:-on}"
prefix="${3:-git:}"

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

printf '%s%s%s' "$prefix" "$branch" "$dirty_suffix"
