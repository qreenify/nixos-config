#!/usr/bin/env bash
# Test the complete setup

echo "==================================="
echo "TESTING HYPRLAND WORKSPACE SETUP"
echo "==================================="
echo

# Kill all test apps first
echo "Cleaning up existing apps..."
pkill steam || true
pkill discord || true
pkill zen || true
pkill brave || true
sleep 2

echo "Starting apps in background..."
# Start apps like autostart would
steam &
sleep 2
flatpak run com.discordapp.Discord &
sleep 3
zen &
sleep 2
brave --new-window --app=https://music.apple.com &
sleep 3
brave --new-window --app=https://youtube.com &
sleep 2
brave --new-window --app=https://twitch.tv &
sleep 3

echo
echo "Moving windows to correct workspaces..."
# Force windows to correct workspaces (escape special chars)
hyprctl dispatch movetoworkspacesilent "5,class:^(steam)$"
hyprctl dispatch movetoworkspacesilent "5,class:^(Steam)$"
hyprctl dispatch movetoworkspacesilent "6,class:^(discord)$"
hyprctl dispatch movetoworkspacesilent "6,class:^(Discord)$"
hyprctl dispatch movetoworkspacesilent "8,class:^(zen-beta)$"
hyprctl dispatch movetoworkspacesilent "7,class:^(brave-music.apple.com.*)$"
hyprctl dispatch movetoworkspacesilent "7,class:^(brave-.*youtube.*)$"
hyprctl dispatch movetoworkspacesilent "7,class:^(brave-.*twitch.*)$"

sleep 2

echo
echo "SWITCHING TO EMPTY WORKSPACES (Super+1)..."
~/.config/hypr/scripts/show-empty.sh
sleep 2

echo "Current view (should be empty):"
echo "-----------------------------------"
for monitor in DP-2 HDMI-A-1 DP-1 DP-3; do
    ws=$(hyprctl monitors | grep -A3 "^Monitor $monitor" | grep "active workspace:" | cut -d' ' -f3)
    echo "$monitor: Workspace $ws"
done

echo
echo "SWITCHING TO APP WORKSPACES (Super+2)..."
~/.config/hypr/scripts/show-apps.sh
sleep 2

echo "Current view (should show apps):"
echo "-----------------------------------"
for monitor in DP-2 HDMI-A-1 DP-1 DP-3; do
    ws=$(hyprctl monitors | grep -A3 "^Monitor $monitor" | grep "active workspace:" | cut -d' ' -f3)
    echo "$monitor: Workspace $ws"
done

echo
echo "FINAL WINDOW PLACEMENT:"
echo "-----------------------------------"
echo "WS 5 (DP-2/Main):"
hyprctl clients | grep -A1 "workspace: 5" | grep "class:" | sed 's/.*class: /  - /'

echo "WS 6 (DP-1/Right):"
hyprctl clients | grep -A1 "workspace: 6" | grep "class:" | sed 's/.*class: /  - /'

echo "WS 7 (DP-3/Left):"
hyprctl clients | grep -A1 "workspace: 7" | grep "class:" | sed 's/.*class: /  - /'

echo "WS 8 (HDMI-A-1/Top):"
hyprctl clients | grep -A1 "workspace: 8" | grep "class:" | sed 's/.*class: /  - /'

echo
echo "==================================="
echo "TEST COMPLETE!"
echo "Use Super+1 for empty workspaces"
echo "Use Super+2 for app workspaces"
echo "==================================="