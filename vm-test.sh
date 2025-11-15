#!/usr/bin/env bash
# Build and run NixOS VM for testing the flake

set -e

cd "$(dirname "$0")"

echo "🚀 Building NixOS VM..."
echo ""

# Build the VM
nix build .#nixosConfigurations.nixos-vm.config.system.build.vm

echo ""
echo "✅ VM built successfully!"
echo ""
echo "Starting VM..."
echo ""
echo "📝 VM Info:"
echo "   Username: qreenify"
echo "   Password: test"
echo "   RAM: 4GB"
echo "   Cores: 4"
echo "   Disk: 20GB"
echo ""
echo "Press Ctrl+C to stop the VM"
echo ""

# Run the VM
QEMU_KERNEL_PARAMS=console=ttyS0 ./result/bin/run-nixos-vm
