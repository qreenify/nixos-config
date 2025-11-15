# Wonderland NixOS - Custom ISO Creation Guide

This guide explains how to build your own branded "Wonderland NixOS" installation ISO.

## 🎯 What You Get

A custom NixOS installation ISO that includes:
- ✨ **Custom branding** - Wonderland logo, splash screens, and themes
- 🎨 **Pre-configured environment** - Your complete flake setup included
- 🚀 **Automated installer** - One-command installation script
- 📦 **Offline installation** - All packages included on the ISO
- 🔒 **Ready for Secure Boot** - Lanzaboote setup scripts included

## 📁 Project Structure

```
~/.config/nixos/
├── flake.nix                          # Updated with wonderland-iso config
├── iso-config.nix                     # ISO-specific configuration
├── branding/
│   ├── wonderland-splash-bios.png     # BIOS boot splash (640x480)
│   ├── wonderland-splash-efi.png      # EFI boot splash (1920x1080)
│   └── wonderland-logo.png            # Plymouth boot animation logo
├── installer-scripts/
│   └── wonderland-install.sh          # Automated installer
└── ISO-CREATION.md                    # This file
```

## 🚀 Quick Start

### 1. Build the ISO

```bash
cd ~/.config/nixos

# Build the ISO (takes 10-20 minutes)
nix build .#nixosConfigurations.wonderland-iso.config.system.build.isoImage

# Find your ISO
ls -lh result/iso/
```

### 2. Write to USB Drive

```bash
# Find your USB device
lsblk

# Write the ISO (replace /dev/sdX with your USB device)
sudo dd if=result/iso/nixos-*.iso of=/dev/sdX bs=4M status=progress conv=fdatasync
```

⚠️ **Warning**: This will erase all data on the USB drive!

### 3. Test in a VM (Optional)

```bash
# Quick test using QEMU
nix-shell -p qemu --run "qemu-system-x86_64 -enable-kvm -m 4096 -cdrom result/iso/nixos-*.iso"
```

## 🎨 Customizing Your ISO

### Boot Splash Screens

Create custom splash screens in the `branding/` directory:

**BIOS Splash** (`wonderland-splash-bios.png`):
- Resolution: 640x480 pixels
- Format: PNG
- Shows during BIOS boot

**EFI Splash** (`wonderland-splash-efi.png`):
- Resolution: 1920x1080 pixels (or higher)
- Format: PNG
- Shows during UEFI boot

**Logo** (`wonderland-logo.png`):
- Any reasonable size
- Format: PNG with transparency
- Used in Plymouth boot animation

### ISO Label and Edition

Edit `iso-config.nix`:

```nix
isoImage = {
  volumeID = "WONDERLAND-NIXOS";     # ISO volume name (max 32 chars)
  edition = "Wonderland";            # Edition name
  prependToMenuLabel = "Wonderland ";
  appendToMenuLabel = " Edition";
};
```

### Included Packages

Add packages that will be available during installation:

```nix
environment.systemPackages = with pkgs; [
  # Add your preferred tools here
  vim
  neovim
  git
  htop
  # ... etc
];
```

## 📝 Using the ISO

### Installation Methods

#### Interactive Installation

Boot from the ISO and run:

```bash
sudo wonderland-install
```

This launches an interactive installer that will:
1. Prompt for hostname
2. Select installation disk
3. Confirm installation
4. Partition and format disk
5. Install NixOS with your flake configuration
6. Set up passwords
7. Reboot into your new system

#### Manual Installation

For more control:

```bash
# Partition disk manually
sudo gdisk /dev/sda

# Format partitions
mkfs.fat -F 32 /dev/sda1
mkfs.ext4 /dev/sda2

# Mount
mount /dev/sda2 /mnt
mkdir /mnt/boot
mount /dev/sda1 /mnt/boot

# Copy configuration
cp -r /nixos-config /mnt/etc/nixos

# Generate hardware config
nixos-generate-config --root /mnt

# Install
nixos-install --flake /mnt/etc/nixos#nixos
```

## 🔧 Advanced Configuration

### Enable SSH for Remote Installation

Already enabled in `iso-config.nix`. After booting:

```bash
# Set password for remote access
passwd

# Get IP address
ip a

# From another machine:
ssh nixos@<ip-address>
```

### Change Base Image

Edit `iso-config.nix` to use different base:

```nix
imports = [
  # Graphical installer (larger, includes desktop)
  "${nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-graphical-gnome.nix"

  # OR minimal (smaller, text-only)
  # "${nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
];
```

### Adjust ISO Size

For smaller ISOs:

```nix
# Use minimal base
imports = [ "${nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix" ];

# Limit packages
environment.systemPackages = lib.mkForce [ pkgs.vim pkgs.git ];

# Increase compression
isoImage.squashfsCompression = "zstd -Xcompression-level 19";
```

## 📦 Distribution

### Generate Checksums

After building:

```bash
cd result/iso
sha256sum nixos-*.iso > SHA256SUMS

# Optionally sign with GPG
gpg --detach-sign --armor SHA256SUMS
```

### Release Checklist

Before distributing your ISO:

- [ ] Test boot on BIOS system
- [ ] Test boot on UEFI system
- [ ] Test installation on VM
- [ ] Test installation on real hardware
- [ ] Verify all branding displays correctly
- [ ] Test automated installer script
- [ ] Verify post-install system boots
- [ ] Generate checksums
- [ ] Write release notes
- [ ] Tag git release
- [ ] Upload to GitHub releases

### GitHub Releases

1. Tag your release:
```bash
git tag -a v1.0.0 -m "Wonderland NixOS 1.0.0"
git push origin v1.0.0
```

2. Create GitHub release with:
   - ISO file
   - SHA256SUMS
   - Release notes
   - Installation instructions

## 🐛 Troubleshooting

### ISO is too large (>4GB)

- Switch to minimal base installer
- Reduce included packages
- Increase compression level

### Build fails with "file not found"

Make sure all branding files are git-tracked:
```bash
git add branding/
git add installer-scripts/
git commit -m "Add branding assets"
```

### ISO won't boot

Check that boot options are enabled:
```nix
isoImage.makeEfiBootable = true;
isoImage.makeUsbBootable = true;
isoImage.makeBiosBootable = true;
```

### Installer can't find configuration

The configuration is copied to `/nixos-config/` on the ISO. Check:
```bash
ls /nixos-config/
```

## 📚 Additional Resources

- [NixOS Manual - Creating ISOs](https://nixos.org/manual/nixos/stable/#sec-building-cd)
- [nixos-generators](https://github.com/nix-community/nixos-generators)
- [NixOS Wiki - Installation](https://nixos.wiki/wiki/NixOS_Installation_Guide)

## 🎯 Quick Reference

```bash
# Build ISO
nix build .#nixosConfigurations.wonderland-iso.config.system.build.isoImage

# Write to USB
sudo dd if=result/iso/nixos-*.iso of=/dev/sdX bs=4M status=progress

# Test in VM
qemu-system-x86_64 -enable-kvm -m 4096 -cdrom result/iso/nixos-*.iso

# After boot, install
sudo wonderland-install
```

---

**Wonderland NixOS** - Your personal NixOS distribution ✨
