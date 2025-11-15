#!/usr/bin/env bash
# Script to set up symlinks from /etc/nixos to ~/.config/nixos
# Run with: sudo ~/.config/nixos/setup-symlinks.sh

set -e

USER_HOME="/home/qreenify"
USER_NIXOS="$USER_HOME/.config/nixos"
SYSTEM_NIXOS="/etc/nixos"

echo "🔧 Setting up NixOS configuration symlinks..."
echo ""

# Step 1: Copy system-specific files to user directory if they don't exist there
echo "📋 Step 1: Copying system files to $USER_NIXOS..."

for file in configuration.nix hardware-configuration.nix flake.lock; do
  if [[ ! -f "$USER_NIXOS/$file" ]] && [[ -f "$SYSTEM_NIXOS/$file" ]]; then
    echo "  Copying $file..."
    cp "$SYSTEM_NIXOS/$file" "$USER_NIXOS/$file"
    chown qreenify:users "$USER_NIXOS/$file"
  else
    echo "  ✓ $file already exists in user config"
  fi
done

echo ""

# Step 2: Backup current /etc/nixos
echo "📦 Step 2: Creating backup of /etc/nixos..."
BACKUP_DIR="/etc/nixos.backup.$(date +%Y%m%d-%H%M%S)"
cp -r "$SYSTEM_NIXOS" "$BACKUP_DIR"
echo "  ✓ Backup created at $BACKUP_DIR"
echo ""

# Step 3: Remove old files in /etc/nixos (keep only what we'll symlink)
echo "🗑️  Step 3: Cleaning /etc/nixos..."
rm -rf "$SYSTEM_NIXOS"/*
echo "  ✓ Cleaned"
echo ""

# Step 4: Create symlinks
echo "🔗 Step 4: Creating symlinks..."

# Symlink all relevant files and directories
for item in flake.nix flake.lock configuration.nix hardware-configuration.nix home.nix \
            modules scripts config omarchy deploy.sh rebuild.sh; do
  if [[ -e "$USER_NIXOS/$item" ]]; then
    echo "  Linking $item..."
    ln -sf "$USER_NIXOS/$item" "$SYSTEM_NIXOS/$item"
  fi
done

echo ""
echo "✅ Setup complete!"
echo ""
echo "Summary:"
echo "  - Backup: $BACKUP_DIR"
echo "  - Source: $USER_NIXOS"
echo "  - System: $SYSTEM_NIXOS (now symlinked)"
echo ""
echo "Your NixOS configuration is now managed from ~/.config/nixos"
echo "Git repository: https://github.com/qreenify/nixos-config"
