#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

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

socket_a="cp-test-window-profile-a"
socket_b="cp-test-window-profile-b"
socket_c="cp-test-window-profile-c"
socket_d="cp-test-window-profile-d"

cleanup() {
  tmux -L "$socket_a" kill-server >/dev/null 2>&1 || true
  tmux -L "$socket_b" kill-server >/dev/null 2>&1 || true
  tmux -L "$socket_c" kill-server >/dev/null 2>&1 || true
  tmux -L "$socket_d" kill-server >/dev/null 2>&1 || true
}

trap cleanup EXIT
cleanup

tmux -L "$socket_a" -f /dev/null new-session -d -s test -c /tmp
tmux -L "$socket_a" run-shell "$REPO_ROOT/cyberpunk.tmux"
window_style_simple="$(tmux -L "$socket_a" show-window-options -gv window-style)"
window_active_style_simple="$(tmux -L "$socket_a" show-window-options -gv window-active-style)"

assert_equals "bg=#070b12,fg=#738399" "$window_style_simple" "simple profile window-style default"
assert_equals "bg=#0d1422,fg=#d7e3ef" "$window_active_style_simple" "simple profile window-active-style default"

tmux -L "$socket_b" -f /dev/null new-session -d -s test -c /tmp
tmux -L "$socket_b" set-option -g @cyberpunk-window-profile bold
tmux -L "$socket_b" run-shell "$REPO_ROOT/cyberpunk.tmux"
window_style_bold="$(tmux -L "$socket_b" show-window-options -gv window-style)"
window_active_style_bold="$(tmux -L "$socket_b" show-window-options -gv window-active-style)"

assert_equals "bg=#06090f,fg=#67788f" "$window_style_bold" "bold profile window-style"
assert_equals "bg=#111b2e,fg=#eef6ff" "$window_active_style_bold" "bold profile window-active-style"

tmux -L "$socket_c" -f /dev/null new-session -d -s test -c /tmp
tmux -L "$socket_c" set-option -g @cyberpunk-window-profile ultra
tmux -L "$socket_c" run-shell "$REPO_ROOT/cyberpunk.tmux"
window_style_ultra="$(tmux -L "$socket_c" show-window-options -gv window-style)"
window_active_style_ultra="$(tmux -L "$socket_c" show-window-options -gv window-active-style)"

assert_equals "bg=#05060a,fg=#665a78" "$window_style_ultra" "ultra profile window-style"
assert_equals "bg=#0a1020,fg=#55ead4" "$window_active_style_ultra" "ultra profile window-active-style"

tmux -L "$socket_d" -f /dev/null new-session -d -s test -c /tmp
tmux -L "$socket_d" set-option -g @cyberpunk-window-profile ultra
tmux -L "$socket_d" set-option -g @cyberpunk-window-style "bg=#101010,fg=#8f8f8f"
tmux -L "$socket_d" set-option -g @cyberpunk-window-active-style "bg=#181818,fg=#f0f0f0"
tmux -L "$socket_d" run-shell "$REPO_ROOT/cyberpunk.tmux"
window_style_override="$(tmux -L "$socket_d" show-window-options -gv window-style)"
window_active_style_override="$(tmux -L "$socket_d" show-window-options -gv window-active-style)"

assert_equals "bg=#101010,fg=#8f8f8f" "$window_style_override" "custom window-style override should win"
assert_equals "bg=#181818,fg=#f0f0f0" "$window_active_style_override" "custom window-active-style override should win"

printf 'window_profile_test: PASS\n'
