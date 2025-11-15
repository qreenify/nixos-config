#!/usr/bin/env bash
# Debug script to show window placement

echo "==================================="
echo "HYPRLAND WINDOW DEBUG INFORMATION"
echo "==================================="
echo

echo "CURRENT ACTIVE WORKSPACE:"
hyprctl activeworkspace | grep -E "workspace ID|on monitor"
echo

echo "MONITORS AND ACTIVE WORKSPACES:"
echo "-----------------------------------"
hyprctl monitors | grep -E "^Monitor|active workspace:"
echo

echo "ALL WINDOWS AND THEIR LOCATIONS:"
echo "-----------------------------------"
hyprctl clients | while IFS= read -r line; do
    # Extract and format window information
    if [[ $line =~ "Window" ]]; then
        echo -e "\n$line"
    elif [[ $line =~ "workspace:" ]] || [[ $line =~ "class:" ]] || [[ $line =~ "title:" ]] || [[ $line =~ "monitor:" ]]; then
        echo "  $line"
    fi
done

echo
echo "WORKSPACE SUMMARY:"
echo "-----------------------------------"
for ws in {1..10}; do
    count=$(hyprctl clients -j | jq "[.[] | select(.workspace.id == $ws)] | length")
    if [[ $count -gt 0 ]]; then
        echo "Workspace $ws: $count window(s)"
        hyprctl clients -j | jq -r ".[] | select(.workspace.id == $ws) | \"  - \" + .class + \": \" + .title[0:50]"
    fi
done

echo
echo "EXPECTED LAYOUT:"
echo "-----------------------------------"
echo "Empty workspaces (Super+1):"
echo "  WS 1: DP-2 (main) - Should be empty"
echo "  WS 2: HDMI-A-1 (top) - Should be empty"
echo "  WS 3: DP-1 (right) - Should be empty"
echo "  WS 4: DP-3 (left) - Should be empty"
echo
echo "App workspaces (Super+2):"
echo "  WS 5: DP-2 - Steam (floating)"
echo "  WS 6: DP-1 - Discord"
echo "  WS 7: DP-3 - Brave PWAs (3 stacked)"
echo "  WS 8: HDMI-A-1 - Zen Browser"

echo
echo "ISSUES DETECTED:"
echo "-----------------------------------"

# Check if Steam is floating
if hyprctl clients -j | jq -e '.[] | select(.class == "steam" or .class == "Steam") | select(.floating == false)' > /dev/null 2>&1; then
    echo "⚠ Steam is not floating!"
fi

# Check if apps are on wrong workspaces
if hyprctl clients -j | jq -e '.[] | select(.workspace.id >= 1 and .workspace.id <= 4) | select(.class != "waybar")' > /dev/null 2>&1; then
    echo "⚠ Apps found on empty workspaces (1-4)!"
    hyprctl clients -j | jq -r '.[] | select(.workspace.id >= 1 and .workspace.id <= 4) | select(.class != "waybar") | "   - WS " + (.workspace.id | tostring) + ": " + .class'
fi

# Check PWA count on workspace 7
pwa_count=$(hyprctl clients -j | jq '[.[] | select(.workspace.id == 7) | select(.class | startswith("brave-"))] | length')
if [[ $pwa_count -ne 3 ]]; then
    echo "⚠ Expected 3 PWAs on workspace 7, found $pwa_count"
fi

echo
echo "==================================="