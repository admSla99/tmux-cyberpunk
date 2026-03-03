#!/usr/bin/env bash
set -euo pipefail

current_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

path="${1:-}"
show_dirty="${2:-on}"
prefix="${3:-git:}"
show_updown="${4:-on}"
padding_raw="${5:-1}"
nerd_fonts="${6:-off}"
separator_right="${7:-}"
color_bg="${8:-#000000}"
color_primary="${9:-#c5003c}"
color_accent="${10:-#f3e600}"
right_bg="${11:-#000000}"
has_static_right_segments="${12:-false}"
separator_style="${13:-legacy}"

if [[ "$padding_raw" =~ ^[0-9]+$ ]]; then
  padding_size="$padding_raw"
else
  padding_size="1"
fi

git_text="$("$current_dir/git_info.sh" "$path" "$show_dirty" "$prefix" "$show_updown")"
if [ -z "$git_text" ]; then
  exit 0
fi

# Avoid tmux format/style interpolation from repository-controlled branch names.
git_text="${git_text//#/##}"
pad="$(printf '%*s' "$padding_size" "")"

case "$(printf '%s' "$nerd_fonts" | tr '[:upper:]' '[:lower:]')" in
  1 | true | on | yes | y)
    if [ "$separator_style" = "ghost" ]; then
      printf '#[fg=%s,bg=%s]%s#[fg=%s,bg=%s]%s%s%s' \
        "$color_primary" \
        "$color_bg" \
        "$separator_right" \
        "$color_primary" \
        "$color_bg" \
        "$pad" \
        "$git_text" \
        "$pad"
      exit 0
    fi

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
