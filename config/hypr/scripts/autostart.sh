#!/usr/bin/env bash
# Autostart apps with forced placement

# Wait for Hyprland to be fully ready
sleep 2

# Start 2 terminals in special:claude workspace (silent) in ~/claude directory
alacritty --working-directory ~/claude &
sleep 0.5
hyprctl dispatch movetoworkspacesilent special:claude

alacritty --working-directory ~/claude &
sleep 0.5
hyprctl dispatch movetoworkspacesilent special:claude

# Start Vesktop on workspace 9 (right monitor)
vesktop &
sleep 3

# Start Zen on workspace 8 (top monitor)
zen &
sleep 2
hyprctl dispatch movetoworkspacesilent 8,class:^(zen)

# Focus workspace 1 on main monitor (default view)
hyprctl dispatch workspace 1

echo "Autostart complete. Press Super+C for Claude terminals."
