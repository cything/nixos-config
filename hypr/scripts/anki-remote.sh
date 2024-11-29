#!/usr/bin/env bash

active_window=$(hyprctl activewindow -j | jq -r ".class")

if [ "$active_window" = "anki" ]; then
  if [ "$1" = "space" ]; then
    wtype " "
  else
    wtype "1"
  fi
fi
