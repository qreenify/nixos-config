# Virt-Manager Setup Guide

Your NixOS configuration now includes full KVM/QEMU virtualization support with virt-manager GUI.

## What's Included

✅ **virt-manager** - Graphical VM manager
✅ **QEMU/KVM** - Hardware-accelerated virtualization
✅ **SPICE** - USB redirection, clipboard sharing, etc.
✅ **OVMF/UEFI** - Modern UEFI boot support with Secure Boot
✅ **TPM 2.0** - For Windows 11 VMs
✅ **libvirtd group** - Your user can manage VMs without sudo

## First Time Setup

After rebuilding:

```bash
# Rebuild to apply changes
rebuild

# Verify libvirtd is running
systemctl status libvirtd

# Launch virt-manager
virt-manager
```

## Creating a NixOS VM for Testing

### Option 1: Use the Built-in VM Config (Recommended)

Build an ISO from your config:

```bash
cd ~/.config/nixos

# Build a live ISO with your configuration
nix build .#nixosConfigurations.nixos-vm.config.system.build.isoImage
```

Then in virt-manager:
1. Click "Create a new virtual machine"
2. Choose "Local install media (ISO)"
3. Browse to the built ISO in `./result/iso/`
4. Allocate RAM (4GB+) and CPUs (4+)
5. Create disk (20GB+)
6. Name it "nixos-test" and finish

### Option 2: Manual NixOS Installation

1. Download NixOS ISO: https://nixos.org/download
2. Create VM in virt-manager with the ISO
3. Install NixOS in the VM
4. Clone your config:
   ```bash
   git clone https://github.com/qreenify/nixos-config ~/.config/nixos
   cd ~/.config/nixos
   sudo ./deploy.sh
   sudo nixos-rebuild switch --flake .#nixos
   ```

## Useful Features

### Clipboard Sharing
SPICE agent enables copy-paste between host and VM. For NixOS guests:
```nix
services.spice-vdagentd.enable = true;
```

### USB Passthrough
1. Click VM → Redirect USB device
2. Select your device from the list
3. It will disconnect from host and attach to VM

### Shared Folders
For easy file sharing between host and VM:
1. Add a filesystem device in VM settings
2. Set source path on host
3. Mount in guest (virtiofs)

### Snapshots
Take snapshots before testing:
1. Click the snapshot icon (camera)
2. Name it (e.g., "Before theme testing")
3. Restore anytime via "Manage snapshots"

## Performance Tips

1. **Enable 3D acceleration** in Display settings
2. **Use virtio drivers** for disk and network (Linux guests)
3. **Allocate enough RAM** - 4GB minimum, 8GB recommended
4. **Use host CPU passthrough** for better performance
5. **Enable KVM** - should be automatic on your hardware

## Troubleshooting

### "Could not connect to libvirt"
```bash
# Start libvirtd
sudo systemctl start libvirtd

# Enable on boot
sudo systemctl enable libvirtd
```

### "Permission denied" when creating VMs
```bash
# Verify you're in libvirtd group
groups | grep libvirtd

# If not, logout and login again after rebuild
```

### VM is slow
- Check that KVM is enabled: `lsmod | grep kvm`
- Verify CPU virtualization: `grep -E 'vmx|svm' /proc/cpuinfo`
- Use virtio drivers instead of IDE/SATA

### Windows 11 Installation
Windows 11 requires TPM 2.0 (already enabled in config):
1. Add TPM device in VM settings (should be automatic)
2. Use UEFI boot mode
3. Download virtio drivers ISO: https://fedorapeople.org/groups/virt/virtio-win/direct-downloads/

## CLI Alternative

You can also manage VMs via `virsh`:

```bash
# List VMs
virsh list --all

# Start VM
virsh start nixos-test

# Connect to console
virsh console nixos-test

# Shutdown VM
virsh shutdown nixos-test

# Delete VM
virsh undefine nixos-test --remove-all-storage
```

## Resources

- Virt-Manager: https://virt-manager.org/
- NixOS Wiki: https://nixos.wiki/wiki/Virt-manager
- QEMU/KVM: https://www.qemu.org/
