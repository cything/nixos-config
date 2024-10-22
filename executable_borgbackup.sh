#/bin/env bash

export GNUPGHOME=~/.gnupg/trezor
export PASSWORD_STORE_DIR=~/.vault/password-store
export BORG_PASSCOMMAND="pass show borg/ssd"

borg create -sp --list --exclude-caches --exclude-from borgexclude.txt /mnt/veracrypt1/borgrepo::yt-home-{now:%Y-%m-%dT%H:%M} .
