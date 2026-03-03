#!/usr/bin/env bash

get_option() {
  local option
  option="$(tmux show-option -gqv "$1")"

  if [ -z "$option" ]; then
    printf '%s\n' "$2"
  else
    printf '%s\n' "$option"
  fi
}

set_option() {
  tmux set-option -gq "$1" "$2"
}

upsert_option() {
  local option
  option="$(tmux show-option -gqv "$1")"

  if [ -z "$option" ]; then
    tmux set-option -gq "$1" "$2"
  fi
}

is_true() {
  case "$(printf '%s' "${1:-}" | tr '[:upper:]' '[:lower:]')" in
    1 | true | on | yes | y)
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

padding() {
  printf '%*s' "${1:-0}" ""
}

is_valid_hex_color() {
  case "${1:-}" in
    \#[0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f])
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

is_non_negative_integer() {
  case "${1:-}" in
    '' | *[!0-9]*)
      return 1
      ;;
    *)
      return 0
      ;;
  esac
}

coerce_non_negative_integer() {
  local value fallback
  value="$1"
  fallback="$2"

  if is_non_negative_integer "$value"; then
    printf '%s\n' "$value"
  else
    printf '%s\n' "$fallback"
  fi
}

coerce_positive_integer() {
  local value fallback
  value="$1"
  fallback="$2"

  if is_non_negative_integer "$value" && [ "$value" -gt 0 ]; then
    printf '%s\n' "$value"
  else
    printf '%s\n' "$fallback"
  fi
}
