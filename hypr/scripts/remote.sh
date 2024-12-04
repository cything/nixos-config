#!/usr/bin/env bash

active_window=$(hyprctl activewindow -j | jq -r ".class")

if [ "$active_window" = "anki" ]; then
  if [ "$1" = "space" ]; then
    wtype " "
  else
    wtype "1"
  fi
else
  if [ "$1" = "space" ]; then
    wtype -M ctrl -k c
  else
    wtype -M ctrl -k v
  fi
fi
