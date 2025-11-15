#!/usr/bin/env bash
# Deploy NixOS configuration from ~/.config/nixos to /etc/nixos

set -e

# Use ~/.config/nixos as the source directory
CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/nixos"
TARGET="/etc/nixos"

echo "🚀 Deploying NixOS configuration..."
echo "   Source: $CONFIG_DIR"
echo "   Target: $TARGET"
echo

# Verify source directory exists
if [ ! -d "$CONFIG_DIR" ]; then
    echo "❌ Error: Configuration directory not found: $CONFIG_DIR"
    echo "   Please ensure your NixOS configs are in ~/.config/nixos/"
    exit 1
fi

# Copy main flake
echo "📝 Copying flake.nix..."
sudo cp "$CONFIG_DIR/flake.nix" "$TARGET/"

# Copy modules directory
echo "📦 Copying modules/..."
sudo cp -r "$CONFIG_DIR/modules" "$TARGET/"

# Copy config directory (if exists)
if [ -d "$CONFIG_DIR/config" ]; then
    echo "⚙️  Copying config/..."
    sudo cp -r "$CONFIG_DIR/config" "$TARGET/"
fi

# Copy scripts directory (if exists)
if [ -d "$CONFIG_DIR/scripts" ]; then
    echo "📜 Copying scripts/..."
    sudo cp -r "$CONFIG_DIR/scripts" "$TARGET/"
fi

# Copy theme directory (if exists)
if [ -d "$CONFIG_DIR/theme" ]; then
    echo "🎨 Copying theme/..."
    sudo cp -r "$CONFIG_DIR/theme" "$TARGET/"
fi

# Copy hardware-configuration.nix (if exists)
if [ -f "$CONFIG_DIR/hardware-configuration.nix" ]; then
    echo "🖥️  Copying hardware-configuration.nix..."
    sudo cp "$CONFIG_DIR/hardware-configuration.nix" "$TARGET/"
fi

echo
echo "✅ Deployment complete!"
echo
echo "Next steps:"
echo "  Run: ~/.config/nixos/rebuild.sh"
echo "  Or manually: sudo nixos-rebuild switch --flake /etc/nixos#nixos"
