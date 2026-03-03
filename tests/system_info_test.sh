#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SCRIPT="$REPO_ROOT/scripts/system_info.sh"

assert_starts_with() {
  local actual prefix message
  actual="$1"
  prefix="$2"
  message="$3"

  case "$actual" in
    "$prefix"*)
      ;;
    *)
      printf 'ASSERT FAILED: %s\nExpected prefix: %s\nActual: %s\n' "$message" "$prefix" "$actual" >&2
      exit 1
      ;;
  esac
}

assert_not_equals() {
  local actual unexpected message
  actual="$1"
  unexpected="$2"
  message="$3"

  if [ "$actual" = "$unexpected" ]; then
    printf 'ASSERT FAILED: %s\nUnexpected value: %s\n' "$message" "$unexpected" >&2
    exit 1
  fi
}

cpu_output="$("$SCRIPT" cpu)"
assert_starts_with "$cpu_output" "CPU " "cpu output format"

memory_output="$("$SCRIPT" memory)"
assert_starts_with "$memory_output" "MEM " "memory output format"

battery_output="$("$SCRIPT" battery)"
assert_starts_with "$battery_output" "BAT " "battery output format"

network_output="$("$SCRIPT" network "1.1.1.1" "200")"
assert_starts_with "$network_output" "NET " "network output format"

if command -v ping >/dev/null 2>&1; then
  network_local_output="$("$SCRIPT" network "127.0.0.1" "500")"
  assert_not_equals "$network_local_output" "NET --" "localhost latency should be available when ping exists"
fi

printf 'system_info_test: PASS\n'
