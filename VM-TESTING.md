# VM Testing Guide

This configuration includes a VM setup for testing the flake without affecting your main system.

## Quick Start

```bash
# Build and run the VM
./vm-test.sh
```

## Manual Build

```bash
# Build the VM
nix build .#nixosConfigurations.nixos-vm.config.system.build.vm

# Run the VM
./result/bin/run-nixos-vm
```

## VM Specs

- **Username**: qreenify
- **Password**: test
- **RAM**: 4GB
- **CPU Cores**: 4
- **Disk**: 20GB
- **Graphics**: Enabled with virtio + OpenGL

## What's Included

The VM includes:
- ✅ Hyprland/Niri window managers
- ✅ Home Manager with your dotfiles
- ✅ Theme system (all 20+ themes)
- ✅ Walker launcher, Waybar, Mako, etc.
- ✅ All custom scripts
- ❌ Nvidia drivers (uses software rendering)
- ❌ Lanzaboote (uses systemd-boot)
- ❌ Hardware-specific mounts

## Testing Themes

Once the VM boots:

```bash
# Switch themes
theme dracula
theme pulsar-theme
theme catppuccin

# Select wallpapers
wallpaper

# Launch walker
walker
```

## Cleanup

The VM creates a disk image file. To clean up:

```bash
# Remove VM build result
rm -f result

# Remove VM disk image
rm -f nixos.qcow2
```

## Tips

- The VM uses software rendering (no GPU acceleration)
- First boot may take a few minutes to set up
- VM state persists in `nixos.qcow2` - delete it to reset
- Press Ctrl+Alt+G to release mouse from VM window
- Use `sudo poweroff` inside VM to shut down gracefully
