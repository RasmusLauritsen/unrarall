#!/usr/bin/env bash
set -Eeuo pipefail

ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
SCRIPT=$ROOT/unrarall
TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT

fail() { printf 'FAIL: %s\n' "$*" >&2; exit 1; }
assert_file() { [[ -f $1 ]] || fail "missing file: $1"; }

command -v unrar >/dev/null || { printf 'SKIP: unrar is not installed\n'; exit 0; }
command -v rar >/dev/null || { printf 'SKIP: rar is not installed\n'; exit 0; }

fixture=$TMP/five
mkdir -p "$fixture"

for number in {1..5}; do
  name="file-$number.txt"
  directory=$fixture/$number
  mkdir -p "$directory"
  printf 'payload %s\n' "$number" > "$directory/$name"
  (cd "$directory" && rar a -idq "archive-$number.rar" "$name")
  rm -f "$directory/$name"
done

output=$("$SCRIPT" --backend=unrar --clean=all "$fixture") || fail "unrarall failed: $output"
[[ $output == *"5 archive(s) extracted"* ]] || fail "unexpected output: $output"

for number in {1..5}; do
  name="file-$number.txt"
  directory=$fixture/$number
  assert_file "$directory/$name"
  [[ $(<"$directory/$name") == "payload $number" ]] || fail "wrong contents: $name"
done

printf 'PASS: extracted five archives in one run\n'
