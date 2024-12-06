#!/usr/bin/env bash

active_window=$(swaymsg -t get_tree |jq -r '..|try select(.focused == true) |.app_id')

if [ "$1" = "btn1" ]; then
  if [ "$active_window" = "anki" ]; then
    wtype " "
  elif [ "$active_window" = "foot" ]; then
    wtype -M ctrl -M shift -k c
    wtype -m ctrl
  else
    wtype -M ctrl -k c
    wtype -m ctrl
  fi
else
  if [ "$active_window" = "anki" ]; then
    wtype "1"
  elif [ "$active_window" = "foot" ]; then
    wtype -M ctrl -M shift -k v
    wtype -m ctrl
  else
    wtype -M ctrl -k v
    wtype -m ctrl
  fi
fi
