#!/usr/bin/env bash
# Rebuild NixOS system

set -e

CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/nixos"
FLAKE_PATH="/etc/nixos#nixos"

# Parse command line arguments
MODE="${1:-switch}"

case "$MODE" in
    switch|boot|test|build|dry-build|dry-activate)
        ;;
    *)
        echo "Usage: $0 [switch|boot|test|build|dry-build|dry-activate]"
        echo ""
        echo "Modes:"
        echo "  switch        - Build and activate new configuration (default)"
        echo "  boot          - Build new configuration, activate on next boot"
        echo "  test          - Build and activate, but don't add boot entry"
        echo "  build         - Build only, don't activate"
        echo "  dry-build     - Show what would be built"
        echo "  dry-activate  - Show what would be changed"
        exit 1
        ;;
esac

echo "🔄 NixOS Rebuild: $MODE"
echo ""

# First, deploy the configuration
echo "📦 Deploying configuration from $CONFIG_DIR to /etc/nixos..."
"$CONFIG_DIR/deploy.sh"
echo ""

# Then rebuild
echo "🔨 Running nixos-rebuild $MODE..."
sudo nixos-rebuild "$MODE" --flake "$FLAKE_PATH"

echo ""
echo "✅ Rebuild complete!"
