#!/usr/bin/env bash
set -e

# Wonderland NixOS Automated Installer
# Interactive installation script for your custom NixOS configuration

echo "╔═══════════════════════════════════════════════════╗"
echo "║                                                   ║"
echo "║      Welcome to Wonderland NixOS Installer!      ║"
echo "║                                                   ║"
echo "╚═══════════════════════════════════════════════════╝"
echo ""
echo "This script will guide you through installing"
echo "Wonderland NixOS with your custom configuration."
echo ""

# Check if running as root
if [ "$EUID" -ne 0 ]; then
  echo "❌ Error: Please run as root"
  echo "   Use: sudo wonderland-install"
  exit 1
fi

# Check if configuration exists
if [ ! -d "/nixos-config" ]; then
  echo "❌ Error: Configuration not found at /nixos-config"
  echo "   The ISO may be corrupted or incomplete."
  exit 1
fi

echo "📋 Step 1: System Configuration"
echo "─────────────────────────────────"
echo ""

# Get hostname
read -p "Enter hostname for this system [wonderland]: " TARGET_HOST
TARGET_HOST=${TARGET_HOST:-wonderland}
echo "✓ Hostname: $TARGET_HOST"
echo ""

# Display available disks
echo "📀 Available disks:"
lsblk -dpno NAME,SIZE,MODEL | grep -v loop
echo ""

# Get installation disk
read -p "Enter installation disk (e.g., /dev/sda): " INSTALL_DISK

# Validate disk exists
if [ ! -b "$INSTALL_DISK" ]; then
  echo "❌ Error: $INSTALL_DISK is not a valid block device"
  exit 1
fi

echo ""
echo "⚠️  WARNING ⚠️"
echo "This will ERASE ALL DATA on $INSTALL_DISK!"
echo ""
lsblk "$INSTALL_DISK"
echo ""
read -p "Type 'yes' to confirm and proceed: " CONFIRM

if [ "$CONFIRM" != "yes" ]; then
  echo "Installation cancelled."
  exit 0
fi

echo ""
echo "🔧 Step 2: Disk Partitioning"
echo "─────────────────────────────────"
echo ""

# Create GPT partition table
echo "Creating partition table..."
parted "$INSTALL_DISK" -- mklabel gpt

# Create EFI partition (512MB)
echo "Creating EFI partition (512MB)..."
parted "$INSTALL_DISK" -- mkpart ESP fat32 1MiB 512MiB
parted "$INSTALL_DISK" -- set 1 esp on

# Create root partition (rest of disk)
echo "Creating root partition..."
parted "$INSTALL_DISK" -- mkpart primary 512MiB 100%

echo "✓ Partitioning complete"
echo ""

# Determine partition names
if [[ "$INSTALL_DISK" =~ "nvme" ]] || [[ "$INSTALL_DISK" =~ "mmcblk" ]]; then
  BOOT_PART="${INSTALL_DISK}p1"
  ROOT_PART="${INSTALL_DISK}p2"
else
  BOOT_PART="${INSTALL_DISK}1"
  ROOT_PART="${INSTALL_DISK}2"
fi

echo "💾 Step 3: Formatting Filesystems"
echo "─────────────────────────────────"
echo ""

# Format partitions
echo "Formatting EFI partition..."
mkfs.fat -F 32 -n BOOT "$BOOT_PART"

echo "Formatting root partition..."
mkfs.ext4 -L nixos "$ROOT_PART"

echo "✓ Formatting complete"
echo ""

echo "📁 Step 4: Mounting Filesystems"
echo "─────────────────────────────────"
echo ""

# Mount filesystems
mount "$ROOT_PART" /mnt
mkdir -p /mnt/boot
mount "$BOOT_PART" /mnt/boot

echo "✓ Filesystems mounted"
echo ""

echo "📦 Step 5: Installing Configuration"
echo "─────────────────────────────────"
echo ""

# Copy configuration
echo "Copying Wonderland NixOS configuration..."
mkdir -p /mnt/etc/nixos
cp -r /nixos-config/* /mnt/etc/nixos/

# Generate hardware configuration
echo "Generating hardware configuration..."
nixos-generate-config --root /mnt

echo "✓ Configuration ready"
echo ""

echo "🚀 Step 6: Installing NixOS"
echo "─────────────────────────────────"
echo ""
echo "This may take 15-30 minutes depending on your hardware..."
echo ""

# Install NixOS using the flake
if nixos-install --flake "/mnt/etc/nixos#nixos" --no-root-passwd; then
  echo ""
  echo "✓ NixOS installation successful!"
else
  echo ""
  echo "❌ Installation failed. Check the error messages above."
  exit 1
fi

echo ""
echo "🔐 Step 7: Set Root Password"
echo "─────────────────────────────────"
echo ""

# Set root password
nixos-enter --root /mnt -c 'passwd root'

echo ""
echo "╔═══════════════════════════════════════════════════╗"
echo "║                                                   ║"
echo "║    ✨ Wonderland NixOS Installation Complete! ✨   ║"
echo "║                                                   ║"
echo "║  Your system is ready. You can now reboot.       ║"
echo "║                                                   ║"
echo "║  Next steps after reboot:                        ║"
echo "║  1. Log in as root                               ║"
echo "║  2. Set password for qreenify user:              ║"
echo "║     passwd qreenify                              ║"
echo "║  3. Enjoy your Wonderland NixOS! 🎨              ║"
echo "║                                                   ║"
echo "╚═══════════════════════════════════════════════════╝"
echo ""

read -p "Reboot now? (yes/no) [yes]: " REBOOT
REBOOT=${REBOOT:-yes}

if [ "$REBOOT" = "yes" ]; then
  echo "Rebooting in 3 seconds..."
  sleep 3
  reboot
else
  echo "Installation complete. Reboot when ready."
fi
