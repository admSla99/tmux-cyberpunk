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
    printf 'ASSERT FAILED: %s\nDid not expect to contain: %s\nActual: %s\n' "$message" "$needle" "$haystack" >&2
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

socket_a="cp-test-status-a"
socket_b="cp-test-status-b"

tmux -L "$socket_a" -f /dev/null new-session -d -s test -c /tmp
tmux -L "$socket_a" set-option -g @cyberpunk-show-host off
tmux -L "$socket_a" set-option -g @cyberpunk-show-time off
tmux -L "$socket_a" set-option -g @cyberpunk-show-network off
tmux -L "$socket_a" set-option -g @cyberpunk-show-cpu off
tmux -L "$socket_a" set-option -g @cyberpunk-show-memory off
tmux -L "$socket_a" set-option -g @cyberpunk-show-battery off
tmux -L "$socket_a" set-option -g @cyberpunk-show-git on
tmux -L "$socket_a" run-shell "$REPO_ROOT/cyberpunk.tmux"
status_right_git="$(tmux -L "$socket_a" show-options -gqv status-right)"
status_right_length_git="$(tmux -L "$socket_a" show-options -gqv status-right-length)"
tmux -L "$socket_a" kill-server

assert_contains "$status_right_git" "scripts/git_segment.sh" "git segment should call dedicated runtime renderer script"
assert_contains "$status_right_git" "#{q:pane_current_path}" "pane path should be shell-escaped using tmux q modifier"
assert_contains "$status_right_git" "#{q:@cyberpunk-git-prefix}" "git prefix should be shell-escaped using tmux q modifier"
assert_contains "$status_right_git" "#{q:@cyberpunk-git-show-updown}" "up/down toggle should be shell-escaped using tmux q modifier"
assert_contains "$status_right_git" "#{q:@cyberpunk-separator-style}" "separator style should be shell-escaped using tmux q modifier"
assert_not_contains "$status_right_git" "#{?#{!=:#(" "git segment must not use tmux conditional around #() command"
assert_equals "250" "$status_right_length_git" "status-right-length should default to cyberpunk value"

tmux -L "$socket_b" -f /dev/null new-session -d -s test -c /tmp
tmux -L "$socket_b" set-option -g @cyberpunk-show-host off
tmux -L "$socket_b" set-option -g @cyberpunk-show-time off
tmux -L "$socket_b" set-option -g @cyberpunk-show-network off
tmux -L "$socket_b" set-option -g @cyberpunk-show-cpu off
tmux -L "$socket_b" set-option -g @cyberpunk-show-memory off
tmux -L "$socket_b" set-option -g @cyberpunk-show-battery off
tmux -L "$socket_b" set-option -g @cyberpunk-show-git off
tmux -L "$socket_b" set-option -g @cyberpunk-status-right-length 333
tmux -L "$socket_b" run-shell "$REPO_ROOT/cyberpunk.tmux"
status_right_no_git="$(tmux -L "$socket_b" show-options -gqv status-right)"
status_right_length_custom="$(tmux -L "$socket_b" show-options -gqv status-right-length)"
tmux -L "$socket_b" kill-server

assert_equals "" "$status_right_no_git" "status-right should stay empty when git/host/time segments are disabled"
assert_equals "333" "$status_right_length_custom" "custom status-right-length should be respected"

printf 'status_git_format_test: PASS\n'
