#!/usr/bin/env bash
# Properly tile the 3 PWAs on workspace 7

echo "Moving PWAs to workspace 7 and tiling them..."

# Move all PWAs to workspace 7
hyprctl dispatch movetoworkspacesilent "7,class:^(brave-music.apple.com.*)$"
hyprctl dispatch movetoworkspacesilent "7,class:^(brave-.*youtube.*)$"
hyprctl dispatch movetoworkspacesilent "7,class:^(brave-.*twitch.*)$"

# Switch to workspace 7
hyprctl dispatch workspace 7
sleep 1

# Get addresses using grep instead of jq
APPLE=$(hyprctl clients | grep -B1 "brave-music.apple.com" | grep "Window" | awk '{print $2}')
YOUTUBE=$(hyprctl clients | grep -B1 "brave.*youtube" | grep "Window" | awk '{print $2}')
TWITCH=$(hyprctl clients | grep -B1 "brave.*twitch" | grep "Window" | awk '{print $2}')

echo "Found windows:"
echo "  Apple Music: ${APPLE:-Not found}"
echo "  YouTube: ${YOUTUBE:-Found}"
echo "  Twitch: ${TWITCH:-Found}"

# Force dwindle to split vertically (creates horizontal rows)
hyprctl dispatch layoutmsg orientationcenter

# Arrange windows if found
if [ -n "$YOUTUBE" ]; then
    hyprctl dispatch focuswindow "address:$YOUTUBE"
    hyprctl dispatch layoutmsg swapwithmaster  # Put at top
fi

if [ -n "$TWITCH" ]; then
    hyprctl dispatch focuswindow "address:$TWITCH"
    # Will be at bottom automatically
fi

if [ -n "$APPLE" ]; then
    hyprctl dispatch focuswindow "address:$APPLE"
    hyprctl dispatch layoutmsg swapnext  # Put in middle
fi

echo "PWA tiling complete!"