#!/usr/bin/env bash
# Switch all monitors to empty workspaces (1-4)

hyprctl dispatch workspace 1  # DP-2 to workspace 1
hyprctl dispatch focusmonitor DP-1
hyprctl dispatch workspace 3  # DP-1 to workspace 3
hyprctl dispatch focusmonitor DP-3
hyprctl dispatch workspace 4  # DP-3 to workspace 4
hyprctl dispatch focusmonitor HDMI-A-1
hyprctl dispatch workspace 2  # HDMI-A-1 to workspace 2
hyprctl dispatch focusmonitor DP-2  # Return focus to main monitor