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

assert_equals() {
  local expected actual message
  expected="$1"
  actual="$2"
  message="$3"

  if [ "$expected" != "$actual" ]; then
    printf 'ASSERT FAILED: %s\nExpected: %s\nActual:   %s\n' "$message" "$expected" "$actual" >&2
    exit 1
  fi
}

socket_a="cp-test-pro-a"
socket_b="cp-test-pro-b"

tmux -L "$socket_a" -f /dev/null new-session -d -s test -c /tmp
tmux -L "$socket_a" set-option -g @cyberpunk-show-session on
tmux -L "$socket_a" set-option -g @cyberpunk-show-mode on
tmux -L "$socket_a" set-option -g @cyberpunk-show-git off
tmux -L "$socket_a" set-option -g @cyberpunk-show-host off
tmux -L "$socket_a" set-option -g @cyberpunk-show-time off
tmux -L "$socket_a" set-option -g @cyberpunk-show-cpu on
tmux -L "$socket_a" set-option -g @cyberpunk-show-memory on
tmux -L "$socket_a" set-option -g @cyberpunk-show-battery on
tmux -L "$socket_a" set-option -g @cyberpunk-show-network on
tmux -L "$socket_a" run-shell "$REPO_ROOT/cyberpunk.tmux"
status_left_pro="$(tmux -L "$socket_a" show-options -gqv status-left)"
status_right_pro="$(tmux -L "$socket_a" show-options -gqv status-right)"
tmux -L "$socket_a" kill-server

assert_contains "$status_left_pro" "#{?client_prefix" "left side should include mode awareness segment"
assert_contains "$status_right_pro" "scripts/system_info.sh cpu" "right side should include cpu segment command"
assert_contains "$status_right_pro" "scripts/system_info.sh memory" "right side should include memory segment command"
assert_contains "$status_right_pro" "scripts/system_info.sh battery" "right side should include battery segment command"
assert_contains "$status_right_pro" "scripts/system_info.sh network" "right side should include network segment command"

tmux -L "$socket_b" -f /dev/null new-session -d -s test -c /tmp
tmux -L "$socket_b" set-option -g @cyberpunk-show-session off
tmux -L "$socket_b" set-option -g @cyberpunk-show-mode off
tmux -L "$socket_b" set-option -g @cyberpunk-show-git off
tmux -L "$socket_b" set-option -g @cyberpunk-show-host off
tmux -L "$socket_b" set-option -g @cyberpunk-show-time off
tmux -L "$socket_b" set-option -g @cyberpunk-show-cpu off
tmux -L "$socket_b" set-option -g @cyberpunk-show-memory off
tmux -L "$socket_b" set-option -g @cyberpunk-show-battery off
tmux -L "$socket_b" set-option -g @cyberpunk-show-network off
tmux -L "$socket_b" run-shell "$REPO_ROOT/cyberpunk.tmux"
status_left_min="$(tmux -L "$socket_b" show-options -gqv status-left)"
status_right_min="$(tmux -L "$socket_b" show-options -gqv status-right)"
tmux -L "$socket_b" kill-server

assert_equals "" "$status_left_min" "status-left should be empty when all left segments are disabled"
assert_equals "" "$status_right_min" "status-right should be empty when all right segments are disabled"

printf 'cyberhud_pro_format_test: PASS\n'
