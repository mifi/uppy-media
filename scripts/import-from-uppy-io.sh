#!/usr/bin/env bash
# One-time import of the blog media that uppy.io still uses, from the archived
# transloadit/uppy.io repository, into this repository.
#
# The website (transloadit/uppy, website/) links media as
# https://uppy-io-static.tlcdn.com/static/<path>, so each file is copied to
# <path> here (e.g. img/blog/1.0/foo.png), keeping every URL unchanged.
#
# Usage: scripts/import-from-uppy-io.sh [uppy-git-ref]
#   uppy-git-ref: ref of transloadit/uppy to scan for media URLs (default: main)
set -euo pipefail

UPPY_IO_COMMIT=67dd4198ca2701abdfac87f5a5d491c792f7ea9e
UPPY_REF=${1:-main}
CDN_PREFIX='https://uppy-io-static.tlcdn.com/static/'

repo_root=$(git rev-parse --show-toplevel)
work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT

echo "Scanning transloadit/uppy@$UPPY_REF website/ for media URLs…"
git -c gc.auto=0 clone --quiet --depth 1 --branch "$UPPY_REF" --filter=blob:none --sparse \
  https://github.com/transloadit/uppy "$work/uppy"
git -C "$work/uppy" -c gc.auto=0 sparse-checkout set website
grep -rhoE "${CDN_PREFIX//./\\.}[^\"'() <>]+" "$work/uppy/website" \
  --exclude-dir=node_modules |
  sed "s#^${CDN_PREFIX}##" | sort -u >"$work/paths.txt"
echo "Found $(wc -l <"$work/paths.txt") media paths."

echo "Fetching them from transloadit/uppy.io@${UPPY_IO_COMMIT:0:7}…"
git -c gc.auto=0 clone --quiet --filter=blob:none --no-checkout \
  https://github.com/transloadit/uppy.io "$work/uppy.io"
sed 's#^#static/#' "$work/paths.txt" >"$work/sources.txt"
git -C "$work/uppy.io" -c gc.auto=0 checkout --quiet "$UPPY_IO_COMMIT" \
  --pathspec-from-file="$work/sources.txt"

while IFS= read -r path; do
  mkdir -p "$repo_root/$(dirname "$path")"
  cp "$work/uppy.io/static/$path" "$repo_root/$path"
done <"$work/paths.txt"

missing=0
while IFS= read -r path; do
  [ -f "$repo_root/$path" ] || { echo "MISSING: $path"; missing=1; }
done <"$work/paths.txt"
[ "$missing" = 0 ] || exit 1

echo "Copied $(wc -l <"$work/paths.txt") files ($(du -sh "$repo_root/img" | cut -f1))."
