# unrarall

A small, defensive shell utility for recursively extracting RAR archives.

## Why This Exists

The original `unrarall` used `file --mime-type` to decide whether a file was a
RAR archive. That is not a reliable archive test: valid RAR files can be
reported as `application/octet-stream` depending on the operating system and
magic database. This version lets the RAR backend validate the archive.

## Requirements

`bash` 4+, `find`, `mktemp`, and one of:

- `unrar` (recommended)
- `rar`
- `7z`

`unrar` is the default because it natively handles traditional `.rar` plus
`.r00`, `.r01` and newer `.part01.rar` multipart sets.

## Usage

```bash
./unrarall ~/Downloads
./unrarall --verbose --clean=all ~/Downloads
./unrarall --dry --verbose ~/Downloads
./unrarall --output ~/Videos ~/Downloads
```

Extraction defaults to the directory containing each archive. Files are first
extracted into a temporary directory and moved only after the backend succeeds.

## Cleanup

No files are deleted by default. `--clean=rar` removes the archive volumes and
matching `.sfv` file after successful extraction. `--clean=all` also removes
common NFO, cover, proof, sample, and operating-system junk files, then empty
directories.

Use `--dry` before cleanup. Cleanup is intentionally limited to the directory
containing the archive.

## Passwords

For encrypted archives, put one password per line in `~/.unrar_passwords`, or
provide another file with `--password-file FILE`. Keep that file private; it is
not part of this project and should never be committed.

## Tests

```bash
tests/test.sh
```

The GitHub Actions workflow runs ShellCheck and the fixture-based test suite on
every push and pull request.
