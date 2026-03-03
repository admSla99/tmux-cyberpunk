#!/usr/bin/env bash
set -euo pipefail

current_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

path="${1:-}"
show_dirty="${2:-on}"
prefix="${3:-git:}"
padding_raw="${4:-1}"
nerd_fonts="${5:-off}"
separator_right="${6:-}"
color_bg="${7:-#000000}"
color_primary="${8:-#c5003c}"
color_accent="${9:-#f3e600}"
right_bg="${10:-#000000}"
has_static_right_segments="${11:-false}"

if [[ "$padding_raw" =~ ^[0-9]+$ ]]; then
  padding_size="$padding_raw"
else
  padding_size="1"
fi

git_text="$("$current_dir/git_info.sh" "$path" "$show_dirty" "$prefix")"
if [ -z "$git_text" ]; then
  exit 0
fi

# Avoid tmux format/style interpolation from repository-controlled branch names.
git_text="${git_text//#/##}"
pad="$(printf '%*s' "$padding_size" "")"

case "$(printf '%s' "$nerd_fonts" | tr '[:upper:]' '[:lower:]')" in
  1 | true | on | yes | y)
    printf '#[fg=%s,bg=%s]%s#[fg=%s,bg=%s]%s%s%s#[fg=%s,bg=%s]%s' \
      "$color_primary" \
      "$right_bg" \
      "$separator_right" \
      "$color_accent" \
      "$color_primary" \
      "$pad" \
      "$git_text" \
      "$pad" \
      "$color_bg" \
      "$color_primary" \
      "$separator_right"
    ;;
  *)
    if [ "$has_static_right_segments" = "true" ]; then
      printf ' '
    fi
    printf '#[fg=%s,bg=%s]%s%s%s' "$color_accent" "$color_primary" "$pad" "$git_text" "$pad"
    ;;
esac
