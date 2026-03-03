#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SCRIPT="$REPO_ROOT/scripts/git_segment.sh"

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

assert_empty() {
  local actual message
  actual="$1"
  message="$2"

  if [ -n "$actual" ]; then
    printf 'ASSERT FAILED: %s\nExpected empty output\nActual: %s\n' "$message" "$actual" >&2
    exit 1
  fi
}

TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

WORK_REPO="$TMP_DIR/repo"
mkdir -p "$WORK_REPO"
cd "$WORK_REPO"

git init -q
git config user.email "test@example.com"
git config user.name "tmux-cyberpunk tests"
echo "hello" > tracked.txt
git add tracked.txt
git commit -q -m "init"
git checkout -q -b feature/cyberpunk-git

plain_clean="$("$SCRIPT" "$WORK_REPO" "on" "git:" "1" "off" ">" "#000000" "#c5003c" "#f3e600" "#000000" "false")"
assert_equals "#[fg=#f3e600,bg=#c5003c] git:feature/cyberpunk-git " "$plain_clean" "plain git segment formatting"

echo "dirty" >> tracked.txt
plain_dirty="$("$SCRIPT" "$WORK_REPO" "on" "git:" "1" "off" ">" "#000000" "#c5003c" "#f3e600" "#000000" "true")"
assert_equals " #[fg=#f3e600,bg=#c5003c] git:feature/cyberpunk-git* " "$plain_dirty" "plain git segment with dirty marker and static-prefix spacing"

nerd_dirty="$("$SCRIPT" "$WORK_REPO" "on" "git:" "1" "on" ">" "#000000" "#c5003c" "#f3e600" "#55ead4" "true")"
assert_equals "#[fg=#c5003c,bg=#55ead4]>#[fg=#f3e600,bg=#c5003c] git:feature/cyberpunk-git* #[fg=#000000,bg=#c5003c]>" "$nerd_dirty" "nerd-font git segment formatting"

NON_GIT_DIR="$TMP_DIR/non-git"
mkdir -p "$NON_GIT_DIR"
non_git_output="$("$SCRIPT" "$NON_GIT_DIR" "on" "git:" "1" "on" ">" "#000000" "#c5003c" "#f3e600" "#55ead4" "false")"
assert_empty "$non_git_output" "non git directory should return empty git segment"

printf 'git_segment_test: PASS\n'
