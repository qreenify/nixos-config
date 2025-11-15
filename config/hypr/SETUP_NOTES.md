# Hyprland Setup Summary

## What Works ✅
- Workspace 1-4: Empty on login
- Workspace 5-8: Apps in background
- Super+1: Switch to empty
- Super+2: Switch to apps
- Discord, YouTube, Twitch work

## Known Issues ⚠️

### 1. Apple Music PWA
Try using direct URL instead:
```bash
brave --new-window --app=https://beta.music.apple.com
```

### 2. PWA Tiling
Dwindle doesn't easily do 3 horizontal rows. Options:
- Use manual tiling with Super+Shift+WASD to arrange
- Try master layout instead of dwindle for workspace 7
- Accept side-by-side layout instead of stacked

### 3. Discord Path
Already fixed - uses:
```bash
flatpak run com.discordapp.Discord
```

## Manual Fixes After Login

If PWAs aren't properly tiled on workspace 7:
1. Press Super+2 to see apps
2. Focus workspace 7 (left monitor)
3. Use Super+Shift+WASD to manually arrange the 3 PWAs

## Test Commands

```bash
# Test full setup
~/.config/hypr/scripts/test-setup.sh

# Just test PWA tiling
~/.config/hypr/scripts/tile-pwas.sh

# Debug window placement
~/.config/hypr/scripts/debug-simple.sh
```

## Files Created
- `/home/qreenify/.config/hypr/workspace-rules.conf` - Window placement rules
- `/home/qreenify/.config/hypr/keybinds.conf` - Keybindings
- `/home/qreenify/.config/hypr/scripts/autostart.sh` - Startup script
- `/home/qreenify/.config/hypr/scripts/show-empty.sh` - Switch to workspaces 1-4
- `/home/qreenify/.config/hypr/scripts/show-apps.sh` - Switch to workspaces 5-8
- `/home/qreenify/.config/hypr/scripts/tile-pwas.sh` - Arrange PWAs
- `/home/qreenify/.config/hypr/scripts/debug-simple.sh` - Debug tool