#!/usr/bin/env bash
# Switch all monitors to app workspaces (5-8)

hyprctl dispatch workspace 5  # DP-2 to workspace 5 (Steam)
hyprctl dispatch focusmonitor DP-1
hyprctl dispatch workspace 6  # DP-1 to workspace 6 (Discord)
hyprctl dispatch focusmonitor DP-3
hyprctl dispatch workspace 7  # DP-3 to workspace 7 (PWAs)
hyprctl dispatch focusmonitor HDMI-A-1
hyprctl dispatch workspace 8  # HDMI-A-1 to workspace 8 (Zen)
hyprctl dispatch focusmonitor DP-2  # Return focus to main monitor