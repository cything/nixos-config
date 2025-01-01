#!/usr/bin/env bash

focused_workspace=$(swaymsg -t get_workspaces | jq '.[] | select(.focused == true) | .num')

foot_window_count=$(swaymsg -t get_tree | jq --argjson workspace "$focused_workspace" '[recurse(.nodes[]?) | select(.type == "workspace" and .num == $workspace) | recurse(.nodes[]?) | select(.app_id == "foot")] | length')

next_session=$((focused_workspace * 10))

if [ "$foot_window_count" -gt 0 ]
then
  next_session=$((next_session + foot_window_count))
fi

foot tmux new-session -A -s ${next_session}
