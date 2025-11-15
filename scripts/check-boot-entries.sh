#!/usr/bin/env bash
# Check boot entries to verify Windows is detected

echo "=== EFI Boot Entries ==="
echo ""
echo "Checking /boot/EFI/ for other operating systems:"
sudo ls -la /boot/EFI/

echo ""
echo "=== Systemd-Boot Entries ==="
echo ""
echo "Boot loader entries in /boot/loader/entries/:"
sudo ls -la /boot/loader/entries/

echo ""
echo "=== Instructions ==="
echo "Windows should appear as /boot/EFI/Microsoft/ if installed"
echo "Arch should appear as /boot/EFI/arch/ or similar"
echo ""
echo "If Windows is not showing in boot menu:"
echo "1. Check if /boot/EFI/Microsoft/Boot/bootmgfw.efi exists"
echo "2. systemd-boot should auto-detect it"
echo "3. You may need to manually add a boot entry if not detected"
