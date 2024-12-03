#!/usr/bin/env bash

focused_workspace=$(hyprctl activeworkspace -j | jq '.id')

kitty_window_count=$(hyprctl clients -j | jq --argjson workspace "$focused_workspace" '[.[] |select(.workspace.id == $workspace and .class == "foot")] |length')

next_session=$((focused_workspace * 10))

if [ "$kitty_window_count" -gt 0 ]
then
  next_session=$((next_session + kitty_window_count))
fi

foot tmux new-session -A -s ${next_session}
