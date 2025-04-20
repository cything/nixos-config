#!/bin/sh

# https://nix.dev/guides/recipes/post-build-hook.html#implementing-the-build-hook
set -eu
set -f # disable globbing
export IFS=' '
echo "Uploading paths" $OUT_PATHS
exec nix copy --to "s3://nixcache" $OUT_PATHS
