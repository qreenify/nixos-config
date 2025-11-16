# NixOS Build Types Explained

Understanding the different NixOS build outputs and where they create files.

## Overview

In your flake.nix, you have different `nixosConfigurations`:
- `nixos` - Your main system configuration
- `nixos-vm` - VM build configuration
- `wonderland-iso` - ISO build configuration (moved to separate repo)

**Important**: These are just different **build outputs** from the same source configuration files. They don't create their own config folders.

---

## 1. Main System Build (`nixos`)

### What it is
Your actual running NixOS system.

### Where config lives
```
/home/qreenify/.config/nixos/     ← Your source files (git tracked)
/etc/nixos/                        ← Deployed config (symlinked from above)
```

### How it's built
```bash
# When you run:
rebuild

# It does:
sudo nixos-rebuild switch --flake /etc/nixos#nixos
```

### Where it goes
- **Source**: Your git repo at `~/.config/nixos`
- **Deployed**: Copied to `/etc/nixos` by deploy.sh
- **Built system**: `/nix/store/...-nixos-system-...`
- **Active**: Linked from `/run/current-system`

**No separate folder created** - it modifies your running system.

---

## 2. VM Build (`nixos-vm`)

### What it is
A **QEMU virtual machine** built from your configuration.

### Command to build
```bash
cd ~/.config/nixos
nix build .#nixosConfigurations.nixos-vm.config.system.build.vm
```

### Where it goes
```
~/.config/nixos/result/          ← Symlink to Nix store
~/.config/nixos/nixos.qcow2      ← VM disk image (created when you run VM)
```

**Does NOT create a separate config folder!** It:
1. Reads from your existing `~/.config/nixos/` files
2. Builds a QEMU VM in `/nix/store/...`
3. Creates a `result` symlink pointing to the build
4. When you run it, creates `nixos.qcow2` for VM storage

### How to use
```bash
# Build the VM
nix build .#nixosConfigurations.nixos-vm.config.system.build.vm

# Run it
./result/bin/run-nixos-vm

# Or use the helper script
./vm-test.sh
```

### What happens when running
1. VM boots from the Nix store image
2. Creates `nixos.qcow2` in current directory (VM's hard drive)
3. VM can read your config from `/nix/store/...`
4. Changes in VM are saved to `nixos.qcow2`
5. Your source files at `~/.config/nixos` are NOT modified

### File structure after building
```
~/.config/nixos/
├── flake.nix              ← Your source files
├── vm.nix                 ← VM-specific config
├── modules/               ← Shared modules
├── result/                ← Symlink to /nix/store/.../vm
│   └── bin/
│       └── run-nixos-vm   ← VM runner script
└── nixos.qcow2            ← VM disk (created on first run)
```

---

## 3. ISO Build (`wonderland-iso`)

### What it is
A **bootable ISO image** for installing NixOS.

### Command to build
```bash
cd ~/.config/nixos  # or ~/git/wonderland-iso when ready
nix build .#nixosConfigurations.wonderland-iso.config.system.build.isoImage
```

### Where it goes
```
~/.config/nixos/result/
└── iso/
    └── nixos-25.05-x86_64-linux.iso    ← The bootable ISO file
```

**Does NOT create a separate config folder!** It:
1. Reads from your existing `~/.config/nixos/` files
2. Builds an ISO image in `/nix/store/...`
3. Creates a `result` symlink pointing to the build
4. The ISO contains a copy of your config at `/nixos-config/`

### How to use
```bash
# Build the ISO
nix build .#nixosConfigurations.wonderland-iso.config.system.build.isoImage

# Write to USB
sudo dd if=result/iso/nixos-*.iso of=/dev/sdX bs=4M status=progress

# Boot from USB, then install
sudo wonderland-install
```

### What's inside the ISO
```
ISO Contents:
├── /nixos-config/              ← Copy of your ~/.config/nixos
├── /nix/store/...              ← NixOS packages
├── /bin/wonderland-install     ← Installer script
└── ... (boot files, kernel, etc.)
```

When you boot the ISO:
1. Live environment starts (GNOME desktop)
2. Your config is available at `/nixos-config/`
3. Installer copies it to the target disk's `/etc/nixos/`
4. Runs `nixos-install` to build the system

### File structure after building
```
~/.config/nixos/
├── flake.nix              ← Your source files
├── iso-config.nix         ← ISO-specific config
├── modules/               ← Shared modules
└── result/                ← Symlink to /nix/store/.../iso
    └── iso/
        └── nixos-25.05-x86_64-linux.iso
```

---

## Key Concepts

### 1. Source vs Build
- **Source**: Your configuration files in git (`~/.config/nixos/`)
- **Build**: The result in `/nix/store/...` (read-only)
- **Symlink**: `result` points to the build for convenience

### 2. No Separate Folders
None of these create their own config folders!

They all use **the same source files** but build **different outputs**:
- `nixos` → Running system
- `nixos-vm` → QEMU VM
- `wonderland-iso` → Bootable ISO

### 3. Module Reuse

Your `vm.nix` and `iso-config.nix` **import** modules from the main config:

```nix
# vm.nix imports:
./modules/networking.nix
./modules/locale.nix
./modules/packages.nix

# They're the SAME files as your main system uses
```

### 4. Where Builds Go

All builds end up in `/nix/store/`:
```
/nix/store/
├── abc123...nixos-system-wondernixlandos-25.11/    ← Main system
├── def456...vm/                                     ← VM
└── ghi789...iso-nixos-25.05.iso/                   ← ISO
```

The `result` symlink is just for convenience:
```bash
ls -la result
# lrwxrwxrwx result -> /nix/store/ghi789...iso-nixos-25.05.iso
```

---

## Common Workflows

### Testing Config Changes in VM

```bash
# 1. Edit your config
vim ~/.config/nixos/modules/packages.nix

# 2. Build VM with changes
nix build .#nixosConfigurations.nixos-vm.config.system.build.vm

# 3. Run VM to test
./result/bin/run-nixos-vm

# 4. If good, apply to main system
rebuild
```

### Creating Installation Media

```bash
# 1. Build ISO
nix build .#nixosConfigurations.wonderland-iso.config.system.build.isoImage

# 2. Write to USB
sudo dd if=result/iso/nixos-*.iso of=/dev/sdX bs=4M status=progress

# 3. Boot on target machine
# 4. Install using your config
```

---

## Example: What Happens When Building

### Building VM:

```bash
$ nix build .#nixosConfigurations.nixos-vm.config.system.build.vm

# Nix does:
1. Reads flake.nix
2. Evaluates nixosConfigurations.nixos-vm
3. Reads vm.nix
4. Imports referenced modules (networking.nix, etc.)
5. Builds everything into /nix/store/abc123-vm/
6. Creates result -> /nix/store/abc123-vm/
```

**No new config folders created!**

The VM **uses** your existing config files to **produce** a VM image.

---

## Summary

| Build Type | Command | Output Location | Creates Config Folder? |
|------------|---------|-----------------|----------------------|
| Main System | `rebuild` | `/run/current-system` | ❌ No (uses `/etc/nixos`) |
| VM | `nix build .#nixos-vm...` | `./result/` + `nixos.qcow2` | ❌ No (reads from source) |
| ISO | `nix build .#wonderland-iso...` | `./result/iso/*.iso` | ❌ No (includes copy in ISO) |

**All three use the SAME source configuration at `~/.config/nixos/`**

They just build different **outputs** for different purposes:
- System: Daily use
- VM: Testing
- ISO: Installation
