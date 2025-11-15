#!/usr/bin/env bash
# Simple debug script without jq dependency

echo "==================================="
echo "WINDOW PLACEMENT DEBUG"
echo "==================================="
echo

echo "CURRENT WORKSPACES ON EACH MONITOR:"
hyprctl monitors | grep -A1 "^Monitor\|active workspace"
echo

echo "ALL WINDOWS:"
echo "-----------------------------------"
hyprctl clients | grep -E "class:|title:|workspace:|floating:" | paste - - - - | column -t -s $'\t'
echo

echo "BRAVE PWAs (should be on WS 7):"
echo "-----------------------------------"
hyprctl clients | grep -B2 -A2 "brave-"
echo

echo "STEAM (should be on WS 5, floating):"
echo "-----------------------------------"
hyprctl clients | grep -B2 -A2 -i "steam"
echo

echo "DISCORD (should be on WS 6):"
echo "-----------------------------------"
hyprctl clients | grep -B2 -A2 -i "discord"
echo

echo "ZEN (should be on WS 8):"
echo "-----------------------------------"
hyprctl clients | grep -B2 -A2 "zen-"