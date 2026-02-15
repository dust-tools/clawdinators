#!/usr/bin/env bash
set -euo pipefail

source_dir="${1:-}"
bucket="${2:-}"
dest_prefix="${3:-}"
state_dir="${4:-}"

if [ -z "$source_dir" ] || [ -z "$bucket" ] || [ -z "$state_dir" ]; then
  echo "Usage: sync-public-s3-tree.sh <source_dir> <bucket> <dest_prefix> <state_dir>" >&2
  exit 2
fi

# Normalize prefix: allow empty or trailing slash.
if [ -n "$dest_prefix" ] && [[ "$dest_prefix" != */ ]]; then
  dest_prefix="${dest_prefix}/"
fi

if [ ! -d "$source_dir" ]; then
  echo "sync-public-s3-tree: source dir missing; nothing to do: $source_dir" >&2
  exit 0
fi

mkdir -p "$state_dir"

lock_file="$state_dir/sync.lock"
stamp_file="$state_dir/last-success.stamp"

if [ ! -f "$stamp_file" ]; then
  # Epoch-ish, so first run uploads everything.
  touch -t 197001010000 "$stamp_file"
fi

exec 9> "$lock_file"
if ! flock -n 9; then
  # Another run is in progress.
  exit 0
fi

# Mark the start time; anything modified after this will be picked up next run.
run_stamp="$state_dir/run.stamp"
touch "$run_stamp"

# Find files newer than the last successful run, but not newer than this run's start.
# (Prevents missing files that are created/modified during the upload.)
mapfile -d '' files < <(find "$source_dir" -type f -newer "$stamp_file" ! -newer "$run_stamp" -print0)

if [ "${#files[@]}" -eq 0 ]; then
  # Nothing to upload; still advance the stamp.
  mv -f "$run_stamp" "$stamp_file"
  exit 0
fi

for f in "${files[@]}"; do
  rel="${f#"$source_dir"/}"
  if [ "$rel" = "$f" ]; then
    # Shouldn't happen, but be safe.
    echo "sync-public-s3-tree: failed to compute relative path for $f" >&2
    exit 1
  fi

  # Use path-style keys; preserve directory structure.
  dst="s3://${bucket}/${dest_prefix}${rel}"

  # Overwrite is allowed (iteration mode). No deletes.
  aws s3 cp \
    --only-show-errors \
    --no-progress \
    "$f" \
    "$dst"
done

mv -f "$run_stamp" "$stamp_file"
