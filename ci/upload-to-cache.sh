#!/bin/sh

# https://nix.dev/guides/recipes/post-build-hook.html#implementing-the-build-hook
set -eu
set -f # disable globbing
export IFS=' '
echo "Uploading paths" $OUT_PATHS
exec /nix/var/nix/profiles/default/bin/nix copy --to "s3://nixcache?endpoint=s3.cy7.sh&compression=zstd" $OUT_PATHS
