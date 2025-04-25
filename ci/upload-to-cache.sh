#!/bin/sh

# https://nix.dev/guides/recipes/post-build-hook.html#implementing-the-build-hook
set -eu
set -f # disable globbing
export IFS=' '
echo "Uploading paths" $OUT_PATHS

# nix may run before rclone mount is done
if [ -d "/mnt/nixcache" ]; then
	exec /nix/var/nix/profiles/default/bin/nix copy --to "file:///mnt/nixcache&compression=zstd&parallel-compression=true" $OUT_PATHS
else
	echo "WARNING: skipping upload cause /mnt/nixcache does not exist"
fi
