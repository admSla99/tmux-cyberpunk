#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SCRIPT="$REPO_ROOT/scripts/git_info.sh"

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

clean_output="$("$SCRIPT" "$WORK_REPO" "on" "git:" "on")"
assert_equals "git:feature/cyberpunk-git" "$clean_output" "clean branch output"

echo "dirty" >> tracked.txt
dirty_output="$("$SCRIPT" "$WORK_REPO" "on" "git:" "on")"
assert_equals "git:feature/cyberpunk-git*" "$dirty_output" "dirty marker output"

clean_without_dirty="$("$SCRIPT" "$WORK_REPO" "off" "git:" "on")"
assert_equals "git:feature/cyberpunk-git" "$clean_without_dirty" "dirty marker disabled"

git add tracked.txt
git commit -q -m "cleanup dirty test state"

REMOTE_REPO="$TMP_DIR/remote.git"
git init -q --bare "$REMOTE_REPO"
git remote add origin "$REMOTE_REPO"
git push -q -u origin feature/cyberpunk-git
git --git-dir "$REMOTE_REPO" symbolic-ref HEAD refs/heads/feature/cyberpunk-git

echo "ahead local change" >> tracked.txt
git add tracked.txt
git commit -q -m "ahead commit"

OTHER_REPO="$TMP_DIR/other"
git clone -q "$REMOTE_REPO" "$OTHER_REPO"
cd "$OTHER_REPO"
git config user.email "test@example.com"
git config user.name "tmux-cyberpunk tests"
git checkout -q feature/cyberpunk-git
echo "behind remote change" >> remote.txt
git add remote.txt
git commit -q -m "remote commit"
git push -q

cd "$WORK_REPO"
git fetch -q origin

diverged_output="$("$SCRIPT" "$WORK_REPO" "off" "git:" "on")"
assert_equals "git:feature/cyberpunk-git ↑1 ↓1" "$diverged_output" "ahead/behind markers output"

diverged_without_arrows="$("$SCRIPT" "$WORK_REPO" "off" "git:" "off")"
assert_equals "git:feature/cyberpunk-git" "$diverged_without_arrows" "ahead/behind disabled"

NON_GIT_DIR="$TMP_DIR/non-git"
mkdir -p "$NON_GIT_DIR"
non_git_output="$("$SCRIPT" "$NON_GIT_DIR" "on" "git:" "on")"
assert_empty "$non_git_output" "non git directory should return empty"

printf 'git_info_test: PASS\n'
