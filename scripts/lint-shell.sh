#!/usr/bin/env bash
set -euo pipefail

# Lint/format gate for repo shell scripts.
# - shellcheck: static analysis
# - shfmt: formatting

# Find shell scripts we own (keep it explicit/simple).
mapfile -t files < <(find scripts -type f -name '*.sh' -print | sort)

if [ "${#files[@]}" -eq 0 ]; then
  echo "no shell scripts found" >&2
  exit 0
fi

echo "shellcheck (${#files[@]} files)" >&2
shellcheck -S warning "${files[@]}"

echo "shfmt check" >&2
shfmt -i 2 -ci -sr -d "${files[@]}"
