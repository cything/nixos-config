#!/bin/bash

running_app=$(swaymsg -t get_tree | jq -r 'recurse(.nodes[]?) | select(.focused==true) | .app_id')

if [ "$running_app" = "anki" ]; then
  echo "kitty open found 😇"
else
  echo "no kitty 😿"
  echo "but ${running_app}"
fi
