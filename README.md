<div align="center">

# 🚀 NixOS Configuration

### Modern, Modular, and Reproducible NixOS Setup

[![NixOS](https://img.shields.io/badge/NixOS-unstable-blue.svg?style=flat&logo=nixos&logoColor=white)](https://nixos.org)
[![License](https://img.shields.io/github/license/qreenify/nixos-config?style=flat)](LICENSE)
[![Stars](https://img.shields.io/github/stars/qreenify/nixos-config?style=flat)](https://github.com/qreenify/nixos-config/stargazers)

*Clean, flat module structure. Each file does one thing.*

[Features](#-features) • [Quick Start](#-quick-start) • [Installation](#-installation) • [Themes](#-theme-system) • [Documentation](#-documentation)

</div>

## ✨ Features

### 🎨 Theme System
- **13 pre-configured themes** including custom base theme
- One-command theme switching with live reload
- Consistent theming across all applications
- Interactive wallpaper selector with terminal preview

### 🪟 Dual Compositor Support
- **Niri** - Modern scrollable tiling compositor
- **Hyprland** - Popular dynamic tiling Wayland compositor
- Choose at login via Ly display manager
- Fully configured for both with matching keybinds

### 🖥️ Multi-Monitor Ready
- Pre-configured 4-monitor setup with rotation support
- Per-monitor workspace management
- Automatic window placement rules
- NVIDIA optimized with modesetting

### 🛠️ Developer-Friendly
- **Neovim** with comprehensive plugin setup ([guide included](NEOVIM-GUIDE.md))
- **Alacritty** terminal with theme integration
- **Git**, **Docker**, **development tools** pre-installed
- **Nushell** as default shell with custom aliases

### 🔒 Security & Boot
- **Lanzaboote** secure boot (v0.4.2)
- Full disk encryption ready
- **Polkit** and **GNOME Keyring** configured

### 📦 Clean Architecture
- Flat, modular file structure
- Each module does one thing well
- Easy to understand and customize
- Fully reproducible with Nix flakes

### 🎯 Included Applications
- **Browser**: Zen Browser (Firefox-based)
- **Launcher**: Walker with fuzzy search
- **Notifications**: Mako
- **Status Bar**: Waybar with MPRIS support
- **Communication**: Vesktop (Discord)
- **RGB Control**: OpenRGB
- **Media**: Spotify, VLC, OBS

## 📸 Screenshots

> **Note**: Add screenshots here showing:
> - Different themes in action
> - Multi-monitor setup
> - Niri/Hyprland workspaces
> - Terminal with theme

<details>
<summary>Click to see more screenshots</summary>

*Screenshots coming soon! Feel free to contribute your own.*

</details>

## 🚀 Quick Start

```bash
# 1. Clone the repository
git clone https://github.com/qreenify/nixos-config.git ~/.config/nixos

# 2. Copy your hardware configuration
sudo cp /etc/nixos/hardware-configuration.nix ~/.config/nixos/
sudo chown $USER:users ~/.config/nixos/hardware-configuration.nix

# 3. Review and customize (see Installation guide)
nano ~/.config/nixos/modules/packages.nix  # Adjust packages as needed

# 4. Deploy and rebuild
cd ~/.config/nixos
./rebuild.sh

# 5. Reboot and enjoy!
sudo reboot
```

## 🎨 Theme System

Switch themes instantly with zero configuration:

```bash
# Interactive theme browser
theme

# Or directly set a theme
theme tokyo-night
```

### Available Themes
- `base` - Custom black & cyan theme
- `catppuccin` - Soothing pastel dark
- `catppuccin-latte` - Soothing pastel light
- `everforest` - Comfortable green forest
- `flexoki-light` - Organic light theme
- `gruvbox` - Retro groove dark
- `kanagawa` - Dark wave inspired
- `matte-black` - Sleek minimal dark
- `nord` - Arctic bluish palette
- `osaka-jade` - Vibrant jade accents
- `ristretto` - Coffee-inspired warm
- `rose-pine` - All natural pine, faux fur, and a bit of soho vibes
- `tokyo-night` - Clean dark Tokyo night

Themes automatically update:
- Niri/Hyprland colors and borders
- Waybar styling
- Alacritty terminal colors
- Walker launcher
- Ghostty terminal
- Btop system monitor
- GTK/Qt applications
- Vesktop/Discord

## 📁 Structure

```
.
├── flake.nix                      # Main entry point
├── hardware-configuration.nix     # Auto-generated hardware config
│
├── modules/
│   ├── boot.nix                   # Bootloader, kernel, secure boot
│   ├── networking.nix             # Network configuration
│   ├── locale.nix                 # Time zone, keyboard, locales
│   ├── nvidia.nix                 # GPU drivers
│   ├── packages.nix               # ALL system packages
│   ├── users.nix                  # User accounts
│   ├── desktop.nix                # Niri, waybar, desktop environment
│   └── home.nix                   # Home-manager (themes, configs)
│
├── config/                        # Actual config files
│   ├── niri/config.kdl            # Niri compositor
│   ├── waybar/                    # Status bar
│   └── fuzzel/                    # Launcher
│
└── scripts/                       # Helper scripts
    ├── mic-status
    ├── mic-toggle
    └── audio-out-status
```

## What Each Module Does

| File | Contains |
|------|----------|
| `boot.nix` | Bootloader, kernel, Lanzaboote secure boot, Nix settings |
| `networking.nix` | Hostname, NetworkManager |
| `locale.nix` | Time zone, keyboard layout (Swedish), locales |
| `nvidia.nix` | NVIDIA GPU drivers and settings |
| `packages.nix` | **ALL system packages** - add packages here |
| `users.nix` | User accounts and groups |
| `desktop.nix` | Niri, waybar, display manager, security |
| `home.nix` | User configs: niri, waybar, alacritty, dark theme |

## 📦 Installation

For detailed installation instructions including first-time setup, see **[INSTALL.md](INSTALL.md)**.

### TL;DR

```bash
git clone https://github.com/qreenify/nixos-config.git ~/.config/nixos
sudo cp /etc/nixos/hardware-configuration.nix ~/.config/nixos/
sudo chown $USER:users ~/.config/nixos/hardware-configuration.nix
cd ~/.config/nixos && ./rebuild.sh
```

**Important Notes:**
- Review `modules/packages.nix` to customize installed packages
- Update monitor configuration in `config/niri/config.kdl` or `config/hypr/hyprland.conf`
- Check `modules/nvidia.nix` if you have different GPU or no NVIDIA
- Username is `qreenify` by default - change in `modules/users.nix` if needed

## Daily Workflow

```bash
# Edit your configs in ~/.config/nixos (this repo), then:
cd ~/.config/nixos
./rebuild.sh              # Deploy + rebuild (switch mode)

# Or use different modes:
./rebuild.sh boot         # Build, activate on next boot
./rebuild.sh test         # Test without adding boot entry
./rebuild.sh dry-build    # See what would be built

# Manual workflow:
./deploy.sh               # Just deploy to /etc/nixos
sudo nixos-rebuild switch --flake /etc/nixos#nixos
```

## 📚 Learning Neovim

Check out [NEOVIM-GUIDE.md](NEOVIM-GUIDE.md) for:
- Complete keybinding reference
- Learning path from beginner to advanced
- Tips and tricks to improve your workflow
- **Pro tip:** Press `Space` in nvim and wait - which-key will show you available commands!

## How to Modify

### Add a package
Edit `modules/packages.nix`:
```nix
environment.systemPackages = with pkgs; [
  # ... existing packages
  firefox
];
```

### Change keyboard layout
Edit `modules/locale.nix`:
```nix
services.xserver.xkb = {
  layout = "us";  # Change from "se"
  variant = "";
};
```

### Change network hostname
Edit `modules/networking.nix`:
```nix
networking.hostName = "my-new-hostname";
```

### Add another user
Edit `modules/users.nix`:
```nix
users.users.newuser = {
  isNormalUser = true;
  extraGroups = [ "wheel" ];
};
```

### Change niri keybindings
Edit `config/niri/config.kdl` directly

### Customize colors
- Alacritty: `modules/home.nix` (search for `colors`)
- Waybar: `config/waybar/style.css`
- Niri borders: `config/niri/config.kdl` (search for `border`)

## Monitor Setup

Your 4-monitor setup is in `config/niri/config.kdl`:
- **HDMI-A-1**: 1920x1080@60Hz (top)
- **DP-1**: 2560x1440@60Hz rotated 90° (right)
- **DP-2**: 2560x1440@155Hz (main)
- **DP-3**: 2560x1440@60Hz rotated 270° (left)

## Window Auto-Placement

See `config/niri/config.kdl` for window rules:
- Discord → Workspace 1, DP-1
- Brave PWAs → Workspace 1, DP-3
- VSCodium → Workspace 2, DP-2 (maximized)
- Gaming (Steam, Lutris) → Workspace 3
- OBS → Workspace 4

## Key Features

✅ **Simple** - Flat structure, obvious names
✅ **Modular** - Each file does one thing
✅ **Dark mode** - GTK, Qt, Alacritty, Waybar
✅ **4-monitor setup** - Pre-configured with rotation
✅ **Secure boot** - Lanzaboote v0.4.2 (working)
✅ **Home Manager** - Declarative user configs

## Troubleshooting

### Build fails
```bash
cd /etc/nixos
nix flake check  # Validate syntax
```

### Want to disable NVIDIA?
Comment out in `flake.nix`:
```nix
# ./modules/nvidia.nix
```

### Want to test without rebuilding?
```bash
sudo nixos-rebuild test --flake /etc/nixos#nixos
```

## 🔄 How It Works: Deploy & Rebuild Workflow

This configuration uses a **two-location approach** for safety and flexibility:

1. **Source** (`~/.config/nixos`): Your git-tracked, user-owned configuration
2. **System** (`/etc/nixos`): Root-owned files used by NixOS rebuild

### The Workflow

```bash
# Your workflow
~/.config/nixos/rebuild.sh
```

**What happens behind the scenes:**
1. `deploy.sh` copies files from `~/.config/nixos` → `/etc/nixos` (with sudo)
2. `nixos-rebuild switch --flake /etc/nixos#nixos` builds and activates

### Why This Approach?

✅ **Safe git operations**: Commit/push without sudo
✅ **NixOS can write**: `flake.lock` updates work correctly
✅ **Secure**: Root doesn't read from user-writable files
✅ **Clean separation**: Development vs. deployment

## 🤝 Contributing

Contributions are welcome! Here's how you can help:

- **Share screenshots** of your setup
- **Report issues** or bugs you encounter
- **Submit themes** for the theme system
- **Improve documentation**
- **Share your customizations**

Please open an issue or PR on [GitHub](https://github.com/qreenify/nixos-config).

## 📚 Documentation

- **[INSTALL.md](INSTALL.md)** - Detailed installation guide for new machines
- **[NEOVIM-GUIDE.md](NEOVIM-GUIDE.md)** - Complete Neovim keybindings and learning path
- **[MODULAR-README.md](MODULAR-README.md)** - Deep dive into the modular architecture

## 🎓 Learning Resources

New to NixOS? Check these out:

- [Official NixOS Manual](https://nixos.org/manual/nixos/stable/)
- [Nix Flakes Wiki](https://nixos.wiki/wiki/Flakes)
- [Home Manager Manual](https://nix-community.github.io/home-manager/)
- [Niri Compositor](https://github.com/YaLTeR/niri)
- [Hyprland Wiki](https://wiki.hyprland.org/)

## ⚡ Tips & Tricks

### Quick Theme Change
```bash
theme  # Interactive picker with previews
```

### Test Before Committing
```bash
./rebuild.sh test  # Test config without boot entry
./rebuild.sh dry-build  # See what would change
```

### Update Flake Inputs
```bash
cd ~/.config/nixos
nix flake update
./rebuild.sh
```

### Selective Wallpaper
```bash
wallpaper  # Interactive wallpaper picker with preview
```

## 🎯 Customization Examples

### Change Theme Permanently
Edit `modules/home.nix` to set your default theme on login.

### Add New Package
1. Edit `modules/packages.nix`
2. Add package to `environment.systemPackages`
3. Run `./rebuild.sh`

### Customize Keybinds
- **Niri**: Edit `config/niri/config.kdl`
- **Hyprland**: Edit `config/hypr/hyprland.conf`

### Create New Theme
1. Create directory: `theme/themes/my-theme/`
2. Add theme files (see existing themes for reference)
3. Run `./rebuild.sh` to deploy
4. Switch with `theme my-theme`

## 🐛 Troubleshooting

### Build Fails

```bash
cd ~/.config/nixos
nix flake check  # Validate flake syntax
```

### Wallpaper Selector Shows "Preview not available"

Make sure `chafa` is installed:
```bash
# Should be in modules/packages.nix already
which chafa
```

### Theme Not Applying

```bash
# Check theme symlink
readlink ~/.config/theme/current/theme

# Ensure scripts are in PATH
echo $PATH | grep theme

# Log out and back in after rebuild
```

### Dual Monitor/Compositor Issues

- Niri: `journalctl --user -u niri -b`
- Hyprland: Check `~/.hyprland.log`
- Display: `journalctl -b | grep -i nvidia`

## 📝 License

This configuration is free to use and modify. See [LICENSE](LICENSE) for details.

## 💖 Acknowledgments

- [NixOS](https://nixos.org/) - The reproducible Linux distribution
- [Home Manager](https://github.com/nix-community/home-manager) - Declarative dotfile management
- [Niri](https://github.com/YaLTeR/niri) - Scrollable-tiling Wayland compositor
- [Hyprland](https://hyprland.org/) - Dynamic tiling Wayland compositor
- All the theme creators whose work inspired the themes

---

<div align="center">

**[⬆ Back to Top](#-nixos-configuration)**

Made with ❤️ and Nix

</div>
