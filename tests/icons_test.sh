#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

assert_contains() {
  local haystack needle message
  haystack="$1"
  needle="$2"
  message="$3"

  if [[ "$haystack" != *"$needle"* ]]; then
    printf 'ASSERT FAILED: %s\nExpected to contain: %s\nActual: %s\n' "$message" "$needle" "$haystack" >&2
    exit 1
  fi
}

assert_not_contains() {
  local haystack needle message
  haystack="$1"
  needle="$2"
  message="$3"

  if [[ "$haystack" == *"$needle"* ]]; then
    printf 'ASSERT FAILED: %s\nDid not expect: %s\nActual: %s\n' "$message" "$needle" "$haystack" >&2
    exit 1
  fi
}

socket_a="cp-test-icons-a"
socket_b="cp-test-icons-b"

tmux -L "$socket_a" -f /dev/null new-session -d -s test -c /tmp
tmux -L "$socket_a" set-option -g @cyberpunk-show-icons on
tmux -L "$socket_a" set-option -g @cyberpunk-icon-pack emoji
tmux -L "$socket_a" set-option -g @cyberpunk-show-git off
tmux -L "$socket_a" set-option -g @cyberpunk-show-host off
tmux -L "$socket_a" set-option -g @cyberpunk-show-time off
tmux -L "$socket_a" set-option -g @cyberpunk-show-cpu off
tmux -L "$socket_a" set-option -g @cyberpunk-show-memory off
tmux -L "$socket_a" set-option -g @cyberpunk-show-battery off
tmux -L "$socket_a" set-option -g @cyberpunk-show-network on
tmux -L "$socket_a" run-shell "$REPO_ROOT/cyberpunk.tmux"
status_left_icons="$(tmux -L "$socket_a" show-options -gqv status-left)"
status_right_icons="$(tmux -L "$socket_a" show-options -gqv status-right)"
tmux -L "$socket_a" kill-server

assert_contains "$status_left_icons" "📡" "session segment should include emoji icon"
assert_contains "$status_left_icons" "⚡" "mode segment should include live icon"
assert_contains "$status_right_icons" "🌐" "network segment should include emoji icon"

tmux -L "$socket_b" -f /dev/null new-session -d -s test -c /tmp
tmux -L "$socket_b" set-option -g @cyberpunk-show-icons off
tmux -L "$socket_b" set-option -g @cyberpunk-icon-pack emoji
tmux -L "$socket_b" set-option -g @cyberpunk-show-git off
tmux -L "$socket_b" set-option -g @cyberpunk-show-host off
tmux -L "$socket_b" set-option -g @cyberpunk-show-time off
tmux -L "$socket_b" set-option -g @cyberpunk-show-cpu off
tmux -L "$socket_b" set-option -g @cyberpunk-show-memory off
tmux -L "$socket_b" set-option -g @cyberpunk-show-battery off
tmux -L "$socket_b" set-option -g @cyberpunk-show-network on
tmux -L "$socket_b" run-shell "$REPO_ROOT/cyberpunk.tmux"
status_left_no_icons="$(tmux -L "$socket_b" show-options -gqv status-left)"
status_right_no_icons="$(tmux -L "$socket_b" show-options -gqv status-right)"
tmux -L "$socket_b" kill-server

assert_not_contains "$status_left_no_icons" "📡" "session segment should hide icon when icons disabled"
assert_not_contains "$status_right_no_icons" "🌐" "network segment should hide icon when icons disabled"

printf 'icons_test: PASS\n'
