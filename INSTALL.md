# NixOS Installation Guide

This guide will help you set up your complete NixOS configuration on a new machine, including Hyprland, omarchy themes, and all customizations.

## What's Included

This flake provides a complete NixOS system with:

- **Window Manager**: Hyprland with 4-monitor NVIDIA support
- **Display Manager**: Ly (TUI greeter)
- **Theme System**: Omarchy with 13 pre-configured themes including custom "base" theme
- **Status Bar**: Waybar with per-monitor workspaces, media player, hidden tray
- **Applications**: Walker launcher, Mako notifications, Alacritty terminal, Vesktop
- **Security**: Lanzaboote secure boot
- **NVIDIA**: RTX 4080 optimized configuration with modesetting
- **Shell**: Nushell with custom aliases
- **RGB**: OpenRGB support for motherboard/GPU lighting
- **Cursor**: Bibata Modern Classic

## Prerequisites

1. **Fresh NixOS installation** with:
   - Secure boot set up (for Lanzaboote)
   - Git installed: `nix-shell -p git`
   - NVIDIA GPU (or modify nvidia.nix for other GPUs)

## Installation Steps

### 1. Clone Configuration

```bash
# Clone your NixOS configuration
git clone <YOUR_REPO_URL> ~/.config/nixos

# Or if setting up from backup:
# cp -r /path/to/backup ~/.config/nixos
```

### 2. Copy Hardware Configuration

Your new machine will have different hardware, so you need to copy its hardware config:

```bash
# Copy the auto-generated hardware configuration from /etc/nixos/
sudo cp /etc/nixos/hardware-configuration.nix ~/.config/nixos/

# Make it writable
sudo chown $USER:users ~/.config/nixos/hardware-configuration.nix
```

### 3. Review and Customize

Before building, review these files and customize for your machine:

#### Monitor Setup
Edit `~/.config/nixos/config/hypr/hyprland.conf` around line 34-50:
```conf
# Update monitor configuration for your displays
monitor = DP-2,2560x1440@155,0x0,1
monitor = HDMI-A-1,1920x1080@60,2560x0,1
# ... adjust for your setup
```

#### NVIDIA Configuration (if different GPU)
Edit `~/.config/nixos/modules/nvidia.nix` if you have a different NVIDIA card or no NVIDIA at all.

#### User Settings
- Username is "qreenify" - if you want a different username, update `modules/users.nix`
- Hostname is "wondernixlandos" - change in main configuration if desired

### 4. Deploy and Build

```bash
# Make scripts executable
chmod +x ~/.config/nixos/deploy.sh
chmod +x ~/.config/nixos/rebuild.sh

# Deploy configuration to /etc/nixos and rebuild
~/.config/nixos/rebuild.sh
```

The `rebuild.sh` script will:
1. Run `deploy.sh` to copy configs from ~/.config/nixos to /etc/nixos
2. Run `nixos-rebuild switch --flake /etc/nixos#nixos`

### 5. Reboot

After successful build:
```bash
sudo reboot
```

You should now boot into:
- Ly greeter (TUI login)
- Hyprland window manager
- Your configured multi-monitor setup
- Omarchy theme system ready to use

### 6. Post-Install

After logging in:

#### Select Theme
```bash
# Browse and select a theme
theme

# Or directly set a theme
~/.local/share/omarchy/bin/omarchy-theme-set base
```

#### Verify Setup
```bash
# Check if all monitors are detected
hyprctl monitors

# Check waybar is running
pgrep waybar

# Test walker launcher
SUPER + Space (or your configured keybind)
```

## File Structure

```
~/.config/nixos/
├── flake.nix              # Main flake configuration
├── hardware-configuration.nix  # Machine-specific (you copy this)
├── deploy.sh              # Deploys config to /etc/nixos
├── rebuild.sh             # Builds the system
├── modules/               # NixOS modules
│   ├── boot.nix          # Lanzaboote secure boot
│   ├── desktop.nix       # Desktop environment (Hyprland, Ly)
│   ├── home.nix          # Home-manager configuration
│   ├── nvidia.nix        # NVIDIA drivers
│   ├── packages.nix      # System packages
│   └── ...
├── config/                # Application configs
│   ├── hypr/             # Hyprland configuration
│   └── waybar/           # Waybar configuration
├── scripts/               # Utility scripts (deployed to ~/.script)
└── omarchy/               # Theme system
    ├── bin/              # 132 omarchy scripts
    ├── themes/           # 13 pre-configured themes
    ├── config/           # Default configs
    └── default/          # Default files
```

## Updating Configuration

After making changes:

```bash
# Quick rebuild
rebuild

# Or full process
cd ~/.config/nixos
./deploy.sh
sudo nixos-rebuild switch --flake /etc/nixos#nixos
```

## Theming

All themes are declaratively managed. To add a new theme:

1. Create directory in `~/.config/nixos/omarchy/themes/your-theme-name/`
2. Add theme files (walker.css, waybar.css, hyprland.conf, etc.)
3. Rebuild to deploy
4. Select with `theme` command

Your custom "base" theme is already included with your current colors:
- Background: #000000 (pure black)
- Foreground: #888888 (gray)
- Accent: #00D4AA (cyan)
- Border: #33ccff (cyan gradient)

## Troubleshooting

### Display Issues
- Check `journalctl -b` for NVIDIA errors
- Ensure `nvidia-drm.modeset=1` in kernel params (already configured)
- Verify monitors with `hyprctl monitors`

### Waybar Duplicates
- Already fixed with `systemd.enable = false` in home.nix
- Waybar is started by Hyprland autostart.sh

### Theme Not Working
- Ensure symlink exists: `readlink ~/.config/omarchy/current/theme`
- Check scripts are in PATH: `echo $PATH | grep omarchy`
- After rebuild, log out and back in for PATH changes

### Omarchy Scripts Not Found
- Rebuild to deploy scripts to `~/.local/share/omarchy/bin/`
- Log out and log back in (PATH updated by home-manager)

## Key Keybindings

(From Hyprland config)
- `SUPER + Q`: Close window
- `SUPER + Space`: Walker launcher
- `SUPER + Return`: Terminal
- `SUPER + 1-9`: Switch workspace
- `SUPER + F`: Toggle fullscreen
- `SUPER + M`: Omarchy menu

## Notes

- **Shell**: Uses Nushell (use `;` not `&&` for command chaining)
- **Flake name**: System is called "nixos" in flake (used in rebuild commands)
- **Hardware config**: NOT committed to git (machine-specific)
- **Secure boot**: Lanzaboote manages EFI entries automatically
- **Themes**: Fully declarative, no manual setup required
- **RGB**: OpenRGB auto-configured for motherboard/GPU

## Repository Structure

This configuration is fully git-managed and reproducible:
- Clone repo → Copy hardware-configuration.nix → Rebuild → Done!
- No manual file copying or imperative setup steps required
- All themes, scripts, and configs are self-contained

## Support

See the main README.md for more detailed information about:
- Module organization
- Neovim setup
- Advanced customization
- Contributing

---

**Installation verified on**: NixOS 25.11 (unstable)
**Last updated**: 2025-11-15
