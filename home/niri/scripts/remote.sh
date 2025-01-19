#!/usr/bin/env bash

active_window=$(niri msg --json focused-window |jq -r .app_id)

if [ "$1" = "btn1" ]; then
  if [ "$active_window" = "anki" ]; then
    wtype " "
  elif [ "$active_window" = "foot" ]; then
    wtype -M ctrl -M shift -k c -m ctrl -m shift
  elif [ "$active_window" = "chromium-browser" ] || [ "$active_window" = "librewolf" ]; then
    wtype -M alt -P right -p right -m alt
  else
    wtype -M ctrl -k c -m ctrl
  fi
else
  if [ "$active_window" = "anki" ]; then
    wtype "1"
  elif [ "$active_window" = "foot" ]; then
    wtype -M ctrl -M shift -k v -m ctrl
  elif [ "$active_window" = "chromium-browser" ] || [ "$active_window" = "librewolf" ]; then
    wtype -M alt -P left -p left -m alt
  else
    wtype -M ctrl -k v -m ctrl
  fi
fi
