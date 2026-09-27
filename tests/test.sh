#!/usr/bin/env bash
set -Eeuo pipefail
ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
SCRIPT=$ROOT/unrarall
TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT

fail() { printf 'FAIL: %s\n' "$*" >&2; exit 1; }
assert_file() { [[ -f $1 ]] || fail "missing file: $1"; }
assert_absent() { [[ ! -e $1 ]] || fail "unexpected path: $1"; }

command -v unrar >/dev/null || { printf 'SKIP: unrar is not installed\n'; exit 0; }
command -v rar >/dev/null || { printf 'SKIP: rar is not installed\n'; exit 0; }

fixture=$TMP/"Movie With Spaces"
mkdir -p "$fixture/Covers" "$fixture/Sample"

printf 'test payload\n' > "$fixture/Movie With Spaces.txt"
(cd "$fixture" && rar a -idq archive.rar "Movie With Spaces.txt")
rm -f "$fixture/Movie With Spaces.txt"

"$SCRIPT" --backend=unrar "$fixture" >/dev/null
assert_file "$fixture/Movie With Spaces.txt"

rm -f "$fixture/Movie With Spaces.txt"
"$SCRIPT" --dry --clean=all "$fixture" >/dev/null
assert_absent "$fixture/Movie With Spaces.txt"

"$SCRIPT" --clean=all "$fixture" >/dev/null
assert_file "$fixture/Movie With Spaces.txt"
assert_absent "$fixture/Movie With Spaces.nfo"
assert_absent "$fixture/Covers"
assert_absent "$fixture/Sample"
assert_file "$fixture/archive.rar"

printf 'PASS: archive discovery, multipart extraction, dry-run, and cleanup\n'
